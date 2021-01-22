function [error, valoresSondeoUnicos, attGlobales] = abrirFicheroRS_formatoEXCELconTexto(direccionFichero)
% Lee los ficheros de los radiosondeos de alta resolución que se descargan
% de internet de la página Web de meteociel.fr y los coloca en una tabla
% valoressondeo y una struct attGlobales

% Abre el fichero y extrae los datos del fichero
[num,txt,raw] = xlsread(direccionFichero);
structPrimeraLinea = extraerInformacionPrimeraLinea(txt(1, 1));
structSegundaLinea = extraerInformacionSegundaLinea(txt(2, 1));
structSegundaLineaBis = extraerInformacionSegundaLineaBis(txt(2, 2));

sizeDatos = size(txt);
valoresSondeo = zeros(sizeDatos(1) - 3, sizeDatos(2) + 5);
for i = 4:length(txt(:, 1)) % Altitud (m asl)
    ValueTxt = char(txt(i, 1));
    Index = strfind(ValueTxt, 'm');
    valoresSondeo((i-3), 1) = sscanf(ValueTxt(1:(Index(1)-1)), '%g', 1);
end %for

for i = 4:length(txt(:, 2)) % Presión (hPa)
    ValueTxt = char(txt(i, 2));
    Index = strfind(ValueTxt, 'hPa');
    valoresSondeo((i-3), 2) = sscanf(ValueTxt(1:(Index(1)-1)), '%g', 1);
end %for

for i = 4:length(txt(:, 3)) % Temperatura (ºC)
    ValueTxt = char(txt(i, 3));
    Index = strfind(ValueTxt, 'C');
    valoresSondeo((i-3), 3) = sscanf(ValueTxt(1:(Index(1)-2)), '%g', 1);
end %for

for i = 4:length(txt(:, 4)) % Theta W (ºC)
    ValueTxt = char(txt(i, 4));
    Index = strfind(ValueTxt, 'C');
    valoresSondeo((i-3), 4) = sscanf(ValueTxt(1:(Index(1)-2)), '%g', 1);
end %for

for i = 4:length(txt(:, 5)) % Punto de Rocio (ºC)
    ValueTxt = char(txt(i, 5));
    Index = strfind(ValueTxt, 'C');
    valoresSondeo((i-3), 5) = sscanf(ValueTxt(1:(Index(1)-2)), '%g', 1);
end %for

for i = 4:length(raw(:, 6))
    valoresSondeo((i-3), 6) = raw{i, 6} * 100; %Humidity (%)
end %for

% Modificación del 02/03/2020 porque luego da problemas en la interpolación
% Eliminación de los valores de altitud repetidos, borrando toda la linea
[~, ind] = unique(valoresSondeo(:, 1), 'stable');
valoresSondeoUnicos = valoresSondeo(ind, :);
% Fin de la modificación del 02/03/2020

% Calculo de los otros parametros, para tener Information in RS:
% 'HGHT' 'PRES' 'TEMP' 'THEW' 'DWPT' 'RELH' 'MIXR' 'DRCT' 'SKNT' 'THTA' 'THTE' 'THTV'
% Humedad relativa

% Modificado el 09/10/2018 para usar las formulas de Vaisala
% presionVaporActual_antigua = 6.1086*exp(17.856*valoresSondeo(:, 5)./(245.52 + valoresSondeo(:, 5))); % Calculada con DewPoint Temp
indicesDWPTPositiva = find(valoresSondeoUnicos(:, 5) >= 0);
indicesDWPTNegativa = find(valoresSondeoUnicos(:, 5) < 0);
Theta = zeros(length(valoresSondeoUnicos(:, 5)), 1);
presionVaporActual = zeros(length(valoresSondeoUnicos(:, 5)), 1);
% DWPT positivas
Theta(indicesDWPTPositiva, 1) = 1 - (valoresSondeoUnicos(indicesDWPTPositiva, 5) + 273.16) / 647.096;
presionVaporActual(indicesDWPTPositiva, 1) = 220640 * exp((647.096 ./ (valoresSondeoUnicos(indicesDWPTPositiva, 5) + 273.16)) .* ...
    (-7.85951783 * Theta(indicesDWPTPositiva, 1) + 1.84408259 * Theta(indicesDWPTPositiva, 1).^1.5 + -11.7866497 * Theta(indicesDWPTPositiva, 1).^3 + ...
    22.6807411 * Theta(indicesDWPTPositiva, 1).^3.5 + -15.9618719 * Theta(indicesDWPTPositiva, 1).^4 + 1.80122502 * Theta(indicesDWPTPositiva, 1).^7.5));
