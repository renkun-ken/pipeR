setnames <- `names<-`
setclass <- `class<-`

.pipe <- function(x,fun) {
  fun <- setclass(substitute(fun),"list")
  eval(as.call(c(fun[1L],quote(x),fun[-1L])),
    envir=list(x=x),enclos = parent.frame())
}

.fpipe <- function(.,expr) {
  eval(substitute(expr),list(.=.),parent.frame())
}

.lpipe <- function(x,lambda) {
  eval(lambda[[3L]],
    setnames(list(x),as.character.default(lambda[[2L]])),
    parent.frame())
}
