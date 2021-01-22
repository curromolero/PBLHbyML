function [WCT] = wavelet(vector, a)
% vector = perfil al que quieres aplicar la WCT
% a      = dilación
% WCT    = wavelet covariance transform de vector
try
    filter = [ones(round(a/2),1);-ones(round(a/2),1)];
    WCT_temp = -(1/a)*conv(vector,filter);
    WCT = WCT_temp(round(a/2):round(a/2)+length(vector)-1);
catch exception
    if (strcmp(exception.identifier,'MATLAB:catenate:dimensionMismatch'))
        msg = ['Dimension mismatch occurred: First argument has ', ...
            num2str(size(vector,2)),' columns while second has ', ...
            num2str(size(filter,2)),' columns.'];
        causeException = MException('MATLAB:myCode:dimensions',msg);
        exception = addCause(exception,causeException);
   end
   WCT = NaN;
end

