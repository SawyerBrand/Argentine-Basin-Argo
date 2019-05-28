function ArgoWaterfall(fn)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sawyer Brand (SOCCOM SIO)%%
%% Requires a mat file of   %%
%% ARGO data formatted by   %%
%% using the process_argo.m %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Data = load(fn);
%file will be a .mat file that is processed using the process_argo.m
%function I created

%% Temperature waterfall 
figure(1)   % first figure is gonna be temperature because it's the most important
hold on

title('Temperature vs Pressure 12700')
xlabel('In-Situ Temp (C) + 15')     %using in-situ for this with a delta T of 15 (eyeballed value)
ylabel('In-situ Pressure')

set(gca,'Ydir','reverse')       %Just because of depth

for i = 1:size(Data.data.T,1)
    plot((Data.data.T(i,:)+(i+15)),Data.data.P(i,:),'b')    %adds 15 to the index each time, ends up being a good way to increment
end 

hold off

%% Salinity Waterfall 
figure(2)
hold on

title('Salinity vs Pressure 12700')     
xlabel('Specific Salinity (psu) + 15')      % Using practical salinity with an eyeballed delta SP of 15
ylabel('In-situ Pressure')

set(gca,'Ydir','reverse')

for i = 1:size(Data.data.SP,1)
    plot((Data.data.SP(i,:)+(i+15)),Data.data.P(i,:),'b')
end 

hold off
