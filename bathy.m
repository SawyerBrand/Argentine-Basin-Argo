function Bathy(cruise)   %call this function in command window with the area you want to plot
disp(['LatLonDep: ',cruise])

%   %closes all open figure windows 
%=========================================
meta = MetaInfo(cruise);   % load paths,file names, info for this cruise

% % these may be needed for previous cruises
% parts = strread(cruise,'%s','delimiter','_');
% year = parts{1};
% area = parts{2};

%below now in MetaInfo.m
%common_loc = '~/work/sogle_plots/common_files/';     % path to common soccom files
%SeaIceFile1 = 'nt_20060920_f13_v01_s.nc';       %greatest ice extent (change this depending on what sea ice file you want (this is September 20, 2006))
%SeaIceFile2 = 'nt_20060220_f13_v01_s.nc';       %lower ice extent (change this depending on what sea ice file you want (this is February 20, 2006))
%=========================================

%EDIT variables below
%If you want to add a new area add an elseif with this code:
%elseif strcmp(area,'your new area') 
%    Station = 'name of your station file'  %file must have 5 collums with
%        station number in the first collumn, latitude in the 3rd collumn,
%        and longitude in the 4th column (lat/lon in decimal form -180 to
%        180 form) 
%        text file
%        if there isn't a station file set Station to "false"
%    Floats = 'name of float file'       %file must have  at least 3 collumns with
%        float number in the first collumn,latitude in the 2nd collumn and
%        longitude in the 3rd collumn (lat/lon in decimal -180 to 180 form) 
%        text file
%        if you don't have a float file, then assign Floats to "false"
%    BathyFile = 'name of bathymetry file'   %file must be for the
%        specific location in .mat format with ocean depths as negative #s
%    LatMin = #; LatMax = #; LonMin = #; LonMax = #; (sets boundary for
%        graph (lat/lon must be in -180 to 180 scale/decimal form)
%    title('input any title you want')
%now call the function by typing LatLonDep('area') in your command window

hold on   %keep figure up throughout the script so that we can keep plotting awesome data over it!
title([ strrep(cruise,'_','\_'), ' Float Deployment'],'FontSize',16)
%title('Andrex II Float Deployment','FontSize',15)

Bath = load(meta.BathyFile);         %loads Bathymetry file for cruise specified above
Bathf = fields(Bath);           %gets the fields from the loaded Bathymetry file
BathFile = Bath.([Bathf{:}]);   %creates final bathfile

[numrows, numcols] = size(BathFile.z);  %finds the size of the depth part of the Bathymetry file and saves the number of rows/collumns
for r = 1:numrows        %double for loop goes through all of the data in the bath file
    for c = 1:numcols
        if (BathFile.z(r,c)) >= 0       %if the elevation is greater or equal to zero
            BathFile.z(r,c) = 51;      %set the elevation to 51 (the colorscale only colors it in as land if it is greater than 50 so this makes all the land colored in)
        end
    end
end


[ahomap,cblev] = AHO_gebco_matlab;      %makes the colormap the gebco map and assigns rgb color code values to ahomap and assigns depths to cblev
caxis([cblev(1) cblev(end)])            %makes the axis go from 100 (tan land color) to -6000 (dark blue)
cba = colorbar;                         %cba is our colorbar variable
% se added comments cba.Label.String = 'Depth (meters)';
set(cba,'YTick', cblev(1:end-1))        %set tick marks on cba to show depths from cblev (all except the last the land one (100): 0, -200, -500, -1000, -2000, -3000, -4000, -5000, -6000), these ticks correspond to changing color levels
colormap(ahomap)                        %makes the colormap use the ahomap rgb codes


