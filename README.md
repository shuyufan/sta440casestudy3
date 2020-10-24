## In This Directory
- `filtered_ncvoterhis_resp.rds`: the data set we cleaned up for modeling purpose.
- `grouped_voter_data_2012.rds`: the data set that we cleaned up for external validation (the 2012 general election voter turnout data set).
- `randeff_sa_grouped_model_whole_data_output.rds`: the modeling result for the mixed effects model we used for sensitivity analysis. We saved it as .rds because the modeling process takes too much time if the original code chunks are included in the Interim-Report.Rmd.
- `Interim-Report.Rmd`: this is the code for the report document. Nothing needs to be changed to knit the report.

Please note that rjags does not work for virtual machines. If rjags isn't installed, try https://sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Mac%20OS%20X/ for MacOS users.