% DWPTeraturas negativas
Theta(indicesDWPTNegativa, 1) = (valoresSondeoUnicos(indicesDWPTNegativa, 5) + 273.16) / 273.16;
presionVaporActual(indicesDWPTNegativa, 1) = 6.11657 * exp(-13.928169*(1-Theta(indicesDWPTNegativa, 1) .^(-1.5))+34.707823*(1-Theta(indicesDWPTNegativa, 1) .^(-1.25)));

% presionVaporSaturada_antigua = 6.1086*exp(17.856*valoresSondeoUnicos(:, 3)./(245.52 + valoresSondeoUnicos(:, 3))); % Calculada con Temp
indicesTempPositiva = find(valoresSondeoUnicos(:, 3) >= 0);
indicesTempNegativa = find(valoresSondeoUnicos(:, 3) < 0);
Theta = zeros(length(valoresSondeoUnicos(:, 3)), 1);
presionVaporSaturada = zeros(length(valoresSondeoUnicos(:, 3)), 1);
% Temperaturas positivas
Theta(indicesTempPositiva, 1) = 1 - (valoresSondeoUnicos(indicesTempPositiva, 3) + 273.16) / 647.096;
presionVaporSaturada(indicesTempPositiva, 1) = 220640 * exp((647.096 ./ (valoresSondeoUnicos(indicesTempPositiva, 3) + 273.16)) .* ...
    (-7.85951783 * Theta(indicesTempPositiva, 1) + 1.84408259 * Theta(indicesTempPositiva, 1).^1.5 + -11.7866497 * Theta(indicesTempPositiva, 1).^3 + ...
    22.6807411 * Theta(indicesTempPositiva, 1).^3.5 + -15.9618719 * Theta(indicesTempPositiva, 1).^4 + 1.80122502 * Theta(indicesTempPositiva, 1).^7.5));
% Temperaturas negativas
Theta(indicesTempNegativa, 1) = (valoresSondeoUnicos(indicesTempNegativa, 3) + 273.16) / 273.16;
presionVaporSaturada(indicesTempNegativa, 1) = 6.11657 * exp(-13.928169*(1-Theta(indicesTempNegativa, 1).^(-1.5))+34.707823*(1-Theta(indicesTempNegativa, 1).^(-1.25)));
% plot(presionVaporSaturada_antigua, valoresSondeoUnicos(:, 1), '-or', presionVaporSaturada, valoresSondeoUnicos(:, 1), '+k');
% plot(presionVaporActual_antigua, valoresSondeoUnicos(:, 1), '-or', presionVaporActual, valoresSondeoUnicos(:, 1), '+k');

% Fin de la modificación 09/10/2018

RELH = (presionVaporActual./presionVaporSaturada)*100;
% plot(RELH, valoresSondeoUnicos(:, 1), valoresSondeoUnicos(:, 6), valoresSondeoUnicos(:, 1));
% Mixing ratio
MIXR = 621.9907*presionVaporActual./(valoresSondeoUnicos(:, 2) - presionVaporActual);
valoresSondeoUnicos(:, 7) = MIXR;
% Temperatura potencial
% TMPK - Temperature in Kelvin
% THTA - Potential temperature in Kelvin: TMPK * ( 1000 / PRES ) ** KAPPA 
% KAPPA = Poisson's constant = 2 / 7 or 0.288
% THTE - Equivalent potential temperature in Kelvin: THTM * EXP [ ( 3.376 /
% TLCL - .00254 ) * ( MIXR * ( 1 + .81 * .001 * MIXR ) ) ].
% THTM = potential temperature for moist air
%      = TMPK * ( 1000 / PRES ) ** E
% E    = 2. / 7. * ( 1 - ( .28 * .001 * MIXR ) )
% TLCL = temperature at the LCL in Kelvin
% THTV - Virtual potential temperature in Kelvin: TVRK * ( 1000 / PRES ) **
% KAPPA
% TVRK = TMPK * ( 1 + ( .001 * MIXR ) / .62197) ) / ( 1 + ( .001 * MIXR ) )
 
