function [dim, attGlobales, var] = abrirFicheroNC_EARLINET(nombreFichero)
    % Funcion que abre los ficheros *.nc formato netCDF que proporcionan los de EARLINET
    % Lee las dimensiones, variables y sus atributos, así como los atributos globales, creando una estructura y situa
    % los valores en el vector arrayDatos
    ncid = netcdf.open(nombreFichero, 'NOWRITE');
    if (ncid ~= 0)
        [ndims,nvars,ngatts,unlimdimid] = netcdf.inq(ncid);
        % Bucle de Dimensiones
        for i = 1:ndims
            [dim(i).nombre, dim(i).longitud] = netcdf.inqDim(ncid,i-1);
        end %
        % Bucle de Variables
        for i = 1:nvars
            [var(i).nombre, var(i).tipo, dimids, var(i).natts] = netcdf.inqVar(ncid,i-1);
            % Modificado el 16/01/2020 porque hay un tipo de variable no
            % soportado
            if var(i).tipo == 12
                var(i).valores = nan;
            else
                var(i).valores = netcdf.getVar(ncid,i-1);
            end %if
            % fin de la modificacion 16/01/2020
            % Subbucle de atributos
            for j = 1:var(i).natts
               [var(i).att(j).nombre] = netcdf.inqAttName(ncid, i-1,  j-1);
               [var(i).att(j).tipo, var(i).att(j).lon] = netcdf.inqAtt(ncid, i-1,  var(i).att(j).nombre);
               [var(i).att(j).valor] = netcdf.getAtt( ncid, i-1,  var(i).att(j).nombre);
            end 
            %Bucle que obtiene el valor de las variables
            [varid(i)] =  netcdf.inqVarID( ncid, var(i).nombre);
            % Modificado el 16/01/2020 porque hay un tipo de variable no
            % soportado
            if var(i).tipo == 12
                [var(i).Datos] = nan;
            else
                [var(i).Datos] = netcdf.getVar( ncid, varid(i));
            end %if
            % fin de la modificacion 16/01/2020
            indicesFiller = find(var(i).Datos > 9e+036);
            var(i).Datos(indicesFiller) = NaN; % Sustituye los valores del filler (9.9692099...e+036) por NaN
        end 
        % Bucle de atributos globales
        for i = 1:ngatts
            [attGlobales(i).nombre] = netcdf.inqAttName( ncid,netcdf.getConstant('NC_GLOBAL'), i-1);
            [attGlobales(i).tipo, attGlobales(i).lon] =netcdf.inqAtt( ncid, netcdf.getConstant('NC_GLOBAL'), attGlobales(i).nombre);
            [attGlobales(i).valor] =  netcdf.getAtt( ncid, netcdf.getConstant('NC_GLOBAL'), attGlobales(i).nombre);
        end 
        netcdf.close(ncid);
    else
        error_message = mexnc('strerror', status);
        errordlg(error_message, 'Error en función AbrirFicheroNC');
    end 
end
