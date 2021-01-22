% Funcion para localizar tres capas de nubes y tres de aerosoles y
% compararlos con los valores que proporciona el ceilometro de Lufft

% Trabajo de Cristina Gil, Practicas de Empresa 2020
% contribuciones de Ruben Barragan y Francisco Molero
function [Clouds_3layer, Aerosols_3layer] = searchCloudsAndAerosols(var)
    fechasNum = 695422 + var(1).Datos/(24 * 60 * 60);
    horas = fechasNum - floor(fechasNum(1));
    altura = var(2).Datos;
    betas = var(28).Datos;
    Clouds_3layer = -1*ones(length(horas), 3);
    Aerosols_3layer = -1*ones(length(horas), 3);
    
    % Bucle que recorre todas las horas del fichero
    PerfilesApromediar = 20; % 300 segundos (5 minutos), como dice el manual
    for queHora = 1:length(horas)  
        if queHora < floor(PerfilesApromediar/2) + 1 % los primeros 20 perfiles (5 minutos * perfil/15s) se promedian entre el 1 y 40, 10 minutos
            meanBeta = mean(betas(:, 1:PerfilesApromediar), 2);
            stdBeta = std(betas(:, 1:PerfilesApromediar), 0, 2);
        elseif queHora > (length(horas) - floor(PerfilesApromediar/2)) % los últimos 20 perfiles se promedian entre el ultimo - 40 y el ultimo, 10 minutos
            meanBeta = mean(betas(:, (length(horas) - floor(PerfilesApromediar/2)):end), 2);
            stdBeta = std(betas(:, (length(horas) - floor(PerfilesApromediar/2)):end), 0, 2);
        else % En otro caso, se toman 20 perfiles a cada lado
            meanBeta = mean(betas(:, (queHora - floor(PerfilesApromediar/2)):(queHora + floor(PerfilesApromediar/2))), 2);
            stdBeta = std(betas(:, (queHora - floor(PerfilesApromediar/2)):(queHora + floor(PerfilesApromediar/2))), 0, 2);
        end %if
        
        % Nubes
        if var(41).Datos(1, queHora) ~= -1 % Si el perfil ha identificado una nube al menos
            % Tratamiento de la señal con el algoritmo de Martucci
            meanGS = (-1)*gradient(meanBeta); 
            stdGS = gradient(stdBeta);
            SNRBeta = meanBeta./stdBeta;
            SNRGS = meanGS./stdGS;
%             maxima_meanGS = islocalmax(meanGS);
%             maxima_meanBeta = islocalmax(meanBeta);
%             figure;
%             plot(SNRBeta, altura);
%             plot(SNRGS, altura);
            criterio = SNRBeta > 1 & meanBeta > 3e5; % SNRBeta > 1
            if length(find(criterio == 1)) == 1
                Clouds_3layer(queHora, 1) = altura(criterio);
            elseif length(find(criterio == 1)) == 2
                Clouds_3layer(queHora, 1) = altura(altura == min(altura(criterio)));
                Clouds_3layer(queHora, 2) = altura(altura == max(altura(criterio)));
            elseif length(find(criterio == 1)) == 3
                indicesCriterio = find(criterio == 1);
                Clouds_3layer(queHora, 1) = altura(indicesCriterio(1));
                Clouds_3layer(queHora, 2) = altura(indicesCriterio(2));
                Clouds_3layer(queHora, 3) = altura(indicesCriterio(3));
            end %if            
%             figure;
%             subplot(1,2,1);
%             plot(meanBeta, altura, meanBeta(maxima_meanBeta), altura(maxima_meanBeta),'r*', meanBeta(criterio), altura(criterio),'b+');
%             xlabel('Betas (m^-^1 sr^-^1)');
%             ylabel('Altura (m)');
%             legend('promedio Beta', 'máximos locales');
%             subplot(1,2,2);
%             plot(meanGS, altura, meanGS(maxima_meanGS), altura(maxima_meanGS),'r*');
%             xlabel('GS');
%             ylabel('Altura (m)');
%             legend('promedio GS', 'máximos locales');
            % Fin del Tratamiento de la señal
        end %if 
        
        % Aerosoles
        dilation = 20; % Anchura del Wavelet
        if var(33).Datos(1, queHora) ~= -1 % Si el perfil ha identificado una capa de aerosoles al menos
            if var(33).Datos(2, queHora) ~= -1 % Si el perfil ha identificado una segunda capa de aerosoles
                if var(33).Datos(2, queHora) ~= -1 % Si el perfil ha identificado una segunda capa de aerosoles
                    numberLayers = 3;
                else
                    numberLayers = 2;
                end %if
            else
                numberLayers = 1;
            end %if
            % Tratamiento de la señal con la función calcularMLH
            indice100m = find(altura > 100, 1);
            indice5Km = find(altura > 5000, 1);
            Aerosols_3layer(queHora, 1:3) = CalcularMLH(meanBeta(indice100m:indice5Km), altura(indice100m:indice5Km), dilation, numberLayers);
        end %if
    end %for
