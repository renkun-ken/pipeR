# compatibility for data.table functions
.datatable.aware <- TRUE

#' Create a Pipe object that stores a value and allows command chaining with \code{$}.
#' @details
#' Pipe object provides object-like command chaining mechanism, which avoids using
#' external operator and can be cleaner than operator-based pipline.
#'
#' \code{Pipe()} creates a Pipe object that allows using \code{$} to perform
#' first-argument piping, call \code{.()} to evaluate an expression with \code{.}
#' or symbol defined by lambda expression, or simply extract an element from the
#' stored value. \code{$value} or \code{[]} ends a pipeline and extracts its final
#' value.
#'
#' A typical usage of Pipe object is to start with \code{Pipe()} and end with
#' \code{$value} or \code{[]}.
#'
#' \code{print()} and \code{str()} are implemented for \code{Pipe} object.
#' Use \code{header = FALSE} to suppress Pipe header message in printed results.
#' Use \code{options(Pipe.header = FASLE)} to suppress it globally.
#' @param value value to pipe (default is \code{NULL})
#' @name Pipe
#' @return Pipe object
#' @examples
#' \dontrun{
#' # Pipe as first-argument using $
#' Pipe(rnorm(100))$mean()
#' Pipe(rnorm(100))$plot(col="red")
#'
#' # Extract the value from the Pipe object using []
#' Pipe(rnorm(100))$c(4,5) []
#'
#' # Pipe to an exrepssion with . or symbol defined in
#' # lambda expression to represent the object
#' Pipe(rnorm(100))$.(1 + .) []
#' Pipe(rnorm(100))$.(x ~ 1 + x) []
#'
#' # Pipe for side effect
#' Pipe(rnorm(100))$
#'   .(~ cat("number:",length(.),"\n"))$
#'   summary()
#' Pipe(rnorm(100))$
#'   .(~ x ~ cat("number:",length(x),"\n"))$
#'   summary()
#'
#' # Extract element with \code{.(name)}
#' Pipe(mtcars)$lm(formula = mpg ~ cyl + wt)$.(coefficients)
#'
#' # Command chaining
#' Pipe(rnorm(100,mean=10))$
#'   log()$
#'   diff()$
#'   plot(col="red")
#'
#' Pipe(rnorm(100))$
#'   density(kernel = "rect")$
#'   plot(col = "blue")
#'
#' # Store an continue piping
#' pipe1 <- Pipe(rnorm(100,mean=10))$log()$diff()
#' pipe1$plot(col="red")
#'
#' # Subsetting, extracting, and assigning
#'
#' p <- Pipe(list(a=1,b=2))
#' p["a"]
#' p[["a"]]
#' p$a <- 2
#' p["b"] <- NULL
#' p[["a"]] <- 3
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
#' # Graphics with ggvis
#' library(ggvis)
#' Pipe(mtcars)$
#'   ggvis(~ mpg, ~ wt)$
#'   layer_points()
#'
#' # Data manipulation with rlist
#' library(rlist)
#' Pipe(list(1,2,3))$
#'   list.map(. + 1)$
#'   list.filter(. <= 5)$
#'   list.sort(.) []
#'
#' # Lazy evaluation
#' p1 <- Pipe(mtcars)$
#'   ggvis(~ mpg, ~ wt)
#' p1$layer_points()
#' p1$layer_bars()
#'
#' # Stored Pipe
#' f1 <- Pipe(rnorm(100))$plot
#' f1(col="red")
#' f1(col="green")
#' }
#' @export
Pipe <- function(value = NULL) {
  fun <- function(expr) {
    warning("fun() in Pipe has been deprecated, please use .() instead, which also supports side-effect piping and element extraction.", call. = FALSE)
    value <- pipe.lambda(value,substitute(expr),parent.frame())
    Pipe(value)
  }
  . <- function(expr) {
    if(!missing(expr))
      value <- pipe.fun(value,substitute(expr),parent.frame())
    Pipe(value)
  }
  .envir <- environment()
  setclass(.envir, "Pipe")
}

Pipe.value <- function(x) {
  get("value", envir = x, inherits = FALSE)
}

#' @export
`$.Pipe` <- function(x,y) {
  if(exists(y, envir = x, inherits = FALSE))
    return(get(y, envir = x, inherits = FALSE))
  f <-  get(y, envir = parent.frame(), mode = "function")
  value <- Pipe.value(x)
  function(...) {
    dots <- match.call(expand.dots = FALSE)$`...`
    rcall <- as.call(c(f,quote(value),dots))
    value <- eval(rcall,list(value = value),parent.frame())
    Pipe(value)
  }
}

Pipe.get <- function(f, value, dots, envir) {
  rcall <- as.call(c(f,quote(value),dots))
  eval(rcall,list(value = value),envir)
}

#' @export
`[.Pipe` <- function(x, ...) {
  value <- Pipe.value(x)
  dots <- match.call(expand.dots = FALSE)$`...`
  if(ndots(dots)) {
    value <- Pipe.get(`[`,value,dots,parent.frame())
    Pipe(value)
  } else {
    value
  }
}

#' @export
`[[.Pipe` <- function(x, ...) {
  value <- Pipe.value(x)
  dots <- match.call(expand.dots = FALSE)$`...`
  if(ndots(dots)) {
    value <- Pipe.get(`[[`,value,dots,parent.frame())
    Pipe(value)
  } else {
    value
  }
}

#' @export
print.Pipe <- function(x,...,header=getOption("Pipe.header",TRUE)) {
  value <- Pipe.value(x)
  if(!is.null(value)) {
    if(header) cat("$value :",class(value),"\n------\n")
    print(value,...)
  }
}

#' @export
str.Pipe <- function(object,...,header=getOption("Pipe.header",TRUE)) {
  if(header) cat("$value : ")
  str(Pipe.value(object),...)
}


Pipe.set <- function(f, x, dots, value, envir) {
  rcall <- as.call(c(f,quote(x),dots,quote(value)))
  eval(rcall,list(x = x, value = value),envir)
}

#' @export
`$<-.Pipe` <- function(x,...,value) {
  dots <- match.call(expand.dots = FALSE)$`...`
  if(ndots(dots))
    value <- Pipe.set(`$<-`, Pipe.value(x), dots, value, parent.frame())
  Pipe(value)
}

#' @export
`[<-.Pipe` <- function(x,...,value) {
  dots <- match.call(expand.dots = FALSE)$`...`
  if(ndots(dots))
    value <- Pipe.set(`[<-`, Pipe.value(x), dots, value, parent.frame())
  Pipe(value)
}

#' @export
`[[<-.Pipe` <- function(x,...,value) {
  dots <- match.call(expand.dots = FALSE)$`...`
  if(ndots(dots))
    value <- Pipe.set(`[[<-`, Pipe.value(x), dots, value, parent.frame())
  Pipe(value)
}
