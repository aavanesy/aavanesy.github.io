# =============================================================================
# Quant R - Dubai Lesson: The February 2026 Drop (9-Day Analysis)
# =============================================================================
# Author: Arkadi Avanesyan
# Series: Quant R - Investing Truths Verified with Code
# =============================================================================

library(quantmod)
library(xts)
library(ggplot2)
library(dplyr)
library(scales)

# -----------------------------------------------------------------------------
# Get Dubai Financial Market General Index (DFMGI) - Last 5 Years
# -----------------------------------------------------------------------------

end_date <- as.Date("2026-03-10")
start_date <- end_date - (5 * 365)

getSymbols("DFMGI.AE", from = start_date, to = end_date, src = "yahoo")
prices <- DFMGI.AE

# Use adjusted close price
close_prices <- Ad(prices)
colnames(close_prices) <- "Close"

cat("\n--- Data Summary ---\n")
cat("Symbol: DFMGI.AE (Dubai Financial Market General Index)\n")
cat("Period:", as.character(start(prices)), "to", as.character(end(prices)), "\n")
cat("Total trading days:", nrow(prices), "\n")

# -----------------------------------------------------------------------------
# Calculate Daily Returns
# -----------------------------------------------------------------------------

daily_returns <- diff(log(close_prices))
daily_returns <- daily_returns[-1]  # Remove first NA
colnames(daily_returns) <- "Daily_Return"

cat("Daily returns calculated:", nrow(daily_returns), "days\n")

# -----------------------------------------------------------------------------
# Compute Rolling 9-Day Returns (Historical)
# -----------------------------------------------------------------------------

cutoff_date <- as.Date("2026-02-26")

# Filter prices up to cutoff date for historical analysis
historical_prices <- close_prices[index(close_prices) <= cutoff_date]

# Calculate all rolling 9-day returns in history
# 9-day return = price[t] / price[t-9] - 1 (or log return)
n_days <- 9
rolling_9day_returns <- diff(log(historical_prices), lag = n_days)
rolling_9day_returns <- rolling_9day_returns[!is.na(rolling_9day_returns)]
colnames(rolling_9day_returns) <- "Return_9Day"

# Calculate historical 9-day volatility (standard deviation of 9-day returns)
volatility_9day <- sd(as.numeric(rolling_9day_returns), na.rm = TRUE)
mean_9day <- mean(as.numeric(rolling_9day_returns), na.rm = TRUE)

cat("\n--- Historical 9-Day Statistics (up to", as.character(cutoff_date), ") ---\n")
cat("Number of 9-day periods:", nrow(rolling_9day_returns), "\n")
cat("Mean 9-day return:", sprintf("%.2f%%", mean_9day * 100), "\n")
cat("9-day volatility (SD):", sprintf("%.2f%%", volatility_9day * 100), "\n")
cat("Annualized volatility:", sprintf("%.2f%%", volatility_9day * sqrt(365/9) * 100), "\n")

# -----------------------------------------------------------------------------
# Analyze the Drop: February 28 to March 9, 2026 (9 days)
# -----------------------------------------------------------------------------

drop_start <- as.Date("2026-02-28")
drop_end <- as.Date("2026-03-09")

# Get prices for the drop period
# Find closest trading days
all_dates <- index(close_prices)
start_idx <- which(all_dates >= drop_start)[1]
end_idx <- which(all_dates <= drop_end)
end_idx <- end_idx[length(end_idx)]

actual_start_date <- all_dates[start_idx]
actual_end_date <- all_dates[end_idx]

# We need price BEFORE Feb 28 to calculate the return
# So we use the closing price on Feb 26 (or nearest trading day before Feb 28)
pre_drop_idx <- which(all_dates < drop_start)
pre_drop_idx <- pre_drop_idx[length(pre_drop_idx)]
pre_drop_date <- all_dates[pre_drop_idx]

price_before <- as.numeric(close_prices[pre_drop_date])
price_after <- as.numeric(close_prices[actual_end_date])

# Calculate the 9-day drop
drop_return <- log(price_after / price_before)
drop_return_pct <- (price_after / price_before - 1)

cat("\n--- The 9-Day Drop Analysis ---\n")
cat("Start date:", as.character(pre_drop_date), "| Price:", sprintf("%.2f", price_before), "\n")
cat("End date:", as.character(actual_end_date), "| Price:", sprintf("%.2f", price_after), "\n")
cat("Calendar days:", as.numeric(actual_end_date - pre_drop_date), "\n")
cat("9-day return (log):", sprintf("%.2f%%", drop_return * 100), "\n")
cat("9-day return (simple):", sprintf("%.2f%%", drop_return_pct * 100), "\n")

