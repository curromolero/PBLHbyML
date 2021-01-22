clear all;
close all;
clc;
%% Lectura de datos de la torre meteorologica
cd('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos\Torre Meteorologica');
[nombreFichero, directorio] = uigetfile('*-verif.xlsx','Seleccione el fichero que se desea representar');
files = dir(fullfile(directorio,nombreFichero));

for i = 1:length(files)
    filename = files(i).name;
    display(files(i).name)
    [~, ~, raw] = xlsread(files(i).name,'Datos Diezminutales','A2:I4465','',@convertSpreadsheetExcelDates);
    stringVectors = string(raw(:,1));
    stringVectors(ismissing(stringVectors)) = '';
    raw = raw(:,[2,3,4,5,6,7,8,9]);

    %% Create output variable
    data = reshape([raw{:}],size(raw));

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

    % For code requiring serial dates (datenum) instead of datetime, uncomment
    % the following line(s) below to return the imported dates as datenum(s).

    % FechaUTC=datenum(FechaUTC);

    %% Clear temporary variables
    clearvars data raw dates R;
end

Datos = [FechaUTC TSuperiorC TInferiorC Humedadmm DirViento VelVientoms Precipitacinmm Presinmb RadiacinWm2];
save('Datos.mat','Datos');