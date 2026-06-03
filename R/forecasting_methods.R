# forecasting_methods.R
# Purpose: Apply all required forecasting methods to ts_train

library(forecast)

# Naive forecasting
naive_forecast <- function(ts_train) {
  c(NA, as.numeric(ts_train[-length(ts_train)]))
}

# Moving average (k periods)
ma_forecast <- function(ts_train, k = 3) {
  as.numeric(stats::filter(ts_train, rep(1/k, k), sides = 1))
}

# Weighted moving average
wma_forecast <- function(ts_train, w = c(0.2, 0.3, 0.5)) {
  ts_vec <- as.numeric(ts_train)
  result <- rep(NA, length(ts_vec))
  for (i in length(w):length(ts_vec))
    result[i] <- sum(w * ts_vec[(i - length(w) + 1):i])
  result
}

# Exponential smoothing
es_forecast <- function(ts_train, alpha = 0.4) {
  HoltWinters(ts_train, alpha = alpha, beta = FALSE, gamma = FALSE)
}

# Holt trend-adjusted
holt_forecast <- function(ts_train, alpha = 0.4, beta = 0.2) {
  HoltWinters(ts_train, alpha = alpha, beta = beta, gamma = FALSE)
}
