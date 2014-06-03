context("Mixed piping")

test_that("Mixed piping works as expected", {

  # ordinary usages
  expect_that(1:10 %>>%
      sin %:>% sum(.) %|>%
      (x ~ x+1),
    is_identical_to(sum(sin(1:10))+1))
  expect_that(iris %:>%
      head(.,n=3) %>>%
      names %|>%
      (x ~ paste0(x,collapse = "")),
    is_identical_to(paste0(names(head(iris,n=3)),collapse = "")))

  # working with ...
  fun1 <- function(x,a,b) {
    c(x+a,x+b)
  }

  fun2 <- function(x,...) {
    fun1(x,...)
  }

  expect_that(1:10 %:>%
      fun2(.,a=-1,b=1) %>>%
      fun2(a=1,b=-1) %|>%
      (x ~ fun2(x,a=5,b=-2)),
    is_identical_to(fun1(fun1(fun1(1:10,a=-1,b=1),a=1,b=-1),a=5,b=-2)))
})
