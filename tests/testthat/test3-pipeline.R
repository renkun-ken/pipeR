context("Pipeline tests")

test_that("tests", {
  expect_identical({
    pipeline(1:10, sin, sum)
  }, sum(sin(1:10)))
  expect_identical(pipeline(), NULL)
  expect_identical(pipeline(1:10), 1:10)
  expect_equal(pipeline(mtcars, lm(formula = mpg ~ cyl + wt), summary, coef),
    coef(summary(lm(formula = mpg ~ cyl + wt, data = mtcars))))
  expect_equal(pipeline({
    mtcars
    lm(formula = mpg ~ cyl + wt)
    summary
    coef
  }), coef(summary(lm(formula = mpg ~ cyl + wt, data = mtcars))))
  expect_equal({
    z <- pipeline({
      1:10
      head(5)
      ~ nhead
      head(1)
    })
    list(z, nhead)
  }, list(1L, 1:5))
})
