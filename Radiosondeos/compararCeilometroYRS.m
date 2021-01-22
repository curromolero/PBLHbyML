% Representa perfiles del ceilometro, promediados 10 minutos, con los RS de Barajas
% Horas del RS: 00:00 y 12:00 en formato 0-1: 24h:
horaRSnoche = 0.2/24;
horaRSdia = 12/24;

% Datos Ceilometro
cd('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos');
[nombreFichCeilometro, dirCeilometro] = uigetfile('*_CHM190148_*.nc','Seleccione el fichero que se desea representar');
[dim, attGlobales, var] = abrirFicheroNC_EARLINET(fullfile(dirCeilometro, nombreFichCeilometro));

if ~isempty(dirCeilometro)
    fechasNum = 695422 + var(1).Datos/(24 * 60 * 60);
    horas = fechasNum - floor(fechasNum(1));
    indice_horaRSnoche = find(horas > horaRSnoche - 15/(24*60*60) & horas <= horaRSnoche + 15/(24*60*60), 1);
    indice_horaRdia = find(horas > horaRSdia - 15/(24*60*60) & horas <= horaRSdia + 15/(24*60*60), 1);
    altura = var(2).Datos;
    betas = var(28).Datos;
    tablaBetasAerosoles = zeros(length(horas), 9);
    tablaBetasNubes = zeros(length(horas), 9);
    
    % Representacion del RS nocturno
    % Datos Ceilometro
    betaPromediado = mean(var(28).Datos(:, 1:40), 2);
    errorBetaPromediado = std(var(28).Datos(:, 1:40), 0, 2);
    % Datos RS
    cd('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos\Radiosondeos');
    [nombreFichRS, dirRS] = uigetfile('RS_*.nc', 'Seleccione el radiosondeo nocturno (00h) que se desea representar');
    [datosRS] = abrirFicheroRS(fullfile(dirRS, nombreFichRS));
    % representacion gráfica
    figuraNoche = figure('NumberTitle', 'off', 'Name', 'Comp Ceilometro vs RS nocturno');
    subplot(1,2,1);
    plot(betaPromediado, altura); % Perfil de backscattering promediado
    xlabel('beta (m^-^1 sr^-^1)');
    ylabel('altura (m)');
    ylim([0, 3000]);
    % Añadir niveles de Luftt de aerosoles
    if var(33).Datos(1, indice_horaRSnoche) ~= -1 % aerosol layer 1
        capa = var(33).Datos(1, indice_horaRSnoche);
        line(xlim,[capa, capa], 'Color', 'black', 'LineStyle', '--');
    end %if
    if var(33).Datos(2, indice_horaRSnoche) ~= -1 % aerosol layer 2
        capa = var(33).Datos(2, indice_horaRSnoche);
        line(xlim,[capa, capa], 'Color', 'red', 'LineStyle', '--');
    end %if  
    if var(33).Datos(3, indice_horaRSnoche) ~= -1 % aerosol layer 3
        capa = var(33).Datos(3, indice_horaRSnoche);
        line(xlim,[capa, capa], 'Color', 'blue', 'LineStyle', '--');
    end %if
    %Representar la temperatura potencial virtual
    ax1 = gca; % current axes
    ax1_pos = ax1.Position;
    ax2 = axes('Position',ax1_pos, 'XAxisLocation', 'top', 'YAxisLocation','right', 'Color','none');
    hold;
    plot(datosRS.THTV, datosRS.altitud - 638, 'Parent', ax2, 'Color', 'k'); % Temperatura potencial
    xlabel('Temp. pot. (ºK)');
    ylabel('altura (m)');
    ylim([0, 3000]);
    hold;
    
    subplot(1,2,2);
    plot(betaPromediado, altura); % Perfil de backscattering promediado
    xlabel('beta (m^-^1 sr^-^1)');
    ylabel('altura (m)');
    ylim([0, 10000]);
    % Añadir niveles de Luftt de nubes
    if var(41).Datos(1, indice_horaRSnoche) ~= -1 % Cloud base layer 1
        capa = var(41).Datos(1, indice_horaRSnoche);
        line(xlim,[capa, capa], 'Color', 'black', 'LineStyle', '-');
    end %if
    if var(41).Datos(2, indice_horaRSnoche) ~= -1 % Cloud base layer 2
        capa = var(41).Datos(2, indice_horaRSnoche);
        line(xlim,[capa, capa], 'Color', 'cyan', 'LineStyle', '-');
    end %if
    if var(41).Datos(3, indice_horaRSnoche) ~= -1 % Cloud base layer 3
        capa = var(41).Datos(3, indice_horaRSnoche);
        line(xlim,[capa, capa], 'Color', 'magenta', 'LineStyle', '-');
    end %if
    % Representar la humedad relativa
    ax3 = gca; % current axes
    ax3_pos = ax3.Position;
    ax4 = axes('Position',ax3_pos, 'XAxisLocation', 'top', 'YAxisLocation','right', 'Color','none');
    hold;
    % plot(datosRS.temp - datosRS.dwpt, datosRS.altitud - 638, 'Parent', ax4, 'Color', 'k'); % Diferencia Temp - Punto de Rocio
    plot(datosRS.RELH, datosRS.altitud - 638, 'Parent', ax4, 'Color', 'b'); % Relative Humidity
    xlabel('Humedad relativa (%)');
    ylabel('altura (m)');
    ylim([0, 10000]);
    hold;
        
    % Representacion del RS diurno
    % Datos Ceilometro
    betaPromediado = mean(var(28).Datos(:, (indice_horaRdia-20):(indice_horaRdia+20)), 2);
    errorBetaPromediado = std(var(28).Datos(:, (indice_horaRdia-20):(indice_horaRdia+20)), 0, 2);
    % Datos RS
    cd('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos\Radiosondeos');
    [nombreFichRS, dirRS] = uigetfile('RS_*.nc', 'Seleccione el radiosondeo diurno (12h) que se desea representar');
    [datosRS] = abrirFicheroRS(fullfile(dirRS, nombreFichRS));
    % representacion gráfica
    figuraDia = figure('NumberTitle', 'off', 'Name', 'Comp Ceilometro vs RS diurno');
    subplot(1,2,1);
    plot(betaPromediado, altura); % Perfil de backscattering promediado
    xlabel('beta (m^-^1 sr^-^1)');
    ylabel('altura (m)');
    ylim([0, 3000]);
    % Añadir niveles de Luftt de aerosoles
    if var(33).Datos(1, indice_horaRdia) ~= -1 % aerosol layer 1
        capa = var(33).Datos(1, indice_horaRdia);
        line(xlim,[capa, capa], 'Color', 'black', 'LineStyle', '--');
    end %if
    if var(33).Datos(2, indice_horaRdia) ~= -1 % aerosol layer 2
        capa = var(33).Datos(2, indice_horaRdia);
        line(xlim,[capa, capa], 'Color', 'red', 'LineStyle', '--');
    end %if  
    if var(33).Datos(3, indice_horaRdia) ~= -1 % aerosol layer 3
        capa = var(33).Datos(3, indice_horaRdia);
        line(xlim,[capa, capa], 'Color', 'blue', 'LineStyle', '--');
    end %if
    %Representar la temperatura potencial virtual
    ax1 = gca; % current axes
    ax1_pos = ax1.Position;
    ax2 = axes('Position',ax1_pos, 'XAxisLocation', 'top', 'YAxisLocation','right', 'Color','none');
    hold;
    plot(datosRS.THTV, datosRS.altitud - 638, 'Parent', ax2, 'Color', 'k'); % Temperatura potencial
    xlabel('Temp. pot. (ºK)');
    ylabel('altura (m)');
    ylim([0, 3000]);
    hold;
    
    subplot(1,2,2);
    plot(betaPromediado, altura); % Perfil de backscattering promediado
    xlabel('beta (m^-^1 sr^-^1)');
    ylabel('altura (m)');
    ylim([0, 10000]);
    % Añadir niveles de Luftt de nubes
    if var(41).Datos(1, indice_horaRdia) ~= -1 % Cloud base layer 1
        capa = var(41).Datos(1, indice_horaRdia);
        line(xlim,[capa, capa], 'Color', 'black', 'LineStyle', '-');
    end %if
    if var(41).Datos(2, indice_horaRdia) ~= -1 % Cloud base layer 2
        capa = var(41).Datos(2, indice_horaRdia);
        line(xlim,[capa, capa], 'Color', 'cyan', 'LineStyle', '-');
    end %if
    if var(41).Datos(3, indice_horaRdia) ~= -1 % Cloud base layer 3
        capa = var(41).Datos(3, indice_horaRdia);
        line(xlim,[capa, capa], 'Color', 'magenta', 'LineStyle', '-');
    end %if
    % Representar la humedad relativa
    ax3 = gca; % current axes
    ax3_pos = ax3.Position;
    ax4 = axes('Position',ax3_pos, 'XAxisLocation', 'top', 'YAxisLocation','right', 'Color','none');
    hold;
    % plot(datosRS.temp - datosRS.dwpt, datosRS.altitud - 638, 'Parent', ax4, 'Color', 'k'); % Diferencia Temp - Punto de Rocio
    plot(datosRS.RELH, datosRS.altitud - 638, 'Parent', ax4, 'Color', 'b'); % Relative Humidity
    xlabel('Humedad relativa (%)');
    ylabel('altura (m)');
    ylim([0, 10000]);
    hold;
    
end %if