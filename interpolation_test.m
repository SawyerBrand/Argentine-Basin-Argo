function interpolation_test(fn,titl)

%%%%%%%%%%%%%%%%%%%%%%%%%
% Sawyer Brand: July 10th, 2019
% This function creates a plot of heat content integration over specific
% depths 0-200m, 200-1000m, 1000-1800m. 
%%%%%%%%%%%%%%%%%%%%%%%%%

%load in a .mat file, processed by process_argo.m
d = load(fn); 

hold on
set(gca,'ydir','reverse')
set(gca,'FontSize',18)

title([titl,': Interpolated Data with Original Data Overlay']);
ylabel('Pressure [dbars]')
xlabel('Temperature [C] + profile number')

for i = 1:1:size(d.idat.T,1)
    interp = scatter(d.idat.T(i,:)+i,d.idat.P(i,:),30,'r.');
    noninterp = scatter(d.data.T(i,:)+(i),d.data.P(i,:),10,'MarkerEdgeColor','black');
end
  
legend([interp noninterp],'Interpolated Data','Original Data','location','northwest')

hold off

end
