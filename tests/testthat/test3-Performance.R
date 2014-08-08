context("Performance tests")

test_that("operator", {
  cat("\nx %>>% c(y)\n")
  print(system.time(lapply(1:10000,function(i) {
    rnorm(100) %>>% c(rnorm(100))
  })))

  cat("\nx %>>% (c(.,y))\n")
  print(system.time(lapply(1:10000,function(i) {
    rnorm(100) %>>% (c(.,rnorm(100)))
  })))

  cat("\nx %>>% (p -> c(p,y))\n")
  print(system.time(lapply(1:10000,function(i) {
    rnorm(100) %>>% (c(.,rnorm(100)))
  })))
})

test_that("Pipe", {
  cat("\nPipe(x)$c(y)\n")
  print(system.time(lapply(1:10000,function(i) {
    Pipe(rnorm(100))$c(rnorm(100)) []
  })))

  cat("\nPipe(x)$fun(c(.,y))\n")
  print(system.time(lapply(1:10000,function(i) {
    Pipe(rnorm(100))$fun(c(.,rnorm(100))) []
  })))

  cat("\nPipe(x)$fun(p -> c(p,y))\n")
  print(system.time(lapply(1:10000,function(i) {
    Pipe(rnorm(100))$fun(p -> c(p,rnorm(100)))
  })))
})
