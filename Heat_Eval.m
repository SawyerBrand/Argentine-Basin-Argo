%% data processing from the .nc file to a mat file, which is interpolated
function data = process_argo(fn)
  
        outfile = '12700.mat';
        addpath(genpath('/Volumes/SOCCOM/Old_Research/GSW/Toolbox...'));

        % Read the variables in the netcdf (.nc) file and save in struct
        ncid = netcdf.open(fn,'NC_NOWRITE');
        [~, numvars, ~, ~] = netcdf.inq(ncid);
        for i = 1:numvars
             varname = netcdf.inqVar(ncid,i-1);
            raw_data.(varname) = netcdf.getVar(ncid,i-1);
        end

        data = struct();
        data.raw = raw_data; %retain raw data for future referece
        t = raw_data.REFERENCE_DATE_TIME';
        ref_t = [t(1:4) '-' t(5:6) '-' t(7:8) ' ' t(9:10) ':' t(11:12) ':' t(13:14)];
        data.time = datetime(ref_t) + days(raw_data.JULD);

        data.lat  = raw_data.LATITUDE;
        data.lon  = raw_data.LONGITUDE;
        data.P  = raw_data.PRES'; %chose to use the nonadjusted vairables because they had all values of 99999
        data.T  = raw_data.TEMP';
        data.SP  = raw_data.PSAL';
        data.DO  = raw_data.DOXY';

        % missing data
        data.P(data.P >= 900) = NaN;
        data.T(data.T >= 900) = NaN;
        data.SP(data.SP >= 900) = NaN;
        data.DO(data.DO >= 900) = NaN;
        zint = 1:1:500;
        
          % depth
          data.z = gsw_z_from_p(data.P, data.lat);

          % absolute salinity
          [data.sa, data.sstar, data.in_ocean] = gsw_SA_Sstar_from_SP(data.SP, data.P, data.lon, data.lat);

          % potential temperature
          data.pt = gsw_pt_from_t(data.sa, data.T, data.P, 0);

          % conservative temperature
          data.ct = gsw_CT_from_t(data.sa, data.T, data.P);

          % potential density
          data.pden = gsw_rho(data.sa, data.ct, 0);

          % in situ density
          data.rho = gsw_rho(data.sa, data.ct, data.P);

          % brunt-väisälä frequency
          [data.N2, data.p_mid] = gsw_Nsquared(data.sa, data.ct, data.P, data.lat);
        
        data.P = double(data.P(isfinite(data.P)));
        data.T = double(data.T(isfinite(data.T)));
        data.SP = data.SP(isfinite(data.SP));
        data.DO = data.DO(isfinite(data.DO));
        
        
        
        
        for i = 1:1:size(data.T,1)
        
            gdata.T = interp1(data.P(1,:),data.T(1,:),zint)
%             gdata.P(i,:) = interp1(data.P(i,:),data.P(i,:),zint);
%             gdata.SP(i,:) = interp1(data.SP(i,:),data.P(i,:),zint);
%             gdata.DO(i,:) = interp1(data.DO(i,:),data.P(i,:),zint);
%             gdata.z(i,:) = gsw_z_from_p(gdata.P(i,:), data.lat(i,:));
%             [gdata.sa(i,:), gdata.sstar(i,:), gdata.in_ocean(i,:)] = gsw_SA_Sstar_from_SP(gdata.SP(i,:), gdata.P(i,:), data.lon(i,:), data.lat(i,:));
% 
%             gdata.pt(i,:) = gsw_pt_from_t(gdata.sa(i,:), gdata.T(i,:), gdata.P(i,:), 0);
%             gdata.ct(i,:) = gsw_CT_from_t(gdata.sa(i,:), gdata.T(i,:), gdata.P(i,:));
%             gdata.pden(i,:) = gsw_rho(gdata.sa(i,:), gdata.ct(i,:), 0);
%             gdata.rho(i,:) = gsw_rho(gdata.sa(i,:), gdata.ct(i,:), gdata.P(i,:));
%             [gdata.N2(i,:), gdata.p_mid(i,:)] = gsw_Nsquared(gdata.sa(i,:), gdata.ct(i,:), gdata.P(i,:), data.lat(i,:));
        end
      

        save(outfile);

end
