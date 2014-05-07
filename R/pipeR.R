#' Pipe an object forward as the first argument to a function
#'
#' The \code{\%>\%} operator pipes the left-hand side foward
#' and evaluates the call expression on the right-hand side
#' with the left-hand side object as the first argument.
#'
#' @param . The object to be piped as the first argument
#' @param f The expression to evaluate with the piped object as the first argument.
#' @name %>%
#' @export
#' @examples
#' \dontrun{
#' rnorm(100) %>% plot
#'
#' rnorm(100) %>% plot(col="red")
#'
#' rnorm(1000) %>% sample(size=100,replace=F) %>% hist
#' }
`%>%` <- function(.,f) {
  . <- substitute(.)
  f <- as.list(substitute(f))
  call <- as.call(c(f[1],.,f[-1]))
  eval(call,envir = parent.frame())
}

#' Pipe an object forward as `.`
#'
#' The operator \code{\%>>\%} pipes the left-hand side foward
#' and evaluates the call expression on the right-hand side
#' with the left-hand side object referred to as \code{.}.
#'
#' @param . The object to be piped as represented by \code{.}
#' @param f The expression to evaluate with the piped object referred to as \code{.}
#' @name %>>%
#' @export
#' @examples
#' \dontrun{
#' rnorm(100) %>>% plot(.)
#'
#' rnorm(100) %>>% plot(.,col="red")
#'
#' rnorm(1000) %>>% sample(.,length(.)/20,F)
#'
#' rnorm(1000) %>>%
#'   sample(.,length(.)/20,F) %>>%
#'   plot(.,main=sprintf("length: %d",length(.)))
#' }
`%>>%` <- function(.,f) {
  env <- new.env(parent = parent.frame())
  env$. <- .
  f <- substitute(f)
  eval(f,envir = env)
}

#' Pipe an object by lambda expression
#'
#' The operator \code{\%|>\%} pipes the left-hand side to the
#' symbol defined by the lambda expression on the right-hand side
#' and evaluates that expression.
#'
#' @param . The object to be piped
#' @param f The lambda expression which should always be in the form like \(x ~ g\(x\)\)
#' @name %|>%
#' @export
#' @examples
#' \dontrun{
#' rnorm(100) %|>% (x ~ plot(x))
#'
#' rnorm(100) %|>% (x ~ plot(x,col="red"))
#'
#' rnorm(1000) %|>% (pop ~ sample(pop,length(pop)*0.2,FALSE))
#'
#' rnorm(1000) %|>%
#'   (pop ~ sample(pop,length(pop)*0.2,FALSE)) %|>%
#'   (s ~ plot(s,main=sprintf("length: sample: %d",length(s))))
#' }
`%|>%` <- function(.,f) {
  env <- new.env(parent = parent.frame())
  eval(as.call(list(`<-`,f[[2]],.)),envir = env)
  eval(f[[3]],envir = env)
}
