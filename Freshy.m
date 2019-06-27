function Freshy(cruise); 

clf

Meta = MetaFile(cruise); %links to meta file
meta = MetaInfo(cruise);

Water = load(Meta.FreshWaterFile); %loads file created for this cruise

mSmoMin = min(min(Water.FreshWaterImage)); %finds minimum of freshwater data for special colormap
mSmoMax = max(max(Water.FreshWaterImage)); %finds maximum of freshwater data for special colormap

ncolors = 2;  % number of colors between integers

vmax = max(abs(floor(mSmoMin)),abs(ceil(mSmoMax)));
[brcmap, rlims, rticks, rbfncol, rctable] = cptcmap('GMT_Fresh.cpt', 'mapping', 'direct', 'ncol' ,vmax*2*ncolors);

hold on
title([ strrep(cruise,'_','\_'), ' Fresh Water Flux (Large & Yeager 2009)']) %creates title

set(gca,'FontSize',16)
colormap(brcmap); %links to special colormap created above

h = colorbar; %creates colorbar
set(get(h,'label'),'string','(W m^-2)','FontSize',16) %labels colorbar
caxis([-20 40])

set(gca,'YDir','normal'); %makes y values decrease in negative y direction
set(gca,'YLim',[Meta.LatMin Meta.LatMax]); % sets map y-limits to the Latitudes specified for your area
set(gca,'XLim',[Meta.LonMin Meta.LonMax]); %sets map x-limits to the Longitudes specified for your area
set(gca,'FontSize',19)

imagesc(Water.FreshWaterLon,Water.FreshWaterLat,Water.FreshWaterImage) %creates actual background image

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

[L,m] = contour(Water.FreshWaterLon,Water.FreshWaterLat,Water.FreshWaterImage,[-160:10:160],'Color','k'); %creates black contours
clabel(L,m,'LabelSpacing',200); %labels contours


xlabel('Longitude','FontSize',16) %labels xaxis
ylabel('Latitude','FontSize',16) %labels yaxis

coast = load('coast'); %loads coastline data
continent = geoshow('landareas.shp','FaceColor','black'); %shows continent on map


hold off