clearvars;
close all;
clc;
%% Lectura de datos de los radiosondeos en superficie
% pathfile = '\\cendat2\lidar\CeilometroLufft_CHM15k\Datos';
pathfile = '/Users/curromolero/Documents/Cosas de Curro/Software Ceilometro/Datos/Torre meteorologica';
cd(pathfile);
[filename, pathfile] = uigetfile('*verif.xlsx','Seleccione el fichero que se desea representar');

% files = dir(fullfile(pathfile,filename));

%% Allocate imported array to column variable names
    FechaUTC = [];
    TSuperiorC = [];
    TInferiorC = [];
    Humedadmm = [];
    DirViento = [];
    VelVientoms = [];
    Precipitacinmm = [];
    Presinmb = [];
    RadiacinWm2 = [];

% for i = 1:length(files)
%     filename = files(i).name;
%     display(files(i).name)
    [~, ~, raw] = xlsread(fullfile(pathfile,filename),'Datos Diezminutales','A2:I4465','',@convertSpreadsheetExcelDates);
    validIndices = find(ismissing(string(raw(:,1)))==0);
    stringVectors = string(raw(validIndices,1));
    % stringVectors(ismissing(stringVectors)) = '';
    raw = raw(validIndices,[2,3,4,5,6,7,8,9]);

    %% Create output variable
    data = reshape([raw{:}],size(raw));
    
    formatIn = 'dd/mm/yyyy hh:MM';
    aux = cellstr(stringVectors(:,1));
    
    FechaUTC = [FechaUTC; datenum(aux,formatIn)];
    TSuperiorC = [ TSuperiorC; data(:,1)];
    TInferiorC  = [ TInferiorC; data(:,2)];
    Humedadmm = [ Humedadmm; data(:,3)];
    DirViento = [ DirViento; data(:,4)];
    VelVientoms = [ VelVientoms; data(:,5)];
    Precipitacinmm = [ Precipitacinmm; data(:,6)];
    Presinmb = [Presinmb; data(:,7)];
    RadiacinWm2 = [ RadiacinWm2; data(:,8)];

    % Read CAMS McClear v3.1 Data
    pathfile_CAMS = '/Users/curromolero/Documents/Cosas de Curro/Software Ceilometro/Datos/ESA CAMS';
    cd(pathfile_CAMS);
    [filename_CAMS, pathfile_CAMS] = uigetfile('adaptor.cams_solar_rad2*','Seleccione el fichero que se desea representar');

    fid = fopen(fullfile(pathfile_CAMS,filename_CAMS));
    for i=1:43
        fgetl(fid);
    end
    out = textscan(fid, '%s%f%f%f%f%f%f%f%f%f%f', 'delimiter', ';');
    fclose(fid);
    
    formatIn = 'yyyy-mm-ddTHH:MM:SS.FFF';
    date_CAMS = datenum(out{1},formatIn);
    
    figure;
    plot(FechaUTC, TSuperiorC - TInferiorC)
    figure;
    plot(FechaUTC, RadiacinWm2)
    hold on;
    plot(date_CAMS, out{3}*3.8, 'r');
    plot(date_CAMS, out{7}*3.8, 'b');
    hold off;
    
    % Clasificar los dias por despejado o cubierto
    CAMS_interp = interp1(date_CAMS, out{3}*3.8, FechaUTC); 
    dias0a24h = FechaUTC - floor(FechaUTC);
    dias = FechaUTC(dias0a24h == 0.5); % 0.5 son las 12:00. 0 las 00:00
    clasificacionDias = zeros(length(dias), 2);
    for i = 1:length(dias)
        clasificacionDias(i, 1) = dias(i);
        indice12horas = find(FechaUTC == dias(i));
        indiceHoras11a13 = (indice12horas - 6:indice12horas + 6);
        integralClearSky = trapz(FechaUTC(indiceHoras11a13),CAMS_interp(indiceHoras11a13));
        integralPiranometro = trapz(FechaUTC(indiceHoras11a13),RadiacinWm2(indiceHoras11a13));
        clasificacionDias(i, 2) = integralPiranometro/integralClearSky;   
    end %for
    
    figure;
    plot(clasificacionDias(:, 1), clasificacionDias(:, 2), '-+');
    [filepath,name,ext] = fileparts(filename);
    % csvwrite(append(filepath,name,'.csv'), clasificacionDias);
    
    fileID = fopen(append(filepath,name,'.txt'),'w');
    for i = 1:length(dias)
        if clasificacionDias(i, 2) > 0.7
            comoeseldia = 'despejado';
        else
            comoeseldia = 'cubierto';
        end %if
        nuevalinea = [datestr(clasificacionDias(i, 1)), ' estaba ', comoeseldia];
        fprintf(fileID,'%s\n',nuevalinea);
    end %fo
    fclose(fileID);
    
    % For code requiring serial dates (datenum) instead of datetime, uncomment
    % the following line(s) below to return the imported dates as datenum(s).

    % FechaUTC=datenum(FechaUTC);

    %% Clear temporary variables
    % clearvars data raw dates R;
% end

% Datos = [FechaUTC TSuperiorC TInferiorC Humedadmm DirViento VelVientoms Precipitacinmm Presinmb RadiacinWm2];
% save('Datos.mat','Datos');