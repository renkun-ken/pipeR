context("Free piping")

test_that("Free piping works as expected", {

  # ordinary usages
  expect_that(1:10 %:>% sin(.) %:>% sum(.),
    is_identical_to(sum(sin(1:10))))
  expect_that(iris %:>% names(.),
    is_identical_to(names(iris)))
  expect_that(iris %:>% head(.,n=3),
    is_identical_to(head(iris,n=3)))
  expect_that("a" %:>% switch(.,a=1,b=2,c=3),
    is_identical_to(switch("a",a=1,b=2,c=3)))

  # nested piping
  expect_that(1:10 %:>% c(.,c(.,c(.))),
    is_identical_to(c(1:10,c(1:10,c(1:10)))))

  # working with higher-order functions
  expect_that(1:5 %:>% lapply(.,function(i) i+1),
    is_identical_to(lapply(1:5,function(i) i+1)))
  expect_that(1:5 %:>% vapply(.,function(i) c(i,i^2),numeric(2)),
    is_identical_to(vapply(1:5,function(i) c(i,i^2),numeric(2))))
  expect_that(1:5 %:>% lapply(.,function(i) i+.),
    is_identical_to(lapply(1:5,function(i) i+1:5)))

  # piping with dots of multiple meanings
  expect_that(mtcars %:>% summary(lm(mpg~.,data=.))$fstatistic,
    is_identical_to(summary(lm(mpg~.,data=mtcars))$fstatistic))

  # working with ...
  fun1 <- function(x,a,b) {
    c(x+a,x+b)
  }

  fun2 <- function(x,...) {
    fun1(x,...)
  }

  expect_that(1:10 %:>% fun2(.,a=-1,b=1),
    is_identical_to(fun1(1:10,a=-1,b=1)))
})
