function hSkewT = representarSkewTlogP(presionRS, temperaturaRS, altitudRS, dwptRS, drctRS, skntRS, RELHRS)
% representa un grafico skewTlogP con el sondeo
    %initialize
    g=9.80665; M=0.0289644; R=8.31447; L=0.0065; ex_10=(R*L)/(g*M);
    pz=presionRS;
    tz=temperaturaRS;
    rhz=RELHRS/100;
    tdz=dwptRS;
    nk=length(presionRS); %needed for cape calculation
    %altz=(1-(pz/1013.25).^ex_10)*(tz(find(min(pz)))+273.15)/L;
    altz = altitudRS;
    tskew(pz,tz,rhz); hold on
    wsp=skntRS/0.514; %knots 2 m/s
    wdir=drctRS;

    % filter windvelocity and direction
    wsp=filter(ones(round(size(wsp,1)/20),1)/round(size(wsp,1)/20),1,wsp);
    wdir=filter(ones(round(size(wdir,1)/20),1)/round(size(wdir,1)/20),1,wdir);
    pzf=filter(ones(round(size(pz,1)/20),1)/round(size(pz,1)/20),1,pz);
    pzff=flipud(pzf(1:round(size(pzf,1)/20):size(pzf,1)));
    wspf=wsp(1:round(size(wsp,1)/20):size(wsp,1));
    wdirf=wdir(1:round(size(wdir,1)/20):size(wdir,1));
    latx=ones(size(wspf,1),1);
    x_loc=40; % note change x_loc value accordingly -
              % it will plot the windbarb vertically at 40 C on the x-axis

%     for i=1:size(wspf,1)
%         windbarb(latx(i)*x_loc,pzff(i),wspf(i),wdirf(i),0.02, 3,'k'); 
%     end

    if 0
    alttick=(1-([100:100:1000]/1013).^ex_10)*(tz(find(min(pz)))+273.15)/L/1000;
    set(gca,'Box','off');
    axesPosition = get(gca,'Position');    
    hNewAxes = axes('Position',axesPosition,...  %# Place a new axes on top...
                    'Color','none',...           %#   ... with no background color
                    'YLim',[min(alttick) max(alttick)],...            %#   ... and a different scale
                    'YAxisLocation','right',...  %#   ... located on the right
                    'XTick',[],...               %#   ... with no x tick marks
                    'Box','off',...
                    'fontweight','bold');                %#   ... and no surrounding box
    ylabel(hNewAxes,'Altitude (km)','fontweight','bold');
    end
        % fin skew_sounding