# Calculate how many standard deviations from the mean
z_score <- (drop_return - mean_9day) / volatility_9day

cat("\n--- Standard Deviation Analysis ---\n")
cat("Historical mean 9-day return:", sprintf("%.2f%%", mean_9day * 100), "\n")
cat("Historical 9-day volatility:", sprintf("%.2f%%", volatility_9day * 100), "\n")
cat("Drop period return:", sprintf("%.2f%%", drop_return * 100), "\n")
cat("Z-score (standard deviations from mean):", sprintf("%.2f", z_score), "\n")

# Probability of such an event under normal distribution
prob_normal <- pnorm(z_score)
cat("\nUnder normal distribution assumption:\n")
cat("Probability of this or worse:", sprintf("%.6f%%", prob_normal * 100), "\n")
cat("This is a 1-in-", format(round(1/prob_normal), big.mark = ","), "event\n")

# -----------------------------------------------------------------------------
# Daily Returns During the Drop Period
# -----------------------------------------------------------------------------

drop_daily <- daily_returns[index(daily_returns) >= drop_start &
                             index(daily_returns) <= drop_end]

cat("\n--- Daily Returns During the Drop (Feb 28 - Mar 9) ---\n")
daily_df <- data.frame(
  Date = index(drop_daily),
  Return_Pct = sprintf("%.2f%%", as.numeric(drop_daily) * 100),
  Cumulative = sprintf("%.2f%%", cumsum(as.numeric(drop_daily)) * 100)
)
print(daily_df)

# -----------------------------------------------------------------------------
# Visualization: Historical 9-Day Returns Distribution with Drop Marked
# -----------------------------------------------------------------------------

hist_df <- data.frame(
  Return_9Day = as.numeric(rolling_9day_returns) * 100
)

p <- ggplot(hist_df, aes(x = Return_9Day)) +
  geom_histogram(bins = 50, fill = "#4A7C6F", color = "white", alpha = 0.8) +
  annotate("point", x = drop_return * 100, y = 0,
           color = "#C44536", size = 4) +
  geom_vline(xintercept = mean_9day * 100,
             color = "#2E5A4C", linewidth = 1, linetype = "dashed") +
  annotate("text", x = drop_return * 100 + 1, y = 8,
           label = paste0("Feb 28-Mar 9: ", sprintf("%.1f%%", drop_return * 100),
                          "\n(", sprintf("%.1f", abs(z_score)), " SD)"),
           hjust = 0, vjust = 0, color = "#C44536", fontface = "bold", size = 4) +
  annotate("text", x = mean_9day * 100 + 1, y = Inf,
           label = paste0("Mean: ", sprintf("%.2f%%", mean_9day * 100)),
           hjust = 0, vjust = 2, color = "#2E5A4C", size = 3.5) +
  scale_x_continuous(labels = function(x) paste0(x, "%")) +
  labs(
    title = "Dubai Market (DFMGI): The 9-Day Drop (Feb 28 - Mar 9, 2026)",
    subtitle = paste0("9-day rolling returns distribution (", format(start_date, "%Y"), "-Feb 2026) | ",
                      sprintf("%.1f", abs(z_score)), " standard deviations from the mean"),
    x = "9-Day Return",
    y = "Frequency"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 14, face = "bold"),
    plot.subtitle = element_text(size = 11),
    axis.title = element_text(size = 10),
    axis.text = element_text(size = 9)
  )

print(p)
ggsave("DubaiLesson-chart.png", plot = p, width = 10, height = 6, dpi = 140)

# -----------------------------------------------------------------------------
# Summary Statistics Table
# -----------------------------------------------------------------------------

cat("\n")
cat("=============================================================================\n")
cat("                           SUMMARY\n")
cat("=============================================================================\n")
cat(sprintf("5-Year 9-Day Volatility (up to Feb 26):  %.2f%%\n", volatility_9day * 100))
cat(sprintf("Drop Period Return (Feb 28 - Mar 9):     %.2f%%\n", drop_return * 100))
cat(sprintf("Standard Deviations from Mean:           %.2f\n", abs(z_score)))
cat("=============================================================================\n")
