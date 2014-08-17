context("Performance tests")

test_that("operator", {
  cat("\nx %>>% c(y)\n")
  print(system.time(replicate(10000,
    rnorm(100) %>>% c(rnorm(100))
  )))

  cat("\nx %>>% (c(.,y))\n")
  print(system.time(replicate(10000,
    rnorm(100) %>>% (c(.,rnorm(100)))
  )))

  cat("\nx %>>% (p -> c(p,y))\n")
  print(system.time(replicate(10000,
    rnorm(100) %>>% (c(.,rnorm(100)))
  )))

  cat("\nx %>>% (y)\n")
  print(system.time(replicate(10000,
    list(a=rnorm(100)) %>>% (a)
  )))
})

test_that("Pipe", {
  cat("\nPipe(x)$c(y)\n")
  print(system.time(replicate(10000,
    Pipe(rnorm(100))$c(rnorm(100)) []
  )))

  cat("\nPipe(x)$.(c(.,y))\n")
  print(system.time(replicate(10000,
    Pipe(rnorm(100))$.(c(.,rnorm(100))) []
  )))

  cat("\nPipe(x)$.(p -> c(p,y))\n")
  print(system.time(replicate(10000,
    Pipe(rnorm(100))$.(p -> c(p,rnorm(100)))
  )))

  cat("\nPipe(x)$.(y)\n")
  print(system.time(replicate(10000,
    Pipe(list(a=rnorm(100)))$.(a)
  )))
})
