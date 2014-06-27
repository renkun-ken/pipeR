.pipe <- function(.,fun) {
  fun <- as.vector(substitute(fun),"list")
  eval(as.call(c(fun[1],substitute(.),fun[-1])),
    envir = parent.frame(),enclos = NULL)
}

.fpipe <- function(.,expr) {
  env <- new.env(FALSE,parent.frame())
  env$. <- .
  eval(substitute(expr),envir = env,enclos = NULL)
}

.lpipe <- function(.,lambda) {
  env <- new.env(FALSE,parent = parent.frame())
  env[[as.character(lambda[[2]])]] <- .
  eval(lambda[[3]],envir = env,enclos = NULL)
}
