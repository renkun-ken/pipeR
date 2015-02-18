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
  expect_identical(1:5 %>>% lapply(function(i) i + 1),
    lapply(1:5, function(i) i + 1))
  expect_identical(1:5 %>>% vapply(function(i) c(i,i ^ 2), numeric(2)),
    vapply(1:5, function(i) c(i, i ^ 2), numeric(2)))

  # working with ...
  fun1 <- function(x,a,b) {
    c(x + a, x + b)
  }

  fun2 <- function(x,...) {
    fun1(x, ...)
  }

  expect_identical(1:10 %>>% fun2(a=-1,b=1), fun1(1:10,a=-1,b=1))

  # working with closures
  fun1 <- function(p) {
    f <- function(x) {
      x + p
    }
    1:3 %>>% f()
  }

  expect_equal(fun1(1), c(2,3,4))
})

test_that("lambda piping", {
  expect_identical(1:3 %>>% (c(1,2,.)), c(1,2,1:3))
  expect_identical(1:3 %>>% {
    c(1, 2, .)
  }, c(1,2,1:3))
  expect_identical(1:3 %>>% (x ~ c(1,2,x)), c(1,2,1:3))
})

test_that("side effect", {
  env <- new.env()
  side <- function(x) {
    assign("x",x+1,envir = env)
  }
  expect_equal({
    x <- 1:3 %>>% (~ side(.))
    c(x,env$x)
  }, c(1:3,2:4))
  expect_equal({
    x <- 1:3 %>>% (~ x ~ side(x))
    c(x,env$x)
  }, c(1:3,2:4))
  testthat::expect_output(1:10 %>>% "compute sum" %>>% sum, "compute sum")
})

test_that("assignment", {
  # assignment as side-effect
  expect_identical({
    x <- 1:3 %>>% (~ p) %>>% mean()
    list(x,p)
  },list(2,1:3))
  expect_identical({
    x <- 1:3 %>>% (~ p = .) %>>% mean()
    list(x,p)
  },list(2,1:3))
  expect_identical({
    x <- 1:3 %>>% (~ p = . + 1L) %>>% mean()
    list(x,p)
  },list(2,2:4))
  expect_identical({
    x <- 1:3 %>>% (~ p = m ~ m + 1L) %>>% mean()
    list(x,p)
  },list(2,2:4))

  expect_identical({
    x <- 1:3 %>>% (p = . + 1L) %>>% mean()
    list(x,p)
  },list(3,2:4))

  expect_identical({
    x <- 1:3 %>>% (p = m ~ m + 1L) %>>% mean()
    list(x,p)
  },list(3,2:4))
  expect_identical({
    x <- 1:3 %>>% (~ . + 1L -> p) %>>% mean()
    list(x,p)
  },list(2,2:4))
  expect_identical({
    x <- 1:3 %>>% (~ . -> p) %>>% mean()
    list(x,p)
  },list(2,1:3))
  expect_identical({
    x <- 1:3 %>>% (~ m ~ m + 1L -> p) %>>% mean()
    list(x,p)
  },list(2,2:4))

  expect_identical({
    x <- 1:3 %>>% (. + 1L -> p) %>>% mean()
    list(x,p)
  },list(3,2:4))
  expect_identical({
    x <- 1:3 %>>% (. -> p) %>>% mean()
    list(x,p)
  },list(2,1:3))
  expect_identical({
    m <- 0
    local({1:10 %>>% (. -> m)})
    m
  },0)
  expect_identical({
    m <- 0
    local({1:10 %>>% (. ->> m)})
    m
  },1:10)
  expect_identical({
    x <- 1:3 %>>% (m ~ m + 1L -> p) %>>% mean()
    list(x,p)
  },list(3,2:4))

  expect_identical({
    x <- 1:3 %>>% (~ p <- .) %>>% mean()
    list(x,p)
  },list(2,1:3))
  expect_identical({
    x <- 1:3 %>>% (~ p <- . + 1L) %>>% mean()
    list(x,p)
  },list(2,2:4))
  expect_identical({
    x <- 1:3 %>>% (~ p <- m ~ m + 1L) %>>% mean()
    list(x,p)
  },list(2,2:4))

  expect_identical({
    x <- 1:3 %>>% (p <- . + 1L) %>>% mean()
    list(x,p)
  },list(3,2:4))
  expect_identical({
    x <- 1:3 %>>% (p <- m ~ m + 1L) %>>% mean()
    list(x,p)
  },list(3,2:4))
})

test_that("function assignment", {
  expect_identical({
    p <- 1:3
    letters[1:3] %>>% (~ names(p) = .)
    p
  },c(a=1L,b=2L,c=3L))
  expect_identical({
    p <- 1:3
    letters[1:3] %>>% (~ names(p) <- .)
    p
  },c(a=1L,b=2L,c=3L))
  expect_identical({
    p <- 1:3
    letters[1:3] %>>% (~ . -> names(p))
    p
  },c(a=1L,b=2L,c=3L))
})

test_that("element extraction", {
  expect_equal(list(a=1)  %>>% (a),1)
  expect_equal(list2env(list(a=1)) %>>% (a),1)
  expect_equal(c(a=1) %>>% (a),1)
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

test_that("scoping", {
  expect_equal(local({ i <- 1; 1:3 %>>% c(i)}),c(1:3,1))
  expect_identical(lapply(1:3,function(i) 1:3 %>>% c(i)),
    lapply(1:3,function(i) c(1:3,i)))
  expect_equal(local({
    p <- 2
    1:3 %>>% (function(x) mean(x + . * p))
  })(1),5)
})

test_that("printing", {
  expect_output({
    z <- 1:10 %>>% (? length(.)) %>>% sum
  }, "^\\? length\\(\\.\\)\n\\[1\\] 10$")
  expect_output({
    z <- 1:10 %>>% ("length" ? length(.)) %>>% sum
  }, "^\\? length\\s*\n\\[1\\] 10$")
  expect_output({
    z <- 1:10 %>>% "numbers" %>>% sum
  }, "^numbers\\s*$")
  expect_error({
    1:10 %>>% (1 ? sum(.))
  }, "Invalid question expression")
})
