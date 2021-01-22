% Representacion de los datos del Ceilometro, ficheros diarios
% cd('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos');
cd('/Users/curromolero/Documents/Cosas de Curro/Software Ceilometro/Datos')
[nombreFichero, directorio] = uigetfile('*_CHM190148_*.nc','Seleccione el fichero que se desea representar');
[dim, attGlobales, var] = abrirFicheroNC_EARLINET(fullfile(directorio, nombreFichero));
if ~isempty(directorio)
    promTemp = 180; % Etiquetas cada 3 horas (180 minutos)
    fechasNum = 695422 + var(1).Datos/(24 * 60 * 60);
    ejeX = fechasNum - floor(fechasNum(1));
    ejeY = var(2).Datos;
    ejeZ = var(28).Datos;
     % Pone etiquetas cada n minutos (n * 6.9444E-04) empezando desde la hora inicial
    [arrayTicks, etiquetasX] = generarEtiquetasEjeXparaQuicklook(promTemp, ejeX); % etiquetas cada promTemp minutos
    scrsz = get(0,'ScreenSize');
    
    [Clouds_3layer, Aerosols_3layer] = searchCloudsAndAerosols(var);
    
    QL1064nm = figure('Position', [1 1 scrsz(3)/2 scrsz(4)/2]);
    pcolor(ejeX, ejeY, ejeZ);
    shading flat
    caxis([0 2E5]);
    ylim([0 12000])
    % Titulo del quicklook con longitud de onda y tipo (Pr^2), ejeX: fechas, escala de colores 
    xlabel('Time (UTC)');
    set(gca, 'XTick', arrayTicks);
    set(gca, 'XTickLabel',etiquetasX);
    ylabel('Height agl (m)');
    StartDate = strcat(num2str(attGlobales(5).valor), '/', num2str(attGlobales(6).valor), '/', num2str(attGlobales(7).valor), ',', datestr(fechasNum(1), 'HH:MM:SS'));
    StopDate = strcat(num2str(attGlobales(5).valor), '/', num2str(attGlobales(6).valor), '/', num2str(attGlobales(7).valor), ',', datestr(fechasNum(end), 'HH:MM:SS'));
    str = sprintf('%s%s%s%s', 'Start: ', StartDate, ' - Stop: ', StopDate);
    Titulo(1) = {strcat(attGlobales(1).valor, ' ', attGlobales(9).valor, ' ', attGlobales(8).valor, ' Range Corrected Signal @1064 nm')};
    Titulo(2) = {str};
    title(Titulo);
    colorbar
    hold on;
    plot(ejeX, var(41).Datos(1, :), '.w', ejeX, var(41).Datos(2, :), '.c', ejeX, var(41).Datos(3, :), '.m'); % Cloud base
    plot(ejeX, var(33).Datos(1, :), '.k', ejeX, var(33).Datos(2, :), '.r', ejeX, var(33).Datos(3, :), '.b'); % aerosol layer in PBL
    
    % Resultado de nuestro algoritmo
    plot(ejeX, Clouds_3layer(:, 1), '*w', ejeX, Clouds_3layer(:, 2), '*c', ejeX, Clouds_3layer(:, 3), '*m');
    plot(ejeX, Aerosols_3layer(:, 1), 'ok', ejeX, Aerosols_3layer(:, 2), 'or', ejeX, Aerosols_3layer(:, 3), 'ob');
    hold off;
    % Comparacion ambas estimaciones
    figure;
    subplot(1,3,1);
    plot(var(33).Datos(1, :), Aerosols_3layer(:, 1), '+k'); % Aerosols layer 1
    line(var(33).Datos(1, :), var(33).Datos(1, :), 'Color','black');
    subplot(1,3,2);
    plot(var(33).Datos(2, :), Aerosols_3layer(:, 2), '+r'); % Aerosols layer 2
    line(var(33).Datos(2, :), var(33).Datos(2, :), 'Color','red');
    subplot(1,3,3);
    plot(var(33).Datos(3, :), Aerosols_3layer(:, 3), '+b'); % Aerosols layer 3
    line(var(33).Datos(3, :), var(33).Datos(3, :), 'Color','blue');
    
%     nombreFicheroFIG = sprintf('%s%s%s%s', 'QL_1064_', datestr(fechasNum(1), 'yyyymmdd_HHMM'), '_to_', datestr(fechasNum(end), 'HHMM'), 'h.fig');
%     saveas(QL1064nm, nombreFicheroFIG);
%     % Otras variables
%     parameters = figure('Position', [scrsz(3)/2 1 scrsz(3)/2 scrsz(4)/2]);
%     % Temperaturas
%     subplot(2,2,1);
%     plot(ejeX, double(var(17).Datos)*var(17).att(3).valor - 273.15, '+k', ejeX, double(var(18).Datos)*var(18).att(3).valor - 273.15, '+r', ...
%             ejeX, double(var(19).Datos)*var(19).att(3).valor - 273.15, '+b', ejeX, double(var(20).Datos)*var(20).att(3).valor - 273.15, '+g');
%     xlabel('Time (UTC)');
%     set(gca, 'XTick', arrayTicks);
%     set(gca, 'XTickLabel',etiquetasX);
%     ylabel('Temperatures');
%     legend('internal', 'external', 'detector', 'laser optic module');
%     % state_optics
%     subplot(2,2,2);
%     plot(ejeX, var(23).Datos, '+k');
%     xlabel('Time (UTC)');
%     set(gca, 'XTick', arrayTicks);
%     set(gca, 'XTickLabel',etiquetasX);
%     ylabel('Transmission of optics');
%     % nn values
%     subplot(2,2,3);
%     plot(ejeX, var(30).Datos, '+k', ejeX, var(31).Datos, '+r', ejeX, var(32).Datos, '+b');
%     xlabel('Time (UTC)');
%     set(gca, 'XTick', arrayTicks);
%     set(gca, 'XTickLabel',etiquetasX);
%     ylabel('NN');
%     legend('nn1', 'nn2', 'nn3');
%     % Clouds
%     subplot(2,2,4);
%     plot(ejeX, var(43).Datos(1, :), '+k', ejeX, var(43).Datos(2, :), '+r', ejeX, var(43).Datos(3, :), '+b');
%     xlabel('Time (UTC)');
%     set(gca, 'XTick', arrayTicks);
%     set(gca, 'XTickLabel',etiquetasX);
%     ylabel('Cloud depth');
%     nombreFicheroPar = sprintf('%s%s%s%s', 'Parameters', datestr(fechasNum(1), 'yyyymmdd_HHMM'), '_to_', datestr(fechasNum(end), 'HHMM'), 'h.fig');
%     saveas(parameters, nombreFicheroPar);    
end %if