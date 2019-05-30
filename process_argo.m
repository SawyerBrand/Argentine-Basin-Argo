function data = process_argo(fn)
  
  outfile = '12700data.mat';
  addpath(genpath(fn));

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
  data.lat = raw_data.LATITUDE;
  data.lon = raw_data.LONGITUDE;
  data.P = raw_data.PRES'; %chose to use the nonadjusted vairables because they had all values of 99999
  data.T = raw_data.TEMP';
  data.SP = raw_data.PSAL';
  data.Oxy = raw_data.DOXY';
  
  % missing data
  data.P(data.P == max(max(data.P))) = nan;
  data.T(data.T == max(max(data.T))) = nan;
  data.SP(data.SP == max(max(data.SP))) = nan;
  data.Oxy(data.Oxy == max(max(data.Oxy))) = nan;
  
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
  
  save(outfile);

end
