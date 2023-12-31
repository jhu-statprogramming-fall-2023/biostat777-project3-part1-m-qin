suppressMessages({
  library(testthat)
  library(dplyr)
  library(tibble)
})
source_test_helpers("R/determineTrimVals.R")


#### cdf_trim() ####
test_that("Test cdf_trim(): LOP", {
  df_long <- data.frame(id = c(rep("A",3), rep("B",3),rep("C",3)),
                        value = c(1,2,3,1,2,3,1,2,3),
                        quantile = c(0,0.2,0.4,0.1,0.3,0.5,0.2,0.4,0.6))
  trim_type = "interior"
  n_trim = 1
  # check a set of keep values
  expected <- data.table(id = c(rep("A",3), rep("B",3),rep("C",3)),
                     value = c(1,2,3,1,2,3,1,2,3),
                     quantile = c(0,0.2,0.4,0.1,0.3,0.5,0.2,0.4,0.6),
                     weight = c(rep(1,3), rep(0,3),rep(1,3)))
  test <- cdf_trim(df_long, trim_type, n_trim, "LOP")
  attr(test,'out.attrs') <- NULL
  expect_identical(test, expected)
})

test_that("Test cdf_trim(): Vincent", {
  df_long <- expand.grid(id = c("A","B","C"),
                         quantile = c(0,0.5,1))
  df_long$value <- ifelse(df_long$id == "A", 1, ifelse(df_long$id == "B", 2, 3))
  trim_type <- "interior"
  n_trim = 1
  # check a set of keep values
  expected <- data.table(id = factor(rep(c("A","B","C"),3)),
                     quantile = c(rep(0,3),rep(0.5,3),rep(1,3)),
                     value = rep(1:3,3),
                     weight = c(1,0,1,1,0,1,1,0,1))
  test <- cdf_trim(df_long, trim_type, n_trim, "vincent")
  attr(test,'out.attrs') <- NULL
  expect_equal(test, expected)
})

#### trim_cdf() ####
test_that("Test implement_trim_cdf(): LOP",{
  df_long <- data.frame(quantile = c(0,0.5,1,0,0,0.5),
                        value = c(1,1,1,2,2,2))
  # check a set of keep values
  keep = 1:2
  expected <- df_long %>%
    mutate(weight = c(1,1,0,1,1,0))
  expect_identical(implement_trim_cdf(df_long, keep, "LOP"), setDT(expected))
  # check a second set of keep values
  keep = c(1,3)
  expected <- df_long %>%
    mutate(weight = c(1,0,1,1,0,1))
  expect_identical(implement_trim_cdf(df_long, keep, "LOP"), expected)
})

test_that("Test implement_trim_cdf(): LOP, rows not ordered",{
  df_long <- data.frame(quantile = c(0,0.5,1,0,0,0.5),
                        value = c(1,1,1,2,2,2))
  df_long <- df_long[c(4:6,1:3),]
  # check a set of keep values
  keep = 1:2
  expected <- df_long %>%
    mutate(weight = c(1,1,0,1,1,0))
  expect_identical(implement_trim_cdf(df_long, keep, "LOP"), setDT(expected))
  # check a second set of keep values
  keep = c(1,3)
  expected <- df_long %>%
    mutate(weight = c(1,0,1,1,0,1))
  expect_identical(implement_trim_cdf(df_long, keep, "LOP"), expected)
})

test_that("Test implement_trim_cdf(): vincent",{
  df_long <- data.frame(quantile = rep(c(0,0.5,1),3),
                        value = c(1,1,1,2,2,2,3,3,3))
  # check a set of keep values
  keep = 1:2
  expected <- df_long %>%
    mutate(weight = c(rep(1,6), rep(0,3)))
  expect_identical(implement_trim_cdf(df_long, keep, "vincent"), setDT(expected))
  # check a second set of keep values
  keep = c(1,3)
  expected <- df_long %>%
    mutate(weight = c(rep(1,3), rep(0,3), rep(1,3)))
  expect_identical(implement_trim_cdf(df_long, keep, "vincent"), expected)
})

test_that("Test implement_trim_cdf(): vincent, rows not ordered",{
  df_long <- data.frame(quantile = rep(c(0,0.5,1),3),
                        value = c(1,1,1,2,2,2,3,3,3))
  df_long <- df_long[c(7,1,4,8,2,5,9,3,6),]
  # check a set of keep values
  keep = 1:2
  expected <- df_long %>%
    mutate(weight = ifelse(value == 3, 0, 1))
  expect_identical(implement_trim_cdf(df_long, keep, "vincent"), setDT(expected))
  # check a second set of keep values
  keep = c(1,3)
  expected <- df_long %>%
    mutate(weight = ifelse(value == 2, 0, 1))
  expect_identical(implement_trim_cdf(df_long, keep, "vincent"), expected)
})

