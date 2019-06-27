function Heaty(cruise); 

clf

Meta = MetaFile(cruise);
meta = MetaInfo(cruise);

heat = load(Meta.HeatFile); %loads file made of data for this specific cruise

mSmoMin = min(min(heat.HeatImage)); %finds minimum of data for the purpose of the specialized colormap
mSmoMax = max(max(heat.HeatImage)); %finds maximum of data for the special colormap

ncolors = 2;  % number of colors between integers

vmax = max(abs(floor(mSmoMin)),abs(ceil(mSmoMax))); 
[brcmap, rlims, rticks, rbfncol, rctable] = cptcmap('GMT_Heat.cpt', 'mapping', 'direct', 'ncol' ,vmax*2*ncolors); %references colormap mfile downloaded and the GMT color file for this map

hold on
set(gca,'FontSize',20)
%title([ strrep(cruise,'_','\_'), ' Heat Flux (Large & Yeager 2009)'],'FontSize',20) %creates title
title('Heat Flux for 12881 & 12700 (Large & Yeager 2009)')

colormap(brcmap); %calls special colormap

set(gca,'YDir','normal'); %makes y values decrease in negative y direction
set(gca,'YLim',[meta.LatMin meta.LatMax]); % sets map y-limits to the Latitudes specified for your area
set(gca,'XLim',[meta.LonMin meta.LonMax]); %sets map x-limits to the Longitudes specified for your area
set(gca,'FontSize',19)

imagesc(heat.HeatLon,heat.HeatLat,heat.HeatImage) %makes the background to the map

h = colorbar; %makes colorbar
set(get(h,'label'),'string','(W m^-2)','FontSize',16) %labels colorbar
caxis([-80 20])

[L,m] = contour(heat.HeatLon,heat.HeatLat,heat.HeatImage,[-120:10:120],'Color','k'); %makes black contours
clabel(L,m,'LabelSpacing',200); %labels contours

%==================================================================
d = load('12700data.mat');

for row = 1:1:length(d.data.lat)    %loop through the positions in the file
    Latitude = d.data.lat;   %get Latitude variable
    Longitude = d.data.lon;  %get Longitude variable
    Flo = plot(Longitude(row),Latitude(row),'.','MarkerSize',Meta.MarkerSize,'LineWidth',4,'MarkerEdgeColor',[0 0 1]); 
end

Cruise = line(Longitude,Latitude,'LineWidth',2,'Color',[0 0 0.75]);


d2 = load('12881data.mat');

for row = 1:1:length(d2.data.lat)    %loop through the positions in the file
    Latitude2 = d2.data.lat;   %get Latitude variable
    Longitude2 = d2.data.lon;  %get Longitude variable
    Flo2 = plot(Longitude2(row),Latitude2(row),'.','MarkerSize',Meta.MarkerSize,'LineWidth',4,'MarkerEdgeColor',[1 0 0]); 
end

Lat = d.data.lat;   %get Latitude variable
Lon = d.data.lon;  %get Longitude variable
FloSpecial = plot(Lon(33),Lat(33),'.','MarkerSize',2*Meta.MarkerSize,'LineWidth',7,'MarkerEdgeColor',[0.45 0 0]);

Cruise2 = line(Longitude2,Latitude2,'LineWidth',2,'Color',[0.75 0 0]);

legend([Flo2 Flo FloSpecial],'12881 Float Traj','12700 Float Traj','Profile 17 of 12700','location','NorthEast')

%==================================================================


xlabel('Longitude','FontSize',16) %labels xaxis
ylabel('Latitude','FontSize',16) %labels yaxis

coast = load('coast'); %loads coast data
continent = geoshow('landareas.shp','FaceColor','black'); %shows the continents on the map

hold off