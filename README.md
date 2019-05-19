# Argentine-Basin-Heat-Flux

## Important Figures 

### CT/AS Diagram:
![12881_CT:AS](https://user-images.githubusercontent.com/40899724/57988505-407fe880-7a44-11e9-8f6c-587413044116.jpg)

### Conservative Temperature Time Series:
![12881_CT](https://user-images.githubusercontent.com/40899724/57988518-4ece0480-7a44-11e9-90c0-08b048ccedbe.jpg)

*Time labels need to be fixed

### Absolute Salinity Time Series:
![12881_AS](https://user-images.githubusercontent.com/40899724/57988522-57263f80-7a44-11e9-84c7-892e5d92840d.jpg)

*Time labels need to be fixed


## Important code: 
### interpolation.m 
* within it is a function intARGO:
    which takes in time, depth, variable, nt, and dz.  It gets rid of profile with 70% of the data missing, and performs         spline interpolation at depth in between points, with no extrapolation. 
    then discards time series for each depth where more than 30% of the data is missing
    finally interpolates in time, and renames the variables.
