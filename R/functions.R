setnames <- `names<-`
setclass <- `class<-`

# pipe to first argument
# x : object
# fun : the function name or call
# envir : environment for evaluation
pipe.first <- function(x,fun,envir) {
  fun <- setclass(fun,"list")

  ## insert x as the first argument to fun
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
  # an explict lambda expression should be a call in forms of either
  # (x -> expr) or (x ~ expr)
  if(is.call(expr)) {
    symbol <- as.character(expr[[1L]])
    # if symbol is an anonymous function, length(symbol) > 1L
    # to make a valid lambda expression, its lambda symbol must be of length 1
    if(length(symbol) == 1L) {
      # (x -> expr) will be parsed as (expr <- x)
      if(symbol == "<-")
        return(eval.labmda(x,expr[[3L]],expr[[2L]],envir))
      # (x ~ expr)
      else if(symbol == "~")
        return(eval.labmda(x,expr[[2L]],expr[[3L]],envir))
    }
  }

  # if no above condition holds, regard as implicit lambda expression
  # pipe to .
  pipe.dot(x,expr,envir)
}

# pipe function that determines the piping mechanism for the expression
# x : object
# expr : function name, call, or enclosed expression
pipe.op <- function(x,expr) {
  expr <- substitute(expr)
  # if expr in enclosed within {} or (),
  # then pipe to dot or by lambda expression.
  # note that { ... } and ( ... ) are also calls.
  if(is.call(expr)) {
    symbol <- as.character(expr[[1L]])
    if(length(symbol) == 1L) {
      # test if expr is enclosed with {},
      # if so, pipe to dot.
      if(symbol == "{") {
        return(pipe.dot(x,expr,parent.frame()))
      # test if expr is enclosed with ()
      } else if(symbol == "(") {
        lexpr <- expr[[2]]
        # if (name), then getElement, otherwise lambda piping
        if(is.name(lexpr)) {
          return(getElement(x, as.character(lexpr)))
        } else {
          return(pipe.lambda(x,lexpr,parent.frame()))
        }
      }
    }
  }
  # if none of the conditions hold, pipe to first argument
  pipe.first(x,expr,parent.frame())
}
