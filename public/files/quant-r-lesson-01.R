# =============================================================================
# Quant R - Lesson 01: Why "Average Returns" Are a Lie
# =============================================================================
# Author: Arkadi Avanesyan
# Series: Quant R - Investing Truths Verified with Code
#
# The Question: "Why do I feel poorer even though my portfolio's
#               'average return' looks fine?"
#
# The Answer: Wall Street reports arithmetic mean. You experience geometric mean.
#             The gap between them is the "volatility tax."
# =============================================================================

# -----------------------------------------------------------------------------
# Part 1: The Basic Lie
# -----------------------------------------------------------------------------

# Simple example: +50% then -50%
returns <- c(0.50, -0.50)

# What your broker reports (arithmetic mean)
arithmetic_mean <- mean(returns)
cat("========================================\n")
cat("THE LIE\n")
cat("========================================\n")
cat("Reported 'Average' Return:", arithmetic_mean * 100, "%\n")

# What actually happened (geometric return)
actual_result <- prod(1 + returns) - 1
cat("Actual Return:", actual_result * 100, "%\n\n")

# -----------------------------------------------------------------------------
# Part 2: See It With Real Money
# -----------------------------------------------------------------------------

initial_investment <- 100
after_year_1 <- initial_investment * (1 + returns[1])
after_year_2 <- after_year_1 * (1 + returns[2])

cat("========================================\n")
cat("WITH REAL MONEY\n")
cat("========================================\n")
cat("Starting amount: $", initial_investment, "\n")
cat("After Year 1 (+50%): $", after_year_1, "\n")
cat("After Year 2 (-50%): $", after_year_2, "\n")
cat("You LOST: $", initial_investment - after_year_2, "\n\n")

# -----------------------------------------------------------------------------
# Part 3: The Volatility Tax Over Time
# -----------------------------------------------------------------------------

set.seed(42)
years <- 20

# Portfolio A: Volatile (8% average, 25% standard deviation)
volatile_returns <- rnorm(years, mean = 0.08, sd = 0.25)

# Portfolio B: Steady (4% every year, no variance)
steady_returns <- rep(0.04, years)

# Calculate wealth paths
volatile_wealth <- 10000 * cumprod(1 + volatile_returns)
steady_wealth <- 10000 * cumprod(1 + steady_returns)

cat("========================================\n")
cat("THE VOLATILITY TAX (20 YEARS)\n")
cat("========================================\n")
cat("Starting: $10,000\n\n")
cat("Volatile portfolio:\n")
cat("  Arithmetic mean:", round(mean(volatile_returns) * 100, 1), "%\n")
cat("  Final value: $", format(round(tail(volatile_wealth, 1)), big.mark=","), "\n\n")
cat("Steady portfolio:\n")
cat("  Return: 4% every year\n")
cat("  Final value: $", format(round(tail(steady_wealth, 1)), big.mark=","), "\n\n")

# -----------------------------------------------------------------------------
# Part 4: The Formula
# -----------------------------------------------------------------------------

# Geometric return approximation:
# Geometric Return ≈ Arithmetic Return - (Variance / 2)

variance <- var(volatile_returns)
expected_geometric <- mean(volatile_returns) - (variance / 2)

cat("========================================\n")
cat("THE FORMULA\n")
cat("========================================\n")
cat("Geometric Return ≈ Arithmetic Return - (Variance/2)\n\n")
cat("For the volatile portfolio:\n")
cat("  Arithmetic mean:", round(mean(volatile_returns) * 100, 1), "%\n")
cat("  Variance:", round(variance, 4), "\n")
cat("  Volatility drag:", round((variance/2) * 100, 1), "%\n")
cat("  Expected geometric:", round(expected_geometric * 100, 1), "%\n")
cat("  Actual geometric:", round((prod(1 + volatile_returns)^(1/years) - 1) * 100, 1), "%\n\n")

# -----------------------------------------------------------------------------
# Part 5: Visualization (if you have ggplot2)
# -----------------------------------------------------------------------------

# Uncomment below if you have ggplot2 installed
# library(ggplot2)
#
# df <- data.frame(
#   Year = 1:years,
#   Volatile = volatile_wealth,
#   Steady = steady_wealth
# )
#
# ggplot(df, aes(x = Year)) +
#   geom_line(aes(y = Volatile, color = "Volatile (8% avg, 25% vol)"), linewidth = 1) +
#   geom_line(aes(y = Steady, color = "Steady (4% guaranteed)"), linewidth = 1) +
#   scale_color_manual(values = c("Volatile (8% avg, 25% vol)" = "#EF4444",
#                                  "Steady (4% guaranteed)" = "#10B981")) +
#   labs(title = "Why Steady 4% Often Beats Volatile 8%",
#        subtitle = "The volatility tax in action",
#        y = "Portfolio Value ($)",
#        color = "Strategy") +
#   theme_minimal() +
#   scale_y_continuous(labels = scales::dollar_format())

# -----------------------------------------------------------------------------
# KEY TAKEAWAY
# -----------------------------------------------------------------------------

cat("========================================\n")
cat("KEY TAKEAWAY\n")
cat("========================================\n")
cat("Ask for GEOMETRIC returns, not averages.\n")
cat("The arithmetic mean lies to you.\n")
cat("The geometric mean tells you what you actually keep.\n")
cat("========================================\n")
