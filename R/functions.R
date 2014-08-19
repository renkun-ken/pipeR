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
  if(!is.name(symbol))
    stop("Invalid symbol \"",deparse(symbol),
      "\" in lambda expression", call. = FALSE)
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
    # to make a valid lambda expression,
    # its lambda symbol must be of length 1
    if(length(symbol) == 1L) {
      if(symbol == "~") {
        # formula
        if(length(expr) == 3L) {
          # (symbol ~ expr)
          lhs <- expr[[2L]]
          if(length(lhs) == 2L) {
            # symbol ~x: side effect
            eval.labmda(x,lhs[[2L]],expr[[3L]],envir)
            return(x)
          } else {
            # symbol x: lambda piping
            return(eval.labmda(x,lhs,expr[[3L]],envir))
          }
        } else {
          # ( ~ expr ): side effect
          pipe.dot(x,expr[[2L]],envir)
          return(x)
        }
      } else if(symbol == "<-") {
        # (x -> expr) will be parsed as (expr <- x)
        warning("lambda expression in form of \"x -> expr\" has been deprecated, please use \"x ~ expr\" instead, which also supports side-effect-only piping.", call. = FALSE)
        return(eval.labmda(x,expr[[3L]],expr[[2L]],envir))
      }
    }
  }

  # if no above condition holds, regard as implicit lambda expression
  # pipe to .
  pipe.dot(x,expr,envir)
}

pipe.fun <- function(x,expr,envir) {
  if(is.name(expr)) {
    # if (name), then get element from x
    getElement(x, as.character(expr))
  } else {
    # otherwise, pipe by lambda expression
    pipe.lambda(x,expr,envir)
  }
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
      if(symbol == "{") {
        # expr is enclosed with {}: pipe to dot.
        return(pipe.dot(x,expr,parent.frame()))
      } else if(symbol == "(") {
        # expr is enclosed with (): more syntax
        return(pipe.fun(x,expr[[2]],parent.frame()))
      }
    }
  }
  # if none of the conditions hold, pipe to first argument
  pipe.first(x,expr,parent.frame())
}
