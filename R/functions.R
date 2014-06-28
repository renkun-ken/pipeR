.pipe <- function(.,fun) {
  fun <- as.vector(substitute(fun),"list")
  eval(as.call(c(fun[1],substitute(.),fun[-1])),
    envir = parent.frame(),enclos = NULL)
}

.fpipe <- function(.,expr) {
  eval(substitute(expr),
    envir=list2env(list(.=.),envir=parent.frame()),
    enclos = NULL)
}

.lpipe <- function(.,lambda) {
  eval(lambda[[3]],
    envir = list2env(`names<-`(list(.),
      as.character(lambda[[2]])),envir = parent.frame()),
    enclos = NULL)
}
