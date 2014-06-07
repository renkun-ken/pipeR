context("Lambda piping")

test_that("Lambda piping works as expected", {

  # ordinary usages
  expect_identical(1:10 %|>% (x ~ sin(x)) %|>% (x ~ sum(x)), sum(sin(1:10)))
  expect_identical(iris %|>% (df ~ names(df)), names(iris))
  expect_identical(iris %|>% (df ~ head(df,n=3)), head(iris,n=3))
  expect_identical("a" %|>% (input ~ switch(input,a=1,b=2,c=3)),
    switch("a",a=1,b=2,c=3))

  # stored lambda expressions
  proc1 <- x ~ sin(x)
  proc2 <- x ~ sum(x)
  expect_identical(1:10 %|>% proc1 %|>% proc2, sum(sin(1:10)))

  # working with higher-order functions
  expect_identical(1:5 %|>% (x ~ lapply(x,function(i) i+1)),
    lapply(1:5,function(i) i+1))
  expect_identical(1:5 %|>% (x ~ vapply(x,function(i) c(i,i^2),numeric(2))),
    vapply(1:5,function(i) c(i,i^2),numeric(2)))
  expect_identical(1:5 %|>% (x ~ lapply(x,function(i) i+x)),
    lapply(1:5,function(i) i+1:5))

  ## working with ...
  fun1 <- function(x,a,b) {
    c(x+a,x+b)
  }

  fun2 <- function(x,...) {
    fun1(x,...)
  }

  expect_identical(1:10 %|>% (x ~ fun2(x,a=-1,b=1)), fun1(1:10,a=-1,b=1))
})
