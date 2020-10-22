library(tidyverse)
library(brms)
library(bayesplot) # to add titles/labels to ppc plot
library(tidybayes) # easy residuals

voter_grouped_train <- readRDS("grouped_voter_data.rds")

# Model
binary_model <-
  brm(data = voter_grouped_train, family = binomial,
      votes | trials(n) ~ 1 + med_inc_binned + gender_code + race_code + age_binned + party_cd + gender_code:party_cd + race_code:party_cd + gender_code:age_binned + party_cd:age_binned,
      iter = 2500, warmup = 500, cores = 2, chains = 2,
      seed = 10)
summary(binary_model)

# Validation & diagnostics start below ------------------------------
# 3-fold & 5-fold CV
set.seed(123)
k3 <- kfold(binary_model, K = 3, save_fits = TRUE)
k5 <- kfold(binary_model, K = 5, save_fits = TRUE)
k10 <- kfold(binary_model, K = 10, save_fits = TRUE)

## Slot yrep contains the matrix of predicted responses, 
## with rows being posterior draws and columns being observations
## (from documentation) 
k3_pred <- kfold_predict(k3, method = "fitted")
k5_pred <- kfold_predict(k5, method = "fitted")
k10_pred <- kfold_predict(k10, method = "fitted")

# define a loss function
# (from documentation kfold_predict)
rmse <- function(y, yrep) {
  yrep_mean <- colMeans(yrep)
  sqrt(mean((yrep_mean - y)^2))
}

# Print RMSE results
cat('RMSE with 3-fold CV:', rmse(y = k3_pred$y, yrep = k3_pred$yrep), '\n')
cat('RMSE with 5-fold CV:', rmse(y = k5_pred$y, yrep = k5_pred$yrep), '\n')
cat('RMSE with 10-fold CV:', rmse(y = k10_pred$y, yrep = k10_pred$yrep), '\n')

# PPC
pp_check(binary_model) + 
  xlab("Number voted") + 
  ylab("Density") + 
  yaxis_ticks() + 
  yaxis_text()

d <-
  voter_grouped_train %>% 
  ungroup() %>% 
  mutate(case = factor(1:nrow(voter_grouped_train))) # all the different cases (e.g. B race AND R party AND <29 age, etc. essentially each row)

p <-
  predict(binary_model) %>%
  as_tibble() %>%
  bind_cols(d)

ggplot(data = d, aes(x = case, y = votes / n)) +
  geom_pointrange(data = p,
                  aes(y    = Estimate / n,
                      ymin = Q2.5     / n ,
                      ymax = Q97.5    / n),
                  color = '#2F4F4F',
                  shape = 1, alpha = 1/3) + 
  geom_point(data=d, aes(x=case, y=votes/n))

# # True dots colored by whether it was within the quantile or not
# temp <- cbind(d, p[,1:4])
# temp$within <- ((temp$votes)/temp$n >= (temp$Q2.5)/temp$n) & 
#   ((temp$votes)/temp$n <=( temp$Q97.5)/temp$n)
# ggplot(data = temp, aes(x = case, y = votes / n)) +
#   geom_pointrange(data = temp,
#                   aes(y    = Estimate / n,
#                       ymin = Q2.5     / n ,
#                       ymax = Q97.5    / n),
#                   color = '#2F4F4F',
#                   shape = 1, alpha = 1/3) + 
#   geom_point(data=temp, aes(x=case, y=votes/n, color=within))

# Residuals

voter_grouped_train %>%
  add_residual_draws(binary_model) %>%
  ggplot(aes(x = .row, y = .residual)) +
  stat_pointinterval() + 
  geom_hline(yintercept = 0, color="red")

# Traceplots

post <- posterior_samples(binary_model, add_chain = T)

n_to_plot <- 4-1
for(i in seq(1, ncol(post)-3-n_to_plot, n_to_plot)) {
  post0 <- post[, c(i:(i+n_to_plot), length(post)-1, length(post))]
  p <- post0 %>% 
    #select(-lp__) %>% 
    gather(key, value, -chain, -iter) %>% 
    mutate(chain = as.character(chain)) %>% 
    
    ggplot(aes(x = iter, y = value, group = chain, color = chain)) +
    geom_line(size = 1/15) +
    scale_color_manual(values = c("#80A0C7", "#B1934A", "#A65141", "#EEDA9D")) +
    scale_x_continuous(NULL, breaks = c(1001, 5000)) +
    ylab(NULL) +
    #theme_pearl_earring +
    theme(legend.position  = c(.825, .06),
          legend.direction = "horizontal") +
    facet_wrap(~key, ncol = 2, scales = "free_y")
  print(p)
}

