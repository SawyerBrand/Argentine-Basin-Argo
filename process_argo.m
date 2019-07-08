
    function data = process_argo(fn,titl)
  
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
        data.P(data.P >= 90000) = NaN;
        data.T(data.T >= 9000) = NaN;
        data.SP(data.SP >= 9000) = NaN;
        data.DO(data.DO >= 9000) = NaN;
        zint = 1:1:1800;

        
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
          
          data.cp = gsw_cp_t_exact(data.sa,data.ct, data.P);
          
          data.heat = data.rho .* data.cp .* (data.ct+273.15);

       for i = 1:2:size(data.T,1)
          tmp= data.P(i,:);
          tmpT = data.T(i,:);
          tmpSP = data.SP(i,:);
          tmpDO = data.DO(i,:);
          tmpSA = data.sa(i,:);
          tmpPT = data.pt(i,:);
          tmpCT = data.ct(i,:);
          tmpPD = data.pden(i,:);
          tmpR = data.rho(i,:);
          tmpH = data.heat(i,:);
          
          I = find(isfinite(tmp)==1 & isfinite(tmpT)==1);
          idat.T(i,:) = interp1(tmp(I),tmpT(I),zint);
          
          I2 = find(isfinite(tmp)==1 & isfinite(tmpSP)==1);
          idat.SP(i,:) = interp1(tmp(I2),tmpSP(I2),zint);
          
          I4 = find(isfinite(tmp)==1 & isfinite(tmp)==1);
          idat.P(i,:) = interp1(tmp(I4),tmp(I4),zint);  
          
          I5 = find(isfinite(tmp)==1 & isfinite(tmpSA)==1);
          idat.sa(i,:) = interp1(tmp(I5),tmpSA(I5),zint);
          
          I6 = find(isfinite(tmp)==1 & isfinite(tmpPT)==1);
          idat.pt(i,:) = interp1(tmp(I6),tmpPT(I6),zint);
          
          I7 = find(isfinite(tmp)==1 & isfinite(tmpCT)==1);
          idat.ct(i,:) = interp1(tmp(I7),tmpCT(I7),zint);
          
          I8 = find(isfinite(tmp)==1 & isfinite(tmpPD)==1);
          idat.pden(i,:) = interp1(tmp(I8),tmpPD(I8),zint);
          
          I9 = find(isfinite(tmp)==1 & isfinite(tmpR)==1);
          idat.rho(i,:) = interp1(tmp(I9),tmpR(I9),zint);
          
          I10 = find(isfinite(tmp)==1 & isfinite(tmpH)==1);
          idat.heat(i,:) = interp1(tmp(I10),tmpH(I10),zint);       
          
       end
       
       for i = 2:2:size(data.DO,1)
          tmp= data.P(i,:);
          tmpDO = data.DO(i,:);
          I3 = find(isfinite(tmp)==1 & isfinite(tmpSP)==1);
          idat.DO(i,:) = interp1(tmp(I3),tmpDO(I3),zint);
       end
       
       for i = zint
           idat.time(:,i) = datenum(data.time(1:2:49,:));
       end

    
%           keyboard
%               if length(I)>2
%                   idat.T(i,:) = interp1(data.P(I(i,:)),data.T(I(i,:)),zint)
%               end
%               if length(I2)>2
%                   idat.SP(i,:) = interp1(data.P(I(i,:)),data.SP(I(i,:)),zint)
%               end


        save(outfile);

    end
