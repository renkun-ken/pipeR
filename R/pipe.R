#' Evaluate a lambda expression for Pipe object
#' @param value value
#' @param expr the lambda expression in the following forms:
#'
#' 1. An expression with \code{.} representing \code{value}
#'
#' 2. \code{x -> f(x)}
#'
#' 3. \code{x ~ f(x)}
#' @param envir the environment to evaluate \code{expr}.
#' @export
fun <- function(value, expr, envir = parent.frame(2L)) {
  pipe.lambda(value,substitute(expr),envir)
}

#' Pipe object
#' @details
#' Pipe object provides object-based mechanism for command chaining, which avoids using
#' external operator and look simpler.
#'
#' \code{Pipe()} creates a Pipe object and then we can use \code{$} to perform
#' first-argument piping, call \code{fun()} to evaluate an expression with \code{.}
#' or symbol defined by lambda expression. \code{[]} ends a pipeline and extracts
#' its final value.
#'
#' A typical usage of Pipe object is to start with \code{Pipe()} and end with
#' \code{[]}.
#' @param value value to pipe (default is \code{NULL})
#' @name Pipe
#' @return Pipe object
#' @examples
#' # Pipe as first-argument using $
#' Pipe(rnorm(100))$mean()
#' Pipe(rnorm(100))$plot(col="red")
#'
#' # Extract the value from the Pipe object using []
#' Pipe(rnorm(100))$c(4,5) []
#'
#' # Pipe to an exrepssion with . or symbol defined in
#' # lambda expression to represent the object
#' Pipe(rnorm(100))$fun(1 + .) []
#' Pipe(rnorm(100))$fun(x -> 1 + x) []
#' Pipe(rnorm(100))$fun(x ~ 1 + x) []
#'
#' # Command chaining
#' Pipe(rnorm(100,mean=10))$
#'   log()$
#'   diff()$
#'   plot(col="red")
#'
#' # Store an continue piping
#' pipe1 <- Pipe(rnorm(100,mean=10))$log()$diff()
#' pipe1$plot(col="red")
#'
#' # Data manipulation with dplyr
#' library(dplyr)
#' Pipe(mtcars)$
#'   select(mpg,cyl,disp,hp)$
#'   filter(mpg <= median(mpg))$
#'   mutate(rmpg = mpg / max(mpg))$
#'   group_by(cyl)$
#'   do(data.frame(mean=mean(.$rmpg),median=median(.$rmpg))) []
#'
#' # Data manipulation with rlist
#' library(rlist)
#' Pipe(list(1,2,3))$
#'   list.map(. + 1)$
#'   list.filter(. <= 5)$
#'   list.sort(.) []
#' @export
Pipe <- function(value = NULL) {
  envir <- environment()
  setclass(envir, "Pipe")
}

#' @export
`$.Pipe` <- function(x,y) {
  f <-  get(y,envir = parent.frame(),mode = "function",inherits = TRUE)
  value <- get("value",envir = x,inherits = FALSE)
  function(...) {
    value <- f(value,...)
    Pipe(value)
  }
}

#' @export
`[.Pipe` <- function(x,...)
  get("value",envir = x,inherits = FALSE)


#' @export
print.Pipe <- function(x,...) {
  value <- get("value",envir = x,inherits = FALSE)
  if(!is.null(value)) {
    cat("<Pipe>\n[] :",class(value),"\n")
    print(value,...)
  }
}
