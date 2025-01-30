# Reconstructing individual-level exposures in cohort analyses of environmental risks: an example with the UK Biobank

------------------------------------------------------------------------

## Sample code for environment and residential data linkage

This repository stores the updated R code to reproduce a simpler and simulated version of the linkage process presented in the article:

Vanoli, J., Mistry, M.N., De La Cruz Libardi, A. et al. Reconstructing individual-level exposures in cohort analyses of environmental risks: an example with the UK Biobank. J Expo Sci Environ Epidemiol 34, 1012–1017 (2024). <https://doi.org/10.1038/s41370-023-00635-w> [[freely available here](https://www.nature.com/articles/s41370-023-00635-w)]

This work was supported by the Medical Research Council-UK (Grant IDs: MR/Y003330/1 and MR/R013349/1), the European Union’s Horizon 2020 Project Exhaustion (Grant ID: 820655), Nagasaki University “Doctoral Program for World-leading Innovative and Smart Education” for Global Health (WISE), KENKYU SHIDO KEIHI (“the Research Grant”) and KYOIKU KENKYU SHIEN KEIHI (“the Stipend”).

### Folders

-   *data*: this folder contains the daily exposure predictions of PM<sub>2.5</sub> for a coastal area of South England over a 1x1 km grid. The data are split into yearly datasets including 2017, 2018, and 2019. The datasets were produced using a method described in a previously published work ([freely available here](https://www.sciencedirect.com/science/article/pii/S1309104224002496?via%3Dihub)). However, the same linkage process can be performed with any other environmental exposure dataset with similar features, simply by adapting the R code (particularly 02_exposure_series.R).

### R code

-   `01_resid_health_data.R`: the script defines sample datasets of individuals including information regarding residential histories located in the specific UK region (for graphical purposes).
-   `02_exposure_series.R`: the script produces the linkage between residential histories and exposure series following steps 1) and 2) of the article.
-   `03_plots.R`: the script produces the following graphs: a map of the locations for all the subjects, a map for the residential locations corresponding with subject A, a plot of the full PM<sub>2.5</sub> series at all the residential locations for subject A, and a plot of the final exposure series for subject A (step 2 of the article).