THTA = (valoresSondeoUnicos(:, 3) + 273.16).*power((valoresSondeoUnicos(:, 2)/1000), -0.288);
THTE = (valoresSondeoUnicos(:, 3) + 273.16).*power((valoresSondeoUnicos(:, 2)/1000), -2. / 7. * (1-(.28*.001*MIXR)));
THTV = THTA.*(1+0.00061*MIXR);
valoresSondeoUnicos(:, 10) = THTA;
valoresSondeoUnicos(:, 11) = THTE;
valoresSondeoUnicos(:, 12) = THTV;
 
% Información de la estación
attGlobales = struct('Location', {}, 'St_no', {}, ...
    'Altitude_meter_asl', {}, 'MaxAltitude', {}, 'StartDate', {}, ...
    'StartTime_UT', {});
attGlobales(1).Location = structPrimeraLinea.Station_location;
attGlobales.St_no = structPrimeraLinea.Station_identifier;
attGlobales.Altitude_meter_asl = structPrimeraLinea.Station_elevation;
attGlobales.MaxAltitude = max(valoresSondeoUnicos(:, 1));
attGlobales.StartDate = datestr(datetime(structSegundaLineaBis.Fecha, 'InputFormat', 'dd/MM/yyyy '), 'yyyymmdd');
attGlobales.StartTime_UT = datestr(datetime(structSegundaLineaBis.HoraZ, 'InputFormat', 'HHZ', 'TimeZone', 'UTC'), 'HHMMSS');
error = 0;

function structPrimeraLinea = extraerInformacionPrimeraLinea(PrimeraLinea)
% Extrae las variables de la primera línea, que son:
% Station 8221 - Madrid / Barajas (Alt. 609m )
[dummy, rem] = strtok(PrimeraLinea);
[codigoWMO, rem] = strtok(rem);
[dummy, rem] = strtok(rem);
[Ciudad, rem] = strtok(rem);
[dummy, rem] = strtok(rem);
[Lugar, rem] = strtok(rem); 
[dummy, rem] = strtok(rem);
[Altitud, rem] = strtok(rem);
structPrimeraLinea = struct('Station_identifier', {codigoWMO}, ...
    'Station_city', {Ciudad}, 'Station_location', {Lugar}, 'Station_elevation', {Altitud});

function structSegundaLinea = extraerInformacionSegundaLinea(SegundaLinea)
% Extrae las variables de la segunda línea, que son:
%  Mardi 28 juin 2016 1:00 locale 
[DiaSemana, rem] = strtok(SegundaLinea);
[dia, rem] = strtok(rem);
[mes, rem] = strtok(rem);
[agno, rem] = strtok(rem);
[hora, rem] = strtok(rem);
structSegundaLinea = struct('WeekDay', {DiaSemana}, 'Day', {dia}, ...
    'Month', {mes}, 'Agno', {agno}, 'LocalTime', {hora});

function structSegundaLineaBis = extraerInformacionSegundaLineaBis(SegundaLineaBis)
% Extrae las variables de la segunda línea, segunda columna, que son:
%  ' Obs 11Z du 19/05/2016 ' 
[dummy, rem] = strtok(SegundaLineaBis);
[horaZ, rem] = strtok(rem);
[dummy, rem] = strtok(rem);
[Fecha, rem] = strtok(rem);
structSegundaLineaBis = struct('HoraZ', {horaZ}, 'Fecha', {Fecha});