function [arrayTicks, etiquetasX] = generarEtiquetasEjeXparaQuicklook(intervalo, ejeX)
% Genera las etiquetas con las horas en texto, formato HH:MM (15), para el 
% Quicklook. Comienza en la hora del primer fichero, luego busca el primer
% punto de intervalo completo (10 minutos por defecto), y sigue hasta la 
% hora del último fichero

% Modificado el 27/09/2016 para que funcione con Matlab R2106a, donde los
% Xlabels(etiquetasX) deben estar en celdas

i = 0;
fraccionHoraria = intervalo/(24*60); % 6.9444E-04 = 1 minuto en formato matlab (1 = 1 dia = 24 horas = 1440 minutos)
arrayTicks = ejeX(1);
etiquetasX = {datestr(arrayTicks, 15)};
vectorFecha = datevec(ejeX(1));
siguienteTick = datenum([0,0,0, vectorFecha(4), (vectorFecha(5)+(intervalo - mod(vectorFecha(5), intervalo))), 0]);
while siguienteTick+fraccionHoraria*i < ejeX(end)
    arrayTicks = [arrayTicks siguienteTick+fraccionHoraria*i];
    if strcmp(version('-release'),'2016a') || strcmp(version('-release'),'2017b') || strcmp(version('-release'),'2019b')
        etiquetasX{i + 2} = datestr(arrayTicks(i+2), 15);
    else
        etiquetasX = strcat(etiquetasX, datestr(arrayTicks(i+2), 15), '|');
    end %if
    i = i + 1;
end %for
if arrayTicks(end) < ejeX(end) - fraccionHoraria + 5 * 6.9444E-04 % Ultima etiqueta con 5 minutos de margen
    arrayTicks = [arrayTicks ejeX(end)];
    if strcmp(version('-release'),'2016a') || strcmp(version('-release'),'2017b') || strcmp(version('-release'),'2019b')
        etiquetasX{i + 2} = datestr(ejeX(end), 15);
    else
        etiquetasX = strcat(etiquetasX, datestr(ejeX(end), 15), '|');
    end %if
end %if
