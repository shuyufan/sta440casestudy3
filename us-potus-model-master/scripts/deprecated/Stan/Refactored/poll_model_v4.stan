data{
  int N;    // Number of polls
  int T;    // Number of days
  int S;    // Number of states (for which at least 1 poll is available) + 1
  int P;    // Number of pollsters
  int<lower = 1, upper = S> state[N]; // State index
  int<lower = 1, upper = T> day[N];   // Day index
  int<lower = 1, upper = P> poll[N];  // Pollster index
  vector[S - 1] state_weights; // subtract 1 for national; based on 2012/16 turnouts
  
  // data
  int n_democrat[N];
  int n_respondents[N];
  
  // forward-backward
  int<lower = 1, upper = T> current_T;
  matrix[S - 1, S - 1] ss_correlation;
  
  // prior input
  // mu_a
  real<lower = 0> prior_sigma_a;
  // mu_b
  real<lower = 0> prior_sigma_b;
  vector[S - 1] mu_b_prior; // mu_b
  // mu_c
  real<lower = 0> prior_sigma_c; // mu_c
  // alpha
  real mu_alpha;    
  real sigma_alpha; 
  // measurement noise
  real<lower = 0> prior_sigma_measure_noise;
  
}

transformed data {
  row_vector[S - 1] rv_mu_b_prior;
  matrix[S - 1, S - 1] cholesky_ss_correlation;
  cholesky_ss_correlation = cholesky_decompose(ss_correlation);
  rv_mu_b_prior = to_row_vector(mu_b_prior);
}

parameters {
  // alpha
  real raw_alpha;             
  // mu_a
  real<lower = 0> raw_sigma_a;
  real raw_mu_a[current_T];
  // mu_b
  real<lower = 0> raw_sigma_b;
  matrix[T, S - 1] raw_mu_b; // S state-specific components at time T
  // mu_c
  real<lower = 0> raw_sigma_c;
  vector[P] raw_mu_c;
  // u = measurement noise
  real <lower = 0> raw_sigma_measure_noise_state;
  real <lower = 0> raw_sigma_measure_noise_national;
  vector[N] measure_noise;
  // e polling error
  row_vector[S - 1] raw_polling_error;  // S state-specific polling errors (raw)
}

transformed parameters {
  //*** parameters
  // alpha
  real sigma_a;
  real alpha;
  // mu_a
  vector[current_T] mu_a;
  // mu_b
  real sigma_b;
  matrix[T, S - 1] mu_b;
  // mu_c
  real sigma_c;
  vector[P] mu_c;
  // u
  real sigma_measure_noise_national;
  real sigma_measure_noise_state;
  // e 
  row_vector[S - 1] polling_error;  
  
  //*** containers
  vector[current_T] sum_average_states; 
  real pi_democrat[N];
  
  //*** construct parameters
  // alpha
  alpha = mu_alpha + raw_alpha * sigma_alpha;
  // polling error
  polling_error = raw_polling_error * cholesky_ss_correlation'; // cholesky decomposition
  // mu_a
  sigma_a = raw_sigma_a * prior_sigma_a / 2;
  mu_a[current_T] = 0;
  for (t in 1:(current_T - 1)) mu_a[current_T - t] = mu_a[current_T - t + 1] + raw_mu_a[current_T - t + 1] * sigma_a; 
  // mu_b
  sigma_b = raw_sigma_b * prior_sigma_b / 2;
  // last (T)
  mu_b[T] = rv_mu_b_prior * cholesky_ss_correlation';
  // forward from current poll (T - 1 to current_T)
  for (t in 1:(T - current_T)) mu_b[T - t] = raw_mu_b[T - t] * cholesky_ss_correlation' + mu_b[T - t + 1];
  // backward from current poll (current_T to 1)
  for (t in 1:(current_T - 1)) mu_b[current_T - t] = mu_b[current_T - t + 1] + raw_mu_b[current_T - t] * sigma_b;
  // mu_c
  sigma_c = raw_sigma_c * prior_sigma_c / 2;
  mu_c = raw_mu_c * sigma_c;
  // u
  sigma_measure_noise_national = raw_sigma_measure_noise_national * prior_sigma_measure_noise / 2;
  sigma_measure_noise_state = raw_sigma_measure_noise_state * prior_sigma_measure_noise / 2;
  
  // averages
  for (t in 1:current_T) sum_average_states[t] = (mu_b[t] + mu_a[t] + polling_error) * state_weights;

  //*** fill pi_democrat
  for (i in 1:N){
    // national-level
    if (state[i] == 52){
      // sum_average_states = weights times state polls trends
      // alpha              = discrepancy adjustment
      // mu_c               = polling house effect
      // measure_noise      = noise of the individual poll
      pi_democrat[i] = sum_average_states[day[i]] + alpha + mu_c[poll[i]] + sigma_measure_noise_national * measure_noise[i];
    } else {
      // state-level
      // mu_a               = national component
      // mu_b               = state component
      // mu_c               = poll component
      // measure_noise (u)  = state noise
      // polling_error (e)  = polling error term (state specific)
      pi_democrat[i] = mu_a[day[i]] + mu_b[day[i], state[i]] + mu_c[poll[i]] + measure_noise[state[i]] * sigma_measure_noise_state + polling_error[state[i]];    
    }
  }
}

model {
  //*** priors
  // Priors not mentioned here have uniform priors bounded by the upper and lower constraints.
  // alpha
  raw_alpha ~ std_normal();
  // mu_a
  raw_sigma_a ~ std_normal();
  raw_mu_a ~ std_normal_lpdf();
  // mu_b
  raw_sigma_b ~ std_normal();
  for (s_id in 1:(S - 1)){
    raw_mu_b[:, s_id] ~ std_normal();  
  } 
  // mu_c
  raw_sigma_c ~ std_normal();
  raw_mu_c ~ std_normal();
  // measurement noise
  raw_sigma_measure_noise_state ~ std_normal();
  raw_sigma_measure_noise_national ~ std_normal();
  measure_noise ~ std_normal();
  //*** likelihood
  n_democrat ~ binomial_logit(n_respondents, pi_democrat);
}

