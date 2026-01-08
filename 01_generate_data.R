# 01_generate_data.R
# Generates reproducible synthetic student performance data
# Output: data/dataset.csv

set.seed(42)

n <- 500

Student_ID <- sprintf("S%04d", 1:n)

# Behaviors (reasonable ranges)
Study_Hours_Per_Day <- pmax(0, pmin(rnorm(n, mean = 2.5, sd = 1.2), 8))
Extracurricular_Hours_Per_Day <- pmax(0, pmin(rnorm(n, mean = 1.2, sd = 0.8), 5))
Physical_Activity_Hours_Per_Day <- pmax(0, pmin(rnorm(n, mean = 0.8, sd = 0.6), 3))

Sleep_Hours_Per_Night <- pmax(4, pmin(rnorm(n, mean = 7.0, sd = 1.0), 10))
Screen_Time_Hours_Per_Day <- pmax(0, pmin(rnorm(n, mean = 3.5, sd = 1.6), 10))

# Categorical features
Gender <- sample(c("Female", "Male", "Non-binary"), n, replace = TRUE, prob = c(0.49, 0.49, 0.02))
Year <- sample(c("Freshman", "Sophomore", "Junior", "Senior"), n, replace = TRUE, prob = c(0.26, 0.25, 0.25, 0.24))

# Stress is related to workload and sleep
Stress_Score <- 5 +
  0.7 * Extracurricular_Hours_Per_Day +
  0.3 * Study_Hours_Per_Day -
  0.6 * (Sleep_Hours_Per_Night - 7) +
  rnorm(n, 0, 1.2)
Stress_Score <- pmax(1, pmin(round(Stress_Score, 1), 10))

# GPA signal: study helps, extreme stress hurts, sleep helps, too much screen time hurts
gpa_raw <- 2.6 +
  0.18 * Study_Hours_Per_Day +
  0.06 * Physical_Activity_Hours_Per_Day +
  0.08 * (Sleep_Hours_Per_Night - 7) -
  0.05 * Screen_Time_Hours_Per_Day -
  0.06 * (Stress_Score - 5) +
  rnorm(n, 0, 0.35)

GPA <- pmax(0, pmin(round(gpa_raw, 2), 4.0))

# Add a small amount of missingness to feel realistic
make_missing <- function(x, p = 0.02) {
  idx <- sample(seq_along(x), size = floor(length(x) * p))
  x[idx] <- NA
  x
}

Study_Hours_Per_Day <- make_missing(Study_Hours_Per_Day, 0.02)
Sleep_Hours_Per_Night <- make_missing(Sleep_Hours_Per_Night, 0.02)

dataset <- data.frame(
  Student_ID,
  GPA,
  Study_Hours_Per_Day,
  Extracurricular_Hours_Per_Day,
  Physical_Activity_Hours_Per_Day,
  Sleep_Hours_Per_Night,
  Screen_Time_Hours_Per_Day,
  Stress_Score,
  Gender,
  Year
)

dir.create("data", showWarnings = FALSE)
write.csv(dataset, "data/dataset.csv", row.names = FALSE)

cat("Wrote data/dataset.csv with", nrow(dataset), "rows and", ncol(dataset), "columns.\n")