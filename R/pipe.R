#' Create a Pipe object that stores a value and allows command chaining with \code{$}.
#' @details
#' \code{Pipe()} function creates a Pipe object that provides object-like command
#' chaining mechanism, which avoids using external operator and can be cleaner than
#' operator-based pipline.
#'
#' \code{Pipe()} creates a Pipe object that allows using \code{$} to perform
#' first-argument piping, call \code{.()} to evaluate an expression with \code{.}
#' or symbol defined by lambda expression, for side effect, or simply extract an
#' element from the stored value. \code{$value} or \code{[]} ends a pipeline and
#' extracts its final value.
#'
#' The functionality of Pipe object fully covers that of the pipe operator \code{\%>>\%}
#' and provides more features. For example, Pipe object supports directly subsetting
#' \code{$value} by \code{[...]}, extracting element by \code{[[...]]}, and assigning value
#' by \code{$item <-}, \code{[...] <-}, and \code{[[...]] <-}.
#'
#' A typical usage of Pipe object is to start with \code{Pipe()} and end with
#' \code{$value} or \code{[]}.
#'
#' \code{print()} and \code{str()} are implemented for \code{Pipe} object.
#' Use \code{header = FALSE} to suppress Pipe header message in printed results.
#' Use \code{options(Pipe.header = FASLE)} to suppress it globally.
#'
#' If the Pipe object is used in more than one pipelines, a recommended usage is to name the
#' object specially so that it is easy to distinguish the Pipe object from the value it
#' stores. For example, it can start with \code{p}.
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
#'
#' Pipe(rnorm(100))$
#'   .(~ x ~ cat("number:",length(x),"\n"))$
#'   summary()
#'
#' # Assignment
#' Pipe(rnorm(100))$
#'   .(~ x)$
#'   mean()
#'
#' Pipe(rnorm(100))$
#'   .(~ x <- length(.))$
#'   mean()
#'
#' Pipe(rnorm(100))%
#'   .(x <- c(min(.),max(.)))$
#'   mean()
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
#' p[length(.)] # . = p$value
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
  .envir <- environment()
  .visible <- TRUE
  . <- Pipe_dot(value, .envir)
  setclass(.envir, c("Pipe","environment"))
}

Pipe_dot <- function(value, envir) {
  function(expr) {
    if(missing(expr)) return(envir)
    args <- withVisible(pipe_fun(value, substitute(expr), parent.frame()))
    Pipe_new(args)
  }
}

Pipe_closure <- function(f, args) {
  f <- as.symbol(f)
  function(...) {
    dots <- match.call(expand.dots = FALSE)$...
    rcall <- as.call(c(f, quote(.), dots))
    args <- withVisible(eval(rcall, args, parent.frame()))
    Pipe_new(args)
  }
}

Pipe_new <- function(args) {
  x <- Pipe(args$value)
  assign(".visible", args$visible, envir = x)
  x
}

Pipe_value <- function(x) {
  get("value", envir = x, inherits = FALSE)
}

Pipe_visible <- function(x) {
  get(".visible", envir = x, mode = "logical", inherits = FALSE)
}

#' @export
`$.Pipe` <- function(x, i) {
  if(exists(i, envir = x, inherits = FALSE))
    return(get(i, envir = x, inherits = FALSE))
  f <- get(i, envir = parent.frame(), mode = "function")
  args <- setnames(list(f, Pipe_value(x)), c(i, "."))
  Pipe_closure(i, args)
}

Pipe_get <- function(f, value, dots, envir) {
  if(!ndots(dots)) return(value)
  rcall <- as.call(c(f, quote(.), dots))
  args <- withVisible(eval(rcall, list(. = value), envir))
  Pipe_new(args)
}

Pipe_get_function <- function(op) {
  op <- as.symbol(op)
  function(x, ...) {
    value <- Pipe_value(x)
    dots <- match.call(expand.dots = FALSE)$...
    Pipe_get(op, value, dots, parent.frame())
  }
}

#' @export
`[.Pipe` <- Pipe_get_function("[")

#' @export
`[[.Pipe` <- Pipe_get_function("[[")


Pipe_set <- function(f, x, dots, value, envir) {
  if(!ndots(dots)) return(value)
  rcall <- as.call(c(f,quote(.), dots, quote(value)))
  args <- withVisible(eval(rcall,list(. = x, value = value), envir))
  Pipe_new(args)
}

Pipe_set_function <- function(op) {
  op <- as.symbol(op)
  function(x,...,value) {
    dots <- match.call(expand.dots = FALSE)$...
    Pipe_set(op, Pipe_value(x), dots, value, parent.frame())
  }
}

#' @export
`$<-.Pipe` <- Pipe_set_function("$<-")

#' @export
`[<-.Pipe` <- Pipe_set_function("[<-")

#' @export
`[[<-.Pipe` <- Pipe_set_function("[[<-")


#' @export
print.Pipe <- function(x,...,header=getOption("Pipe.header",TRUE)) {
  value <- Pipe_value(x)
  if(Pipe_visible(x)) {
    if(header) {
      cat("<Pipe:", class(value))
      cat(">\n")
    }
    print(value,...)
  }
}

#' @export
str.Pipe <- function(object,...,header=getOption("Pipe.header",TRUE)) {
  if(header) cat("<Pipe>\n")
  str(Pipe_value(object),...)
}
