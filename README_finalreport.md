## In This Directory
- `FinalReport.Rmd`: this is the code for the report document. Nothing needs to be changed to knit the report.
- `cleaned_econ_polls.rds`: the rds file that contains cleaned polling data from The Economist for presidential election as of Nov 2nd.
- `cleaned_senate_polls.rds`: the rds file that contains cleaned polling data from FiveThirtyEight for Senate election as of Nov 2nd.
- `cleaned_house_polls.rds`: the rds file that contains cleaned polling data from FiveThirtyEight for House election as of Nov 2nd.
- `pres_model_multivariate.Rmd`: the is the code for running the presidential election model.
- `pres_model_output.rds`: the rds file that contains model output from the presidential election model.
- `senate_model.Rmd`: the is the code for running the Senate election model.
- `senate_model_output.rds`: the rds file that contains model output from the Senate election model.
- `house_model.Rmd`: the is the code for running the House election model.
- `house_model_output.rds`: the rds file that contains model output from the House election model.
- `grouped_voter_data.rds`: the rds file on 2020 registered voters in North Carolina that has been cleaned, used in the House election model.
- `vote_share_df.Rdata`: the data file that contains vote share information from predicted turnout for 2020 voters in North Carolina, used in the House election model.
- `electoral_votes.csv`: the data file that contains the electoral college vote quota for each state.

## Data
### Presidential Election Model: 
- `2020 US presidential election polls - all_polls.csv`: 2020 U.S. Presidential Election Polls compiled by The Economist, publiclly available at https://projects.economist.com/us-2020-forecast/president/how-this-works. 
- `partisan_leans_538.csv`: effect of partisan lean on the Democratic candidate's presidential election vote share in each state. Available at https://github.com/fivethirtyeight/data/tree/master/partisan-lean.
- `abramowitz_data.csv`: downloaded from Andrew Gelman's Github repository on the 2020 Presidential Election. This data set contains information on each of the 1948-2016 election year's annualized 2nd quarter GDP growth rate, incumbent party's June approval rating and incumbent party's vote share. Available at https://github.com/TheEconomist/us-potus-model.
- `states_cov_matrix_full.csv`: covariance matrix of states which take into account similarity between states based on their demographic and political profiles. Retrieved from Andrew Gelman's Github repository on the 2020 Presidential Election. 
- `abramowitz_additional.csv`: Supplemented `abramowitz_data.csv` with the corresponding year's 2nd quarter real income growth, 3rd quarter real income growth (data from FRED https://fred.stlouisfed.org/series/A067RO1Q156NBEA) and S&P stock performance 3 months prior to the election (data from https://www.multpl.com/s-p-500-historical-prices/table/by-month). 
 
### Senate Election Model: 
- `senate_polls.csv`: this is from course website https://data.fivethirtyeight.com/ 
- `partisan_leans_538.csv`: same as the data set in presidential election model
- We also incorporated incumbency advantage in the model, which as FiveThirtyEight suggests, is on average 2.6 for senate incumbents (https://fivethirtyeight.com/features/how-much-was-incumbency-worth-in-2018/).
 
### House Election Model (for North Carolina):
- `house_polls.csv`: this is from course website https://data.fivethirtyeight.com/ 
- `ncvoter_1027_small.rds`: NC registered voter demographics information provided by the NC State Board of Elections (https://dl.ncsbe.gov/list.html). 
- Partisan lean and incumbency information was taken from FiveThirtyEight at the following links, respectively:  https://fivethirtyeight.com/features/north-carolinas-new-house-map-hands-democrats-two-seats-but-it-still-leans-republican/, https://fivethirtyeight.com/features/how-much-was-incumbency-worth-in-2018/
