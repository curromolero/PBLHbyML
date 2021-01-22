% Representa diferentes perfiles del ceilometro para comparar los valores
% de las capas que proporciona el equipo con los valores de backscattering 
% Representacion de los datos del Ceilometro, ficheros diarios
cd('\\cendat2\lidar\CeilometroLufft_CHM15k\Datos');
[nombreFichero, directorio] = uigetfile('*_CHM190148_*.nc','Seleccione el fichero que se desea representar');
[dim, attGlobales, var] = abrirFicheroNC_EARLINET(fullfile(directorio, nombreFichero));

% Representar la siguiente hora, en formato 0-1: 24h:
horaRepresentar = 5.05/24;

if ~isempty(directorio)
    fechasNum = 695422 + var(1).Datos/(24 * 60 * 60);
    horas = fechasNum - floor(fechasNum(1));
    altura = var(2).Datos;
    betas = var(28).Datos;
    tablaBetasAerosoles = zeros(length(horas), 9);
    tablaBetasNubes = zeros(length(horas), 9);
    for queHora = 21:length(horas) % Bucle que recorre todas las horas (A partir del minuto 5 (21 * 15s)) del fichero 
        % if horas(queHora) < horaRepresentar && horas(queHora) + 15/(24*60*60) >= horaRepresentar
        if var(41).Datos(1, queHora) ~= -1
            % Tratamiento de la señal: Promedio temporal de 10 minutos y derivada del logaritmo
            betaPromediado = mean(var(28).Datos(:, (queHora - 20):(queHora + 20)), 2);
            errorBetaPromediado = std(var(28).Datos(:, (queHora - 20):(queHora + 20)), 0, 2);
            SNR_beta = betaPromediado./errorBetaPromediado;
            plot(SNR_beta, altura); % SNRº
            GS = diff(log(var(28).Datos(:, (queHora - 20):(queHora + 20))))./diff(altura);
            prom_der_log = mean(GS, 2);
            der_log_Promediado = diff(log(betaPromediado))./diff(altura);
            plot(der_log_Promediado, altura(1:(length(altura)-1))); % Perfil de la derivada del logaritmo
            hold;
            plot(prom_der_log, altura(1:(length(altura)-1))); % Perfil de la derivada del logaritmo
            hold; % Solo son iguales al principio
            % Fin del Tratamiento de la señal
            
            
            [MLH_deriv, MLH_WCT_PrimerMaximo, MLH_WCT_PrimerMaximo_Err, MLH_WCT_MasIntenso, MLH_WCT_MasIntenso_Err] = CalcularMLH(betaPromediado, altura, 1);
            
            figurePerfil = figure;
            plot(betas(:, queHora), altura); % Perfil de backscattering
            hold;
            plot(betaPromediado, altura); % Perfil de backscattering promediado
            hold;
            if var(33).Datos(1, queHora) ~= -1 % aerosol layer 1
                capa = var(33).Datos(1, queHora);
                line(xlim,[capa, capa], 'Color', 'black', 'LineStyle', '--');
                hold on;
                scatter(betas(find(altura - double(capa) < 0, 1, 'last'), queHora), capa, [], 'o', 'black');
                hold off;
            end %if
            if var(33).Datos(2, queHora) ~= -1 % aerosol layer 2
                capa = var(33).Datos(2, queHora);
                line(xlim,[capa, capa], 'Color', 'red', 'LineStyle', '--');
                hold on;
                scatter(betas(find(altura - double(capa) < 0, 1, 'last'), queHora), capa, [], 'o', 'red');
                hold off;
            end %if  
            if var(33).Datos(3, queHora) ~= -1 % aerosol layer 3
                capa = var(33).Datos(3, queHora);
                line(xlim,[capa, capa], 'Color', 'blue', 'LineStyle', '--');
                hold on;
                scatter(betas(find(altura - double(capa) < 0, 1, 'last'), queHora), capa, [], 'o', 'blue');
                hold off;
            end %if
            if var(41).Datos(1, queHora) ~= -1 % Cloud base layer 1
                capa = var(41).Datos(1, queHora);
                line(xlim,[capa, capa], 'Color', 'black', 'LineStyle', '-');
                hold on;
                scatter(betas(find(altura - double(capa) < 0, 1, 'last'), queHora), capa, [], 'o', 'black');
                hold off;
            end %if
            if var(41).Datos(2, queHora) ~= -1 % Cloud base layer 2
                capa = var(41).Datos(2, queHora);
                line(xlim,[capa, capa], 'Color', 'cyan', 'LineStyle', '-');
                hold on;
                scatter(betas(find(altura - double(capa) < 0, 1, 'last'), queHora), capa, [], 'o', 'cyan');
                hold off;
            end %if
            if var(41).Datos(3, queHora) ~= -1 % Cloud base layer 3
                capa = var(41).Datos(3, queHora);
                line(xlim,[capa, capa], 'Color', 'magenta', 'LineStyle', '-');
                hold on;
                scatter(betas(find(altura - double(capa) < 0, 1, 'last'), queHora), capa, [], 'o', 'magenta');
                hold off;
            end %if
        end %if
        if var(33).Datos(1, queHora) ~= -1
            tablaBetasAerosoles(queHora, 1) = altura(find(altura - double(var(33).Datos(1, queHora)) < 0, 1, 'last'));
            tablaBetasAerosoles(queHora, 2) = betas(find(altura - double(var(33).Datos(1, queHora)) < 0, 1, 'last'), queHora);
            tablaBetasAerosoles(queHora, 3) = betas(find(altura - double(var(33).Datos(1, queHora)) > 0, 1 ), queHora);
        end %if
        if var(33).Datos(2, queHora) ~= -1
            tablaBetasAerosoles(queHora, 4) = altura(find(altura - double(var(33).Datos(2, queHora)) < 0, 1, 'last'));
            tablaBetasAerosoles(queHora, 5) = betas(find(altura - double(var(33).Datos(2, queHora)) < 0, 1, 'last'), queHora);
            tablaBetasAerosoles(queHora, 6) = betas(find(altura - double(var(33).Datos(2, queHora)) > 0, 1 ), queHora);
        end %if
        if var(33).Datos(3, queHora) ~= -1
            tablaBetasAerosoles(queHora, 7) = altura(find(altura - double(var(33).Datos(3, queHora)) < 0, 1, 'last'));
            tablaBetasAerosoles(queHora, 8) = betas(find(altura - double(var(33).Datos(3, queHora)) < 0, 1, 'last'), queHora);
            tablaBetasAerosoles(queHora, 9) = betas(find(altura - double(var(33).Datos(3, queHora)) > 0, 1 ), queHora);
        end %if
        if var(41).Datos(1, queHora) ~= -1
            tablaBetasNubes(queHora, 1) = altura(find(altura - double(var(41).Datos(1, queHora)) < 0, 1, 'last'));
            tablaBetasNubes(queHora, 2) = betas(find(altura - double(var(41).Datos(1, queHora)) < 0, 1, 'last'), queHora);
            tablaBetasNubes(queHora, 3) = betas(find(altura - double(var(41).Datos(1, queHora)) > 0, 1 ), queHora);
        end %if
        if var(41).Datos(2, queHora) ~= -1
            tablaBetasNubes(queHora, 4) = altura(find(altura - double(var(41).Datos(2, queHora)) < 0, 1, 'last'));
            tablaBetasNubes(queHora, 5) = betas(find(altura - double(var(41).Datos(2, queHora)) < 0, 1, 'last'), queHora);
            tablaBetasNubes(queHora, 6) = betas(find(altura - double(var(41).Datos(2, queHora)) > 0, 1 ), queHora);
        end %if
        if var(41).Datos(3, queHora) ~= -1
            tablaBetasNubes(queHora, 7) = altura(find(altura - double(var(41).Datos(3, queHora)) < 0, 1, 'last'));
            tablaBetasNubes(queHora, 8) = betas(find(altura - double(var(41).Datos(3, queHora)) < 0, 1, 'last'), queHora);
            tablaBetasNubes(queHora, 9) = betas(find(altura - double(var(41).Datos(3, queHora)) > 0, 1 ), queHora);
        end %if
    end %for 
