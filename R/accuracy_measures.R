# accuracy_measures.R
# Purpose: Compute forecast accuracy measures

compute_accuracy <- function(actual, forecast_vals, method_name) {
  errors <- actual - forecast_vals
  bias   <- mean(errors)
  mad    <- mean(abs(errors))
  mse    <- mean(errors^2)
  mape   <- mean(abs(errors / actual)) * 100
  rsfe   <- sum(errors)
  ts_val <- rsfe / mad
  data.frame(
    Method          = method_name,
    Bias            = round(bias, 2),
    MAD             = round(mad, 2),
    MSE             = round(mse, 2),
    MAPE            = round(mape, 4),
    RSFE            = round(rsfe, 2),
    Tracking_Signal = round(ts_val, 4),
    stringsAsFactors = FALSE
  )
}
