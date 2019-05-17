# Argentine-Basin-Heat-Flux

### interpolation.m 
* within it is a function intARGO:
    which takes in time, depth, variable, nt, and dz.  It gets rid of profile with 70% of the data missing, and performs         spline interpolation at depth in between points, with no extrapolation. 
    then discards time series for each depth where more than 30% of the data is missing
    finally interpolates in time, and renames the variables.