% Estudio de aerosoles
figure;
plot(horas, tablaBetasAerosoles(:, 1), '.k', horas, tablaBetasAerosoles(:, 4), '.r', horas, tablaBetasAerosoles(:, 7), '.b');
plot(horas, tablaBetasAerosoles(:, 2), '.k', horas, tablaBetasAerosoles(:, 5), '.r', horas, tablaBetasAerosoles(:, 8), '.b');
plot(horas, tablaBetasAerosoles(:, 3), '.k', horas, tablaBetasAerosoles(:, 6), '.r', horas, tablaBetasAerosoles(:, 9), '.b');
% Estudio de nubes
plot(horas, tablaBetasNubes(:, 1), '.k', horas, tablaBetasNubes(:, 4), '.c', horas, tablaBetasNubes(:, 7), '.m'); 
plot(horas, tablaBetasNubes(:, 2), '.k', horas, tablaBetasNubes(:, 5), '.c', horas, tablaBetasNubes(:, 8), '.m');
plot(horas, tablaBetasNubes(:, 3), '.k', horas, tablaBetasNubes(:, 6), '.c', horas, tablaBetasNubes(:, 9), '.m');
plot(horas, tablaBetasNubes(:, 3) - tablaBetasNubes(:, 2), '.k', horas, tablaBetasNubes(:, 6) - tablaBetasNubes(:, 5), '.c', horas, tablaBetasNubes(:, 9) - tablaBetasNubes(:, 8), '.m');
end %if