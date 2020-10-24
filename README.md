## In This Directory
- `make_small_versions.R`: this is the code we used to subset data from the files in the `VOTE` folder on the DCC.
- `filtered_ncvoterhis_resp.rds`: the data set we cleaned up for modeling purposes.
- `voter_grouped_sa_ra.rds`: The grouped voter data that is used to run our main model as well as sensitivity analysis models.
- `10_20_grouped_model_sa_ra.R`: the R file that was used to run the sensitivity analysis with random effects on the DCC.
- `randeff_sa_grouped_model_whole_data_output.rds`: the modeling result for the mixed effects model we used for sensitivity analysis. We saved it as .rds because the modeling process takes too much time if the original code chunks are run in the Interim Report.Rmd.
- `grouped_voter_data_2012.rds`: the data set that we cleaned up for external validation (the 2012 general election voter turnout data set).
- `Interim Report.Rmd`: this is the code for the report document. Nothing needs to be changed to knit the report.

Please note that you must have the `brm` package installed to run the models.
