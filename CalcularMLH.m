function [MLH_WCT] = CalcularMLH(AveragedRCS, ejeY, dilation, numberLayers)
% Calcular Mixing Layer Height mediante Wavelet Covariance Transform
% modificado por Curro, 31/03/2020, sobre la función CalcularMLH 

MLH_WCT = -1*ones(1, 3);
% Método de Wavelet Covariance Transform
WCT = wavelet(AveragedRCS, dilation);
[locs, pks]=peakseek(WCT, dilation);
if ~isempty(locs)
    % Tres primeros máximos desde superficie
    if length(locs) == 1 
        MLH_WCT(1, 1) = ejeY(locs(1));
    elseif length(locs) == 2
        MLH_WCT(1, 1:2) = ejeY(locs(1:2));
    else
        MLH_WCT(1, 1:numberLayers) = ejeY(locs(1:numberLayers));
    end %if
    % Pico más intenso y los dos siguientes
%     maxPks = find(pks == max(pks));
%     if maxPks + 1 > length(locs) 
%         MLH_WCT(1, 1) = ejeY(locs(maxPks));
%     elseif maxPks + 2 > length(locs)
%         MLH_WCT(1, 1:(numberLayers - 1)) = ejeY(locs(maxPks:(maxPks + numberLayers - 2)));
%     else
%         MLH_WCT(1, 1:numberLayers) = ejeY(locs(maxPks:(maxPks + numberLayers - 1)));
%     end %if
end %if