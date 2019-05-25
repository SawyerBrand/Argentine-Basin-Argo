# Argentine-Basin-Heat-Flux

## Important Figures 

### Trajectory Plots
![12700_12881_Trajectory](https://user-images.githubusercontent.com/40899724/58374979-c648db80-7efd-11e9-826a-f7d5eba15c41.jpg)

### CT/AS Diagram:
![12881_CT:AS](https://user-images.githubusercontent.com/40899724/57988505-407fe880-7a44-11e9-8f6c-587413044116.jpg)

### Conservative Temperature Time Series:
![12881_CT](https://user-images.githubusercontent.com/40899724/57988518-4ece0480-7a44-11e9-90c0-08b048ccedbe.jpg)

*Time labels need to be fixed

### Absolute Salinity Time Series:
![12881_AS](https://user-images.githubusercontent.com/40899724/57988522-57263f80-7a44-11e9-84c7-892e5d92840d.jpg)

*Time labels need to be fixed


### Heat Content Integrated over Water Masses (But not interpolated in any way)
Figure 1: The graphs represent the heat content at each measured depth, integrated (not interpolated) over depths of 0-400m, 400-1200m, and 1200-1400m. Because the data hasn’t been interpolated, it is a generalization of each depth, because they aren’t on a similar grid. The third graph, from 1200-1400m, has only a few data points because there are so many NaN values represented (Sawyer will have to go in and look at why that is and make sure it’s not just her processing code). 


Figure 2: The two graphs represent heat integration over 0-400m, and 400-1200m. This was created to represent all the values that were given, and not include the NaN values that came up below 1200m. Therefore, they show non-interpolated integration of surface waters (subplot 1) and of mode to deep waters (subplot 2). 

## Important code: 
### interpolation.m 
* within it is a function intARGO:
    which takes in time, depth, variable, nt, and dz.  It gets rid of profile with 70% of the data missing, and performs         spline interpolation at depth in between points, with no extrapolation. 
    then discards time series for each depth where more than 30% of the data is missing
    finally interpolates in time, and renames the variables.
