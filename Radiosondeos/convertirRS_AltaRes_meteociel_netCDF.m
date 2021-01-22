% Script convertirRS_AltaRes_meteociel_netCDF
% Lee el fichero EXCEL descargados de meteociel.fr y lo convierte en
% un fichero netCDF con todas las variables.

% Programado por Curro, el 05/10/2018, con Matlab 9.0.0 (R2016a)

% cd('\\cendat2\lidar\EARLINET\Datos Brutos');
cd('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos\Radiosondeos');
% cd('\\cendat\u4627\Mis Documentos\CIEMAT\Proyectos\Proyectos en marcha\TFM_Victor\Datos\RS alta res');

% [ficheroRS, directorio] = uigetfile('RS_meteociel_*.*','Seleccione el fichero que se desea convertir a netCDF'); 
% fileList = {fullfile(directorio, ficheroRS)};
% Bucle sobre todos los subdirectorios buscando ficheros con nombre
% RS_AltaRes_YYYYMMDD_HHZ.xlsx
% fileList = getAllFiles('\\cendat\u4627\Mis Documentos\CIEMAT\Proyectos\Proyectos en marcha\TFM_Victor\Datos\RS alta res', 'RS_AltaRes_*.*');
fileList = getAllFiles('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos\Radiosondeos', 'RS_meteociel_*.*');
for i = 1:numel(fileList)
    [error, valoresSondeo, attGlobales] = abrirFicheroRS_formatoEXCELconTexto(fileList{i});
    [filepath,name,ext] = fileparts(fileList{i});
    newStr = split(name,'_');
    nuevoFichero = ['RS_' newStr{3} '_' newStr{4} '.nc'];
    % nuevoFichero = ['RS_' attGlobales.StartDate '_' attGlobales.StartTime_UT(1:2) 'Z.nc'];
    directorio = fileparts(fileList{i});
    direccionNuevoFichero = fullfile(directorio, nuevoFichero);
    grabarFicheroNC_RS_METEOCIEL(direccionNuevoFichero, valoresSondeo, attGlobales);
    disp(['file converted to netCDF: ' nuevoFichero])
end % for

 