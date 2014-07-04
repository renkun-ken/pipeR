.pipe <- function(.,fun) {
  fun <- as.vector(substitute(fun),"list")
  eval(as.call(c(fun[1L],substitute(.),fun[-1L])),
    envir = parent.frame(),enclos = NULL)
}

.fpipe <- function(.,expr) {
  env <- new.env(FALSE,parent.frame(),1L)
  env$. <- .
  eval(substitute(expr),env,NULL)
}

.lpipe <- function(.,lambda) {
  env <- new.env(FALSE,parent.frame(),1L)
  assign(as.character(lambda[[2L]]),.,envir = env)
  eval(lambda[[3L]],env,NULL)
}
