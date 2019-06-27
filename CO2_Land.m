function CO2_Land(cruise)  %creates function for reference

% this function read a averaged (meaned) CO2 flux density file, typically output from 
% CO2_annual_mean_Landschutzer.m
%  loads as 
%	c = 
%	
%	                           seamask: [360x180 int32]
%	                               lat: [180x1 single]
%	                               lon: [360x1 single]
%	         fgco2_raw_Mean_2005to2015: [360x180 single]
%	    fgco2_smoothed_Mean_2005to2015: [360x180 single]
%
% NOTE:  the smoothed and raw files are very similar when meaned between 2005 and 2015
% 	Therefore,  the raw plots ( world and area, in blue-red) will be saved.  Other
%	plots made are commentd out, but remain in the code for reference if needed.
%	To comment in the plots,  remove "%p" from the beginning of lines.  Lines
%	not starting with "%p" are actual comments in the code.
%
% DONE
% 2018-08-16; in matlab ran 
%       >>  CO2_annual_mean_Landschutzer('spco2_1982-2015_MPI_SOM-FFN_v2016.nc');
%       to get the file spco2_mean_2005-2015_MPI_SOM-FFN_v2016.mat to use in CO2_Landschutzer.m


%
% cruise='2019_AMT28'  % testing
%addpath ../../mfiles  % testing


Meta = MetaFile(cruise);  %links to metainfo so we can call variables, etc from other mfiles

meta = MetaInfo(cruise);

%*****
% also check out
%https://blogs.mathworks.com/steve/2016/04/25/clim-caxis-imshow-and-imagesc/
%
% use a GMT .cpt file for the color map and ticks
%  from https://www.mathworks.com/matlabcentral/fileexchange/28943-color-palette-tables-cpt-for-matlab
% for GMT cpt colormapping
addpath([meta.top_loc,'/mfiles/cpt_matlab/kakearney-cptcmap-pkg-845bf83/cptcmap']);
addpath([meta.top_loc,'/mfiles/cpt_matlab/kakearney-cptcmap-pkg-845bf83/parsepv']);
addpath([meta.top_loc,'/mfiles/cpt_matlab/kakearney-cptcmap-pkg-845bf83/cptcmap/cptfiles']);
addpath([meta.common_loc]);  %for the file GMT_CO2.cpt
%*****

% load Meaned CO2 file
c = load(fullfile(meta.common_loc,Meta.CO2));

% find min, max of the M(eaned) file
% raw
mRawMin = min(min(c.fgco2_raw_Mean_2005to2015));
mRawMax = max(max(c.fgco2_raw_Mean_2005to2015));
disp([ 'World RAW Mean  min: ' num2str(mRawMin) ';  max: ' num2str(mRawMax)])
% smoothed
mSmoMin = min(min(c.fgco2_smoothed_Mean_2005to2015));
mSmoMax = max(max(c.fgco2_smoothed_Mean_2005to2015));
disp([ 'World SMOOTHED Mean  min: ' num2str(mSmoMin) ';  max: ' num2str(mSmoMax)])

%============================
% pull out data for date and area

if any(c.lon>180)
    disp('Error:  longitudes in meta file do not match lons in CO2 file (-180 to 180)' );
    keyboard;
end

% find index to area
ialat = find(c.lat>Meta.LatMin & c.lat<Meta.LatMax);
ialon = find(c.lon>Meta.LonMin & c.lon<Meta.LonMax);

% area position
alat = c.lat(ialat);
alon = c.lon(ialon);

% select area data
aflraw = c.fgco2_raw_Mean_2005to2015(ialon,ialat);
aflsmo = c.fgco2_smoothed_Mean_2005to2015(ialon,ialat);

%============================

%% keep null/missing values at nan for now,  for clean plotting comparisons
%mflraw(find(isnan(wflraw))) = 20;  
%mflsmo(find(isnan(wflsmo))) = 20;  
%
disp('Warning:  changing null values to NaNs,  which will be interpolated near coasts and other areas');
%%aflraw(find(isnan(aflraw))) = 20;  
%%aflsmo(find(isnan(aflsmo))) = 20;  
%
%============================

% make a colormap from -x to x.  Need this to make 0 at the middle
% GMT_CO2_blue goes from -18 to  0, but we are using GMT just for color
% GMT_CO2_red  goes from   1 to 18, but we are using GMT just for color
% GMT_CO2 is red and blue,  choose number of colors

% make ncol color GMT colormap, 2 red for each integer>0, 2 blue for each integer<0 
ncolors = 2;  % number of colors between integers

vmax = max(abs(floor(mSmoMin)),abs(ceil(mSmoMax)));
[brcmap, rlims, rticks, rbfncol, rctable] = cptcmap('GMT_CO2', 'mapping', 'direct', 'ncol' ,vmax*2*ncolors);


% Area plot with blue-red colormap
clf;

hold on

imagesc(alon,alat,aflraw');   % must transpose
set(gca,'YDir','normal');  % set to a normal y-direction
set(gca,'YLim',[Meta.LatMin Meta.LatMax]); % sets map y-limits to the Latitudes specified for your area
set(gca,'XLim',[Meta.LonMin Meta.LonMax]);
set(gca,'FontSize',16)

[L,m] = contour(alon,alat,aflraw',[-3:1:3],'Color','k');
clabel(L,m,'LabelSpacing',200);

%daspect([1,1,1]);
title(gca, [strrep(cruise,'_','\_') ': Landschutzer CO2 flux density, meaned, raw, 2005-2015'],'FontSize',16)
colormap(brcmap);
set(gca,'CLim',[vmax*-1 vmax]);
%set(gca,'FontSize',18);
ax = gca;
ax.FontSize = 16;
hc = colorbar('YTICK',[(vmax*-1):1:(vmax)]);
geoshow('landareas.shp','FaceColor','black');  % takes a while,  but easy proga
%print('-dpng',fullfile(Meta.top_loc,cruise,['Landschutzer_BlueRed_Mean_raw_' cruise '.png']));


ylabel('Degree Longitude','FontSize',16)
xlabel('Degree Latitude','FontSize',16)
h = colorbar; 
set(get(h,'label'),'string','umol/m2/y','FontSize',16)


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

hold off