[X,Y] = meshgrid(BathFile.x,BathFile.y);      %makes grid using longitudes and latitudes from the Bathymetry file
imagesc(BathFile.x,BathFile.y,BathFile.z');   %plots image using corresponding lon/lat and the depths from the Bathymetry file (rotated so that they match up correctly)
set(gca,'YDir','normal');        %gets handle of current axis (gca) and sets it to a normal y-direction
set(gca,'YLim',[meta.LatMin meta.LatMax]); % sets map y-limits to the Latitudes specified for your area
set(gca,'XLim',[meta.LonMin meta.LonMax]); % sets map x-limits to the Longitudes specified for you area
set(gca,'FontSize',16)

ncfname   = fullfile(meta.common_loc,meta.SeaIceFile1); %gets ice file by calling fullfile(FolderName,'FileName') and referring to variables specified at the top
ncid = netcdf.open(ncfname,'NC_NOWRITE');     %opens ice file so that you can't edit the file and assigns file to "ncid"
[numdims, numvars, numglobalatts, unlimdimID] = netcdf.inq(ncid);   %keeps track of netcdf variables
for i = 1:numvars                             %loops through variables
    [varnames{i}, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,i-1);   %saves variables
    Data.([varnames{i}]) = netcdf.getVar(ncid,i-1);   %finds what variables are and saves all of them into Data so that you can access them
end
netcdf.close(ncid);  %closes netcdf file
[numrows,numcols] = size(Data.longitude);  %finds size of longitude,latitude,and Ice Conc arrays (they will each be same size) and assigns those values to numrows and numcols
for r = 1:numrows  %double for loop goes through each row and collumn or Ice Concentration array
    for c = 1:numcols  %goes through all the collumns
        if (isnan(Data.IceConc(r,c)) == 1) || (Data.IceConc(r,c) == 0) %checks for NaN data and puts 0 in instead
            Data.IceConc(r,c)=0;
        elseif ((Data.longitude(r,c) > 180) && (Data.longitude(r,c) < 360)) == 1   %if longitude values are between 180 and 360 in the ice file, subtract 360 from them to make the value match up to our -180 to 180 scale
            Ice = plot(Data.longitude(r,c)-360, Data.latitude(r,c),'o','MarkerSize',4.5,'LineWidth',1,'MarkerEdgeColor',[0 1 1]); %plot where the ice is at the correct lat lon with cyan circles (keep middle of cirles clear so that you can see bathymetry levels) and assign to "ice" so that we can use in the legend
        else   %if the ice location is between 0 and 180 degrees east
            Ice = plot(Data.longitude(r,c), Data.latitude(r,c),'o','MarkerSize',4.5,'LineWidth',1,'MarkerEdgeColor',[0 1 1]); %plot where the ice is at the correct lat lon with cyan circles (keep middle of circles clear so that you can see bathymetry) and assign to "ice" so that we can use in legend
        end
    end
end

ncfname   = fullfile(meta.common_loc,meta.SeaIceFile2); %gets second ice file by calling fullfile(FolderName,'FileName') and referring to variables specified above
ncid = netcdf.open(ncfname,'NC_NOWRITE');     %opens ice file so that you can't edit the file and assigns file to "ncid"
[numdims, numvars, numglobalatts, unlimdimID] = netcdf.inq(ncid);  %keeps track of netcdf variables
for i = 1:numvars                                                  %loops through variables
    [varnames{i}, xtype, varDimIDs, varAtts] = netcdf.inqVar(ncid,i-1);    %saves variables
    Data.([varnames{i}]) = netcdf.getVar(ncid,i-1);   %finds what variables are and saves all of them into Data so that you can access them
end
netcdf.close(ncid);
[numrows,numcols] = size(Data.longitude);  %finds size of longitude,latitude,and Ice Conc arrays (they will each be same size) and assigns those values to numrows and numcols
for r = 1:numrows  %double for loop goes through each row and each collumn
    for c = 1:numcols
        if (isnan(Data.IceConc(r,c)) == 1) || (Data.IceConc(r,c) == 0) %checks for NaN data and puts 0 in instead
            Data.IceConc(r,c)=0;
        elseif ((Data.longitude(r,c) > 180) && (Data.longitude(r,c) < 360)) == 1    %if longitude values are between 180 and 360 in the ice file, subtract 360 from them to make the value match up to our -180 to 180 scale
            Feb = plot(Data.longitude(r,c)-360, Data.latitude(r,c),'^','MarkerSize',5,'LineWidth',.45,'MarkerEdgeColor',[0 0 1]); %plot where the ice is at the correct lat lon with a blue triangle (middle open so that you can see bathymetry) and assign to "Feb" so that we can use in legend
        else              %if longitude values for ice are between 0 and 180 east
            Feb = plot(Data.longitude(r,c), Data.latitude(r,c),'^','MarkerSize',5,'LineWidth',.45,'MarkerEdgeColor',[0 0 1]);    %plot where the ice is at the correct lat lon with blue triangle (middle open so that you can see bathymetry) and assign to "Feb so that we can use in legend
        end
    end
end


%==================================================================
d = load('6901814data.mat');

for row = 10:1:length(d.data.lat)    %loop through the positions in the file
    Latitude = d.data.lat;   %get Latitude variable
    Longitude = d.data.lon;  %get Longitude variable
    Flo = plot(Longitude(row),Latitude(row),'.','MarkerSize',meta.MarkerSize,'LineWidth',4,'MarkerEdgeColor',[1 0 0]); 
end

Cruise = line(Longitude(10:442),Latitude(10:442),'LineWidth',2,'Color',[0 0 1]);


d2 = load('6901814data.mat');

for row = 10:1:length(d2.data.lat)    %loop through the positions in the file
    Latitude2 = d2.data.lat;   %get Latitude variable
    Longitude2 = d2.data.lon;  %get Longitude variable
    Flo2 = plot(Longitude(row),Latitude(row),'.','MarkerSize',meta.MarkerSize,'LineWidth',4,'MarkerEdgeColor',[1 0 0]); 
end

Cruise2 = line(Longitude2(10:442),Latitude2(10:442),'LineWidth',2,'Color',[0 0 1]);


%==================================================================
%======================================================================================


SAF = load(fullfile(meta.common_loc,'saf.asc.txt'));                            %load Subantarctic Front file
plot(SAF(:,1),SAF(:,2),'-','Color',[.9 .87 .88],'LineWidth', 1.5)      %plot the longitude/latitude of this front in a tan color
% This code does not work:  see working code below commented lines
%for row = 1:80:length(SAF)                            %loop through length of SAF file so that you label every nth point (adjust n to make make more/less cluttered)
%    x = SAF(row,1);                                   %assign x to longitude of SAF
%    y = SAF(row,2);                                   %ssign y to latitude of SAF
%    if (x > (meta.LonMin+1) && x < (meta.LonMax-1)) && (y > (meta.LatMin+1) && y < (meta.LatMax-1))  %only add text if the text will stay inside the range of the map
%        text(x,y,'SAF','FontSize',8)                  %labels the fronts
%    end
%end
% use below instead
%    x = SAF(row,1);                                   %assign x to longitude of SAF
%    y = SAF(row,2);                                   %ssign y to latitude of SAF
ipos = find( (SAF(:,1) > (meta.LonMin+1)) & (SAF(:,1) < (meta.LonMax-1)) & (SAF(:,2) > (meta.LatMin+1)) & (SAF(:,2) < (meta.LatMax-1)));  %only add text if the text will stay inside the range of the map
text(SAF(ipos(1:40:end),1),SAF(ipos(1:40:end),2),'SAF','FontSize',8)  %label the front only once
clear ipos

SBDY = load(fullfile(meta.common_loc,'sbdy.asc.txt'));                           %load the southern boundary file
plot(SBDY(:,1),SBDY(:,2),'-','Color',[.9 .87 .88],'LineWidth', 1.5)     %plot the longitude/latitude of this in a tan color
%for row = 1:18:length(SBDY)                            %loop through length of SBDY file so that you label every nth point (adjust n to make make more/less cluttered)
%    x = SBDY(row,1);                                   %assign x to longitude of SBDY
%    y = SBDY(row,2);                                   %assign y to latitude of SBDY
%    if (x > (meta.LonMin+1) && x < (meta.LonMax-1)) && (y > (meta.LatMin+1) && y < (meta.LatMax-1))  %only add text if the text will stay inside the range of the map
%        text(x,y,'SBDY','FontSize',8)                  %add text
%    end
%end
ipos = find( (SBDY(:,1) > (meta.LonMin+1)) & (SBDY(:,1) < (meta.LonMax-1)) & (SBDY(:,2) > (meta.LatMin+1)) & (SBDY(:,2) < (meta.LatMax-1))) ; %only add text if the text will stay inside the range of the map
text(SBDY(ipos(1:40:end),1),SBDY(ipos(1:40:end),2),'SBDY','FontSize',8)  %label the front only once
clear ipos

STF = load(fullfile(meta.common_loc,'stf.asc.txt'));                              %loads Subtropical Front file (only appears on a few maps because it is farther north)
plot(STF(:,1),STF(:,2),'-','Color', [.9 .87 .88],'LineWidth', 1.5)       %plot the longitude/latitude of this in a tan color
%for row = 1:30:length(STF)                              %loop through length of STF file so that you label every nth point (adjust n to make make more/less cluttered)
%    x = STF(row,1);                                     %assign x to longitude of STF
%    y = STF(row,2);                                     %assign y to latitude of STF
%    if (x > (meta.LonMin+1) && x < (meta.LonMax-1)) && (y > (meta.LatMin+1) && y < (meta.LatMax-1))   %only add text if the text will stay inside the range of the map
%        text(x,y,'STF','FontSize',8)                    %add text
%    end
%end
ipos = find( (STF(:,1) > (meta.LonMin+1)) & (STF(:,1) < (meta.LonMax-1)) & (STF(:,2) > (meta.LatMin+1)) & (STF(:,2) < (meta.LatMax-1))) ; %only add text if the text will stay inside the range of the map
if ipos    
   text(STF(ipos(1:40:end),1),STF(ipos(1:40:end),2),'STF','FontSize',8)  %label the front only once
end
clear ipos

PF = load(fullfile(meta.common_loc,'pf.asc.txt'));                               %loads Polar Front file
plot(PF(:,1),PF(:,2),'-','Color',[.9 .87 .88],'LineWidth', 1.5)         %plot the longitude/latitude of this in a tan color
%for row = 1:90:length(PF)                              %loop through length of PF file so that you label every nth point (adjust n to make make more/less cluttered)
%    x = PF(row,1);                                     %assign x to longitude of STF file
%    y = PF(row,2);                                     %assign y to latitude of STF file
%    if (x > (meta.LonMin+1) && x < (meta.LonMax-1)) && (y > (meta.LatMin+1) && y < (meta.LatMax-1))  %only add text if the text will stay inside the range of the map
%        text(x,y,'PF','FontSize',8)                    %add text
%    end
%end
ipos = find( (PF(:,1) > (meta.LonMin+1)) & (PF(:,1) < (meta.LonMax-1)) & (PF(:,2) > (meta.LatMin+1)) & (PF(:,2) < (meta.LatMax-1)));  %only add text if the text will stay inside the range of the map
text(PF(ipos(1:40:end),1),PF(ipos(1:40:end),2),'PF','FontSize',8)  %label the front 
clear ipos

SACCF = load(fullfile(meta.common_loc,'saccf.asc.txt'));                        %load the Southern Atlantic Circumpolar Current Front file
plot(SACCF(:,1),SACCF(:,2),'-','Color',[.9 .87 .88],'LineWidth', 1.5)  %plot the longitude/latitude of this front in a tan color
%for row = 1:25:length(SACCF)                          %loop through length of SACCF file so that you label every nth point (adjust n to make make more/less cluttered)
%    x = SACCF(row,1);                                 %assign x to longitude of SACCF
%    y = SACCF(row,2);                                 %assign y to latitude of SACCF
%    if (x > (meta.LonMin+1) && x < (meta.LonMax-1)) && (y > (meta.LatMin+1) && y < (meta.LatMax-1))     %only add text if the text will stay inside the range of the map
%        text(x,y,'SACCF','FontSize', 8)               %labels the fronts
%    end
%end
ipos = find( (SACCF(:,1) > (meta.LonMin+1)) & (SACCF(:,1) < (meta.LonMax-1)) & (SACCF(:,2) > (meta.LatMin+1)) & (SACCF(:,2) < (meta.LatMax-1))) ; %only add text if the text will stay inside the range of the map
text(SACCF(ipos(1:40:end),1),SACCF(ipos(1:40:end),2),'SACCF','FontSize',8)  %label the front only once
clear ipos

contour(BathFile.x,BathFile.y,BathFile.z',[0 0],'Color','k')                  % outline the coasts with black contour by accessing Bathymetry file lon/lat/dep
[L,m] = contour(BathFile.x,BathFile.y,BathFile.z',[-2000 -2000],'Color','k'); % -2000m isobath (farthest floats go to) black countour and assign lon/lat positions to L/M
clabel(L,m,'LabelSpacing',200);                                               %label contour with "2000" every nth datapoint

ylabel('Latitude(degrees)','FontSize',16)    %add y label for Latitude
xlabel('Longitude(degrees)','FontSize',16)   %add x label for Longitude



% if  strcmp(area,'OOI')      %if your area is OOI
%     legend([Ice Feb More Flo], 'Ice on September 20, 2006', 'Ice on February 20, 2006','Station Locations','Mooring','Proposed Floats','Location','Northwest')  %add legend
% elseif strcmp(area,'CSIRO') %if your area is CSIRO
%     legend([Ice Feb Flo], 'Ice on September 20, 2006', 'Ice on February 20, 2006','Proposed Floats','Location','Northwest')  %add legend
if (StationF == true) && (Floaty == true)   %RIGHT ONE
    legend([Ice Feb Flo Stat],'Ice on September 20, 2006', 'Ice on February 20, 2006','Float Locations','Station Locations','Location','Northeast')%add legend
elseif StationF == true       %if area has only a Station File
    legend([Ice Feb Stat],'Ice on September 20, 2006', 'Ice on February 20, 2006','Float Locations','Location','Northwest')  %add legend with location of legend as Northeast so that it doesn't cover the floats
elseif Floaty == true         %if area only has a Proposed float file
     legend([Ice Feb Flo],'Ice on September 20, 2006', 'Ice on February 20, 2006','Float Drop Location','Location','Northwest')
else       %if area does NOT have a float or a station file (only bathymetry/ice)
    legend(Ice,'Ice on September 20, 2006', 'Location','Northeast') %add legend for ice
end

%legend([Cruise Cruiset],'12881 Float Traj','12700 Float Traj')

hold off    %we are done plotting
