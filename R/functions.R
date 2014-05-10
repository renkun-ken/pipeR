.pipe <- function(.,fun) {
  . <- substitute(.)
  fun <- as.list(substitute(fun))
  call <- as.call(c(fun[1],.,fun[-1]))
  eval(call,envir = parent.frame())
}

.fpipe <- function(.,expr) {
  env <- new.env(parent = parent.frame())
  env$. <- .
  expr <- substitute(expr)
  eval(expr,envir = env)
}

.lpipe <- function(.,lambda) {
  env <- new.env(parent = parent.frame())
  eval(as.call(list(`<-`,lambda[[2]],.)),envir = env)
  eval(lambda[[3]],envir = env)
}
