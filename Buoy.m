function Buoy(cruise); 

meta = MetaFile(cruise);
buoyancy = load(meta.BuoyancyFluxFile);

mSmoMin = min(min(-1*buoyancy.BuoyancyImage)); %finds minimum of data for the special colormap
mSmoMax = max(max(-1*buoyancy.BuoyancyImage)); %finds maximum of data for the special colormap

ncolors = 2;  % number of colors between integers

vmax = max(abs(floor(mSmoMin)),abs(ceil(mSmoMax))); 
[brcmap, rlims, rticks, rbfncol, rctable] = cptcmap('GMT_Buoyancy.cpt', 'mapping', 'direct', 'ncol' ,vmax*2*ncolors);


clf 


hold on
title([ strrep(cruise,'_','\_'), ' Buoyancy Flux (Large & Yeager 2009)']) %creates title for the plot

h = colorbar; %creates colorbar
set(get(h,'label'),'string','(W m^-2)','FontSize',16) %labels colorbar
caxis([-20 80])

colormap(brcmap) %calls the special colormap created above

set(gca,'YDir','normal'); %makes it so y values count down in the negative y direction
set(gca,'YLim',[meta.LatMin meta.LatMax]); % sets map y-limits to the Latitudes specified for your area
set(gca,'XLim',[meta.LonMin meta.LonMax]); %sets map x-limits to the Longitudes specified for your area
set(gca,'FontSize',19)

imagesc(buoyancy.BuoyancyLon,buoyancy.BuoyancyLat,(-1*buoyancy.BuoyancyImage)) %creates the map background from the data (the buoyancy itself needs to be multiplied by neg 1)

[L,m] = contour(buoyancy.BuoyancyLon,buoyancy.BuoyancyLat,(-1*buoyancy.BuoyancyImage),[-160:10:160],'Color','k'); %creates black contour of values
clabel(L,m,'LabelSpacing',200); %labels the contours

%INSERT CODE FOR STATIONS,FLOATS,TRACK BELOW THIS - choose from README code
%choose based on number of cruises per map

%==================================================================
d = load('12700data.mat');

for row = 1:1:length(d.data.lat)    %loop through the positions in the file
    Latitude = d.data.lat;   %get Latitude variable
    Longitude = d.data.lon;  %get Longitude variable
    Flo = plot(Longitude(row),Latitude(row),'.','MarkerSize',meta.MarkerSize,'LineWidth',4,'MarkerEdgeColor',[0 0 1]); 
end

Cruise = line(Longitude,Latitude,'LineWidth',2,'Color',[0 0 0.75]);


d2 = load('12881data.mat');

for row = 1:1:length(d2.data.lat)    %loop through the positions in the file
    Latitude2 = d2.data.lat;   %get Latitude variable
    Longitude2 = d2.data.lon;  %get Longitude variable
    Flo2 = plot(Longitude2(row),Latitude2(row),'.','MarkerSize',meta.MarkerSize,'LineWidth',4,'MarkerEdgeColor',[1 0 0]); 
end

Lat = d.data.lat;   %get Latitude variable
Lon = d.data.lon;  %get Longitude variable
FloSpecial = plot(Lon(33),Lat(33),'.','MarkerSize',2*meta.MarkerSize,'LineWidth',7,'MarkerEdgeColor',[0.45 0 0]);

Cruise2 = line(Longitude2,Latitude2,'LineWidth',2,'Color',[0.75 0 0]);

legend([Flo2 Flo FloSpecial],'12881 Float Traj','12700 Float Traj','Profile 17 of 12700','location','NorthEast')

%==================================================================


xlabel('Longitude','FontSize',16) %labels xaxis
ylabel('Latitude','FontSize',16) %labels yaxis

coast = load('coast'); %loads coast 
continent = geoshow('landareas.shp','FaceColor','black'); %maps the continents on the map

%legend([Cruise1 Cruise2 Flo1 Flo2 Stat],'Cruise Track Polarstern','Cruise Track Andrex','Float Locations','Float Locations','Station Locations','Location','Northwest') %change based on what files you got

hold off