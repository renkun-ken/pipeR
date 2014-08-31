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
  if(!is.symbol(symbol))
    stop("Invalid symbol \"",deparse(symbol),
      "\" in lambda expression", call. = FALSE)
  eval(expr,setnames(list(x),as.character(symbol)),envir)
}

# pipe by lambda expression
# x : object
# expr : lambda expression
# envir : environment for evaluation
pipe.lambda <- function(x,expr,envir) {
  # ( symbol ): extract element
  if(is.symbol(expr)) return(getElement(x, as.character(expr)))

  # an explict lambda expression should be a call in forms of either
  # (x -> expr) or (x ~ expr)
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
        rhs <- expr[[3L]]
        if(length(lhs) == 2L && as.character(lhs) == "~") {
          # ~ expr: side effect
          eval.labmda(x,lhs[[2L]],rhs,envir)
          return(x)
        } else {
          # expr: lambda piping
          return(eval.labmda(x,lhs,rhs,envir))
        }
      } else {
        expr <- expr[[2L]]
        if(is.symbol(expr)) {
          # ~ symbol: assign
          assign(as.character(expr), x, envir = envir)
        } else {
          # ~ expr: side effect
          pipe.dot(x,expr,envir)
        }
        return(x)
      }
    } else if(symbol == "<-") {
      # (x -> expr) will be parsed as (expr <- x)
      warning("lambda expression in form of \"x -> expr\" has been deprecated, please use \"x ~ expr\" instead, which also supports side-effect-only piping.", call. = FALSE)
      return(eval.labmda(x,expr[[3L]],expr[[2L]],envir))
    } else if(symbol == "?") {
      value <- Recall(x,expr[[2L]],envir)
      cat("? ")
      print(expr[[2L]])
      print(value)
      return(x)
    } else if(symbol == "=") {
      lhs <- expr[[2L]]
      value <- Recall(x, expr[[3L]], envir)
      if(length(lhs) == 2L &&  as.character(lhs) == "~") {
        call <- as.call(list(quote(`<-`),lhs[[2L]],value))
        eval(call,envir)
        return(x)
      } else {
        call <- as.call(list(quote(`<-`),lhs,value))
        return(eval(call,envir))
      }
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
  envir <- parent.frame()
  # if expr in enclosed within {} or (),
  # then pipe to dot or by lambda expression.
  # note that { ... } and ( ... ) are also calls.
  if(is.call(expr)) {
    symbol <- as.character(expr[[1L]])
    if(length(symbol) == 1L) {
      if(symbol == "{") {
        # expr is enclosed with {}: pipe to dot.
        return(pipe.dot(x,expr,envir))
      } else if(symbol == "(") {
        # expr is enclosed with (): more syntax
        return(pipe.lambda(x,expr[[2]],envir))
      }
    }
  }
  # if none of the conditions hold, pipe to first argument
  pipe.first(x,expr,envir)
}
