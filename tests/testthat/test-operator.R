context("Operator tests")

test_that("first-argument piping", {

  # ordinary usages
  expect_identical(1:10 %>>% sin %>>% sum, sum(sin(1:10)))
  expect_identical(1:10 %>>% sin() %>>% sum(), sum(sin(1:10)))
  expect_identical(iris %>>% names, names(iris))
  expect_identical(iris %>>% head(n=3),head(iris,n=3))
  expect_identical("a" %>>% switch(a=1,b=2,c=3),switch("a",a=1,b=2,c=3))

  expect_identical(1:3 %>>% base::mean(), mean(1:3))
  expect_identical(1:3 %>>% c(1,2,.), c(1:3,1,2,1:3))

  # working with higher-order functions
  expect_identical(1:5 %>>% lapply(function(i) i+1), lapply(1:5,function(i) i+1))
  expect_identical(1:5 %>>% vapply(function(i) c(i,i^2),numeric(2)),
    vapply(1:5,function(i) c(i,i^2),numeric(2)))

  # working with ...
  fun1 <- function(x,a,b) {
    c(x+a,x+b)
  }

  fun2 <- function(x,...) {
    fun1(x,...)
  }

  expect_identical(1:10 %>>% fun2(a=-1,b=1), fun1(1:10,a=-1,b=1))
})

test_that("lambda piping", {
  expect_identical(1:3 %>>% (c(1,2,.)), c(1,2,1:3))
  expect_identical(1:3 %>>% {c(1,2,.)}, c(1,2,1:3))
  expect_identical(1:3 %>>% (x -> c(1,2,x)), c(1,2,1:3))
  expect_identical(1:3 %>>% (x ~ c(1,2,x)), c(1,2,1:3))
})

test_that("function", {
  # anonymous function
  expect_identical(1:3 %>>% (function(x) mean(x))(), 2)
  expect_identical(1:3 %>>% (function(x,y) mean(x+y))(3), 5)

  # closure
  expect_identical({
    z <- 1:3 %>>% (function(x) mean(x+.))
    z(3)
  }, 5)
})
