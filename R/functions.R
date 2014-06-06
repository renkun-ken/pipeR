.pipe <- function(.,fun) {
  fun <- as.list(substitute(fun))
  eval(as.call(c(fun[1],substitute(.),fun[-1])),
    envir = parent.frame(),enclos = baseenv())
}

.fpipe <- function(.,expr) {
  env <- new.env(parent = parent.frame())
  env$. <- .
  eval(substitute(expr),envir = env,enclos = baseenv())
}

.lpipe <- function(.,lambda) {
  env <- new.env(parent = parent.frame())
  assign(as.character(lambda[[2]]),.,envir = env)
  eval(lambda[[3]],envir = env,enclos = baseenv())
}
