.pipe <- function(.,fun) {
  fun <- as.vector(substitute(fun),"list")
  eval(as.call(c(fun[1],substitute(.),fun[-1])),
    envir = parent.frame(),enclos = NULL)
}

.fpipe <- function(.,expr) {
  env <- new.env(hash = FALSE,parent = parent.frame(),size = 1)
  assign(".",.,envir = env,inherits = FALSE)
  eval(substitute(expr),envir = env,enclos = NULL)
}

.lpipe <- function(.,lambda) {
  env <- new.env(hash = FALSE,parent = parent.frame(),size = 1)
  assign(as.character(lambda[[2]]),.,envir = env,inherits = FALSE)
  eval(lambda[[3]],envir = env,enclos = NULL)
}
