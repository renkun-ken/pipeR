setnames <- `names<-`
setclass <- `class<-`

# pipe to first argument
# x : object
# fun : the function name or call
# envir : environment for evaluation
pipe.first <- function(x,fun,envir) {
  fun <- setclass(fun,"list")
  eval(as.call(c(fun[1L],quote(.),fun[-1L])),
    envir=list(.=x),enclos = envir)
}

# pipe to dot
# . : object
# expr : expression
# envir : environment for evaluation
pipe.dot <- function(.,expr,envir) {
  eval(expr,list(.=.),envir)
}

# evaluate lambda expression
# x : object
# symbol : symbol part
# expr : expression part
# envir : environment for evaluation
eval.labmda <- function(x,symbol,expr,envir) {
  eval(expr,setnames(list(x),as.character(symbol)),envir)
}

# pipe by lambda expression
# x : object
# expr : lambda expression
# envir : environment for evaluation
pipe.lambda <- function(x,expr,envir) {
  if(is.call(expr)) {
    symbol <- as.character(expr[[1L]])
    if(length(symbol) == 1L) {
      if(symbol == "<-")
        return(eval.labmda(x,expr[[3L]],expr[[2L]],envir))
      else if(symbol == "~")
        return(eval.labmda(x,expr[[2L]],expr[[3L]],envir))
    }
  }
  eval(expr,list(.=x),envir)
}

# pipe function that determines the piping mechanism for the expression
# x : object
# expr : function name, call, or enclosed expression
pipe.op <- function(x,expr) {
  expr <- substitute(expr)
  if(is.call(expr)) {
    symbol <- as.character(expr[[1L]])
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
