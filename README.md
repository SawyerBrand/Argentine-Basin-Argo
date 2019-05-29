# Argentine-Basin-Heat-Flux

*One paragraph description(?) 

## List of what's in this repo:
1. mfiles:
    i. process_argo2.m
    ii. ArgoWaterfall.m
2. ImportantFigures.md
3. README.md (which you already found)

## Important code: 

### ArgoWaterfall.m 
Creates the waterfall plots for Dr. Talley (In-situ temperature and salinity)

### interpolation.m 
* within it is a function intARGO:
    which takes in time, depth, variable, nt, and dz.  It gets rid of profile with 70% of the data missing, and performs         spline interpolation at depth in between points, with no extrapolation. 
    then discards time series for each depth where more than 30% of the data is missing
    finally interpolates in time, and renames the variables.
    
    
    
## Authors

* **Sawyer Brand**
 


