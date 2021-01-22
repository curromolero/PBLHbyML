function [datosRS] = abrirFicheroRS(dirFichero)

datosRS = struct('altitud', {0}, 'presion', {0}, 'temp', {0}, ...
    'dwpt', {0}, 'drct', {0}, 'sknt', {0}, 'WVMixR', {0}, ...
    'RELH', {0}, 'THTV', {0});

% Si existe el fichero, se abre y obtienen los valores de presión y temperatura, en otro caso se utiliza una atmosfera standard.
if exist(dirFichero, 'file') == 2
    % Se leen los datos directamente del fichero netCDF generado
    % Information in RS: 'PRES'    'HGHT'    'TEMP'    'DWPT'    'RELH'
    % 'MIXR'    'DRCT'    'SKNT'    'THTA'    'THTE'    'THTV'
    ncid = netcdf.open(dirFichero, 'NC_NOWRITE');
    datosRS.altitud = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'HGHT'));
    datosRS.presion = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'PRES'));
    datosRS.temp = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'TEMP'));
    datosRS.dwpt = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'DWPT'));
    datosRS.drct = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'DRCT'));
    datosRS.sknt = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'SKNT'));
    datosRS.WVMIXR = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'MIXR'));
    datosRS.RELH = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'RELH'));
    datosRS.THTV = netcdf.getVar(ncid, netcdf.inqVarID(ncid,'THTV'));
    netcdf.close(ncid);
    
    % Modificacion 11/07/2016 para representar el RS
    % Truncar RS para presiones < 100 mb
%     indicesHasta100mb = find(presionRS > 100);
%     partesFichero = split(nombreFichero, '_');
%     HoraFichero = split(partesFichero{3}, '.');
%     nombreFicheroFIG = sprintf('%s%s%s%s', 'SkewT_', partesFichero{2}, '_', HoraFichero{1}, '.fig');
%     representarSkewTlogP(presionRS(indicesHasta100mb), temperaturaRS(indicesHasta100mb), altitudRS(indicesHasta100mb), dwptRS(indicesHasta100mb), drctRS(indicesHasta100mb), skntRS(indicesHasta100mb), RELHRS(indicesHasta100mb));
%     saveas(gca, nombreFicheroFIG);
    % Mejor el formato skewT-logP
    % Fin de la modificacion 11/07/2016
end %if