# Reconstructing individual-level exposures in cohort analyses of environmental risks: an example with the UK Biobank

------------------------------------------------------------------------

## Sample code for environment and residential data linkage

This repository stores the updated R code to reproduce a simpler version of the linkage process presented in the article:

Vanoli, J., Mistry, M.N., De La Cruz Libardi, A. et al. Reconstructing individual-level exposures in cohort analyses of environmental risks: an example with the UK Biobank. J Expo Sci Environ Epidemiol 34, 1012–1017 (2024). https://doi.org/10.1038/s41370-023-00635-w [[freely available here](https://www.nature.com/articles/s41370-023-00635-w)]

This work was supported by the Medical Research Council-UK (Grant IDs: MR/Y003330/1 and MR/R013349/1), the European Union’s Horizon 2020 Project Exhaustion (Grant ID: 820655), Nagasaki University “Doctoral Program for World-leading Innovative and Smart Education” for Global Health (WISE), KENKYU SHIDO KEIHI (“the Research Grant”) and KYOIKU KENKYU SHIEN KEIHI (“the Stipend”).

### R code
The three R scripts demonstrate the linkage steps. Specifically:

01_resid_health_data.R Creates the simulated study participant and location data  
02_exposure_series.R Carries out the linkage of environmental data and participant locations  
03_plots.R Plots the participant location and linked exposure series  
