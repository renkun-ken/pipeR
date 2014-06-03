context("Lambda piping")

test_that("Lambda piping works as expected", {

  # ordinary usages
  expect_that(1:10 %|>% (x ~ sin(x)) %|>% (x ~ sum(x)),
    is_identical_to(sum(sin(1:10))))
  expect_that(iris %|>% (df ~ names(df)),
    is_identical_to(names(iris)))
  expect_that(iris %|>% (df ~ head(df,n=3)),
    is_identical_to(head(iris,n=3)))
  expect_that("a" %|>% (input ~ switch(input,a=1,b=2,c=3)),
    is_identical_to(switch("a",a=1,b=2,c=3)))

  # stored lambda expressions
  proc1 <- x ~ sin(x)
  proc2 <- x ~ sum(x)
  expect_that(1:10 %|>% proc1 %|>% proc2,
    is_identical_to(sum(sin(1:10))))

  # working with higher-order functions
  expect_that(1:5 %|>% (x ~ lapply(x,function(i) i+1)),
    is_identical_to(lapply(1:5,function(i) i+1)))
  expect_that(1:5 %|>% (x ~ vapply(x,function(i) c(i,i^2),numeric(2))),
    is_identical_to(vapply(1:5,function(i) c(i,i^2),numeric(2))))
  expect_that(1:5 %|>% (x ~ lapply(x,function(i) i+x)),
    is_identical_to(lapply(1:5,function(i) i+1:5)))

  ## working with ...
  fun1 <- function(x,a,b) {
    c(x+a,x+b)
  }

  fun2 <- function(x,...) {
    fun1(x,...)
  }

  expect_that(1:10 %|>% (x ~ fun2(x,a=-1,b=1)),
    is_identical_to(fun1(1:10,a=-1,b=1)))
})
