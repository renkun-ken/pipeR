context("Pipe tests")

test_that("first-argument piping", {

  # ordinary usages
  expect_identical(Pipe(1:10)$sin()$sum()[], sum(sin(1:10)))
  expect_identical(Pipe(1:3)$c(1,.)[],c(1:3,1,1:3))
  expect_identical(Pipe(iris)$names()[], names(iris))
  expect_identical(Pipe(iris)$head(n=3)[],head(iris,n=3))
  expect_identical(Pipe("a")$switch(a=1,b=2,c=3)[],switch("a",a=1,b=2,c=3))

  expect_identical(Pipe(1:3)$.(base::mean(.))[], mean(1:3))
  expect_identical(Pipe(1:3)$.(c(1,2,.))[], c(1,2,1:3))

  # working with higher-order functions
  expect_identical(Pipe(1:5)$lapply(function(i) i+1)[], lapply(1:5,function(i) i+1))
  expect_identical(Pipe(1:5)$vapply(function(i) c(i,i^2),numeric(2))[],
    vapply(1:5,function(i) c(i,i^2),numeric(2)))

  # working with ...
  fun1 <- function(x,a,b) {
    c(x+a,x+b)
  }

  fun2 <- function(x,...) {
    fun1(x,...)
  }

  expect_identical(Pipe(1:10)$fun2(a=-1,b=1)[], fun1(1:10,a=-1,b=1))

  # working with closures
  fun1 <- function(p) {
    f <- function(x) {
      x+p
    }
    Pipe(1:3)$f()$value
  }

  expect_equal(fun1(1), c(2,3,4))
})

test_that("lambda piping", {
  expect_identical(Pipe(1:3)$.(c(1,2,.))[], c(1,2,1:3))
  expect_identical(Pipe(1:3)$.(x ~ c(1,2,x))[], c(1,2,1:3))
})

test_that("side effect", {
  side <- function(x) {
    x + 1
  }
  expect_equal(Pipe(1:3)$.(~ side(.))$value, 1:3)
  expect_equal(Pipe(1:3)$.(~ x ~ side(x))$value, 1:3)
})

test_that("element extraction", {
  expect_equal(Pipe(list(a=1))$.(a)$value,1)
  expect_equal(Pipe(list2env(list(a=1)))$.(a)$value,1)
  expect_equal(Pipe(c(a=1))$.(a)$value,1)
})

test_that("subsetting", {
  expect_identical(Pipe(list(a=1,b=2))["a"]$value,list(a=1))
  expect_identical(Pipe(c(a=1,b=2))["a"]$value,c(a=1))
  expect_identical(Pipe(c(a=1,b=2))[length(.)]$value,c(b=2))
})

test_that("extracting", {
  expect_identical(Pipe(list(a=1,b=2))[["a"]]$value,1)
  expect_identical(Pipe(list2env(list(a=1,b=2)))[["a"]]$value,1)
  expect_identical(Pipe(c(a=1,b=2))[[length(.)]]$value,2)
})

test_that("element assignment", {
  expect_identical({
    z <- Pipe(list(a=1,b=2))
    z$a <- 2
    z$b <- NULL
    z$value
  },list(a=2))
  expect_equal({
    z <- new.env()
    env <- Pipe(z)
    env$a <- 1
    env$value$a
  },1)
  expect_identical({
    z <- Pipe(c(a=1,b=2))
    z["a"] <- 2
    z[length(.)] <- 3
    z$value
  },c(a=2,b=3))
  expect_identical({
    z <- Pipe(c(a=1,b=2))
    z[["a"]] <- 2
    z[[length(.)]] <- 3
    z$value
  },c(a=2,b=3))
})

test_that("assignment", {
  # assignment as side-effect
  expect_identical({
    x <- Pipe(1:3)$.(~ p)$mean()$value
    list(x,p)
  },list(2,1:3))
  expect_identical({
    x <- Pipe(1:3)$.(~ . + 1L -> p)$mean()$value
    list(x,p)
  },list(2,2:4))
  expect_identical({
    x <- Pipe(1:3)$.(~ m ~ m + 1L -> p)$mean()$value
    list(x,p)
  },list(2,2:4))

  expect_identical({
    x <- Pipe(1:3)$.(. + 1L -> p)$mean()$value
    list(x,p)
  },list(3,2:4))
  expect_identical({
    x <- Pipe(1:3)$.(m ~ m + 1L -> p)$mean()$value
    list(x,p)
  },list(3,2:4))

  expect_identical({
    x <- Pipe(1:3)$.(~ p <- . + 1L)$mean()$value
    list(x,p)
  },list(2,2:4))
  expect_identical({
    x <- Pipe(1:3)$.(~ p <- m ~ m + 1L)$mean()$value
    list(x,p)
  },list(2,2:4))

  expect_identical({
    x <- Pipe(1:3)$.(p <- . + 1L)$mean()$value
    list(x,p)
  },list(3,2:4))
  expect_identical({
    x <- Pipe(1:3)$.(p <- m ~ m + 1L)$mean()$value
    list(x,p)
  },list(3,2:4))
})

test_that("function", {
  # closure
  expect_identical({
    z <- Pipe(1:3)$.(p ~ function(x) mean(x+p))[]
    z(3)
  }, 5)
})

test_that("scoping", {
  p <- function(x) 1L
  pobj <- Pipe(0)$p
  expect_identical(pobj()$value,1L)
  expect_identical(local({p <- function(x) 0L; pobj()$value}),1L)
  expect_identical(local({p <- function(x) 0L; Pipe(0)$p()$value}),0L)
})
