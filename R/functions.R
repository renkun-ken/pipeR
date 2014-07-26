setnames <- `names<-`
setclass <- `class<-`

.pipe <- function(.,fun) {
  fun <- setclass(substitute(fun),"list")
  eval(as.call(c(fun[1L],substitute(.),fun[-1L])),
    envir=parent.frame(),enclos = NULL)
}

.fpipe <- function(.,expr) {
  eval(substitute(expr),list(.=.),parent.frame())
}

.lpipe <- function(.,lambda) {
  eval(lambda[[3L]],
    setnames(list(.),as.character.default(lambda[[2L]])),
    parent.frame())
}
