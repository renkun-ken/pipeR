setnames <- `names<-`
setclass <- `class<-`

pipe.first <- function(x,fun,envir) {
  fun <- setclass(fun,"list")
  eval(as.call(c(fun[1L],quote(.),fun[-1L])),
    envir=list(.=x),enclos = envir)
}

pipe.dot <- function(.,expr,envir) {
  eval(expr,list(.=.),envir)
}

eval.labmda <- function(x,symbol,expr,envir) {
  eval(expr,setnames(list(x),as.character.default(symbol)),envir)
}

pipe.lambda <- function(x,expr,envir) {
  if(is.call(expr)) {
    symbol <- as.character.default(expr[[1L]])
    if(length(symbol) == 1L) {
      if(symbol == "~") {
        return(eval.labmda(x,expr[[2L]],expr[[3L]],envir))
      } else if(symbol == "<-") {
        return(eval.labmda(x,expr[[3L]],expr[[2L]],envir))
      }
    }
  }
  eval(expr,list(.=x),envir)
}

pipe.op <- function(x,expr) {
  expr <- substitute(expr)
  if(is.call(expr)) {
    symbol <- as.character.default(expr[[1L]])
    if(length(symbol) == 1L) {
      if(symbol == "{") {
        return(pipe.dot(x,expr,parent.frame()))
      } else if(symbol == "(") {
        return(pipe.lambda(x,expr[[2L]],parent.frame()))
      }
    }
  }
  pipe.first(x,expr,parent.frame())
}
