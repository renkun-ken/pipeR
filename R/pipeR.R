#' Pipe an object forward as the first argument to a function
#'
#' The \code{\%.\%} operator pipes the left-hand side foward
#' and evaluates the call expression on the right-hand side
#' with the left-hand side object as the first argument.
#'
#' @param x The object to be piped
#' @param f The expression to evaluate with the piped object as the first argument.
#' @name %.%
#' @export
#' @examples
#' \dontrun{
#' rnorm(100) %.% plot
#'
#' rnorm(100) %.% plot(col="red")
#'
#' rnorm(1000) %.% sample(size=100,replace=F) %.% hist
#' }
`%.%` <- function(x,f) {
  f <- substitute(f)
  fl <- as.list(f)
  call <- as.call(c(fl[1],quote(x),fl[-1]))
  eval(call)
}

#' Pipe an object forward as `.`
#'
#' The operator \code{\%>\%} pipes the left-hand side foward
#' and evaluates the call expression on the right-hand side
#' with the left-hand side object referred to as \code{.}.
#'
#' @param x The object to be piped
#' @param f The expression to evaluate with the piped object referred to as \code{.}
#' @name %>%
#' @export
#' @examples
#' \dontrun{
#' rnorm(100) %>% plot
#'
#' rnorm(100) %>% plot(.)
#'
#' rnorm(100) %>% plot(.,col="red")
#'
#' rnorm(1000) %>% sample(.,length(.)/20,F)
#'
#' rnorm(1000) %>% sample(.,length(.)/20,F) %>% plot(.,main=sprintf("length: %d",length(.)))
#' }
`%>%` <- function(x,f) {
  f <- substitute(f)
  if(is.name(f)) {
    call <- as.call(c(f,quote(x)))
    eval(call)
  } else if(is.call(f)) {
    local({
      . <- x
      eval(f)
    })
  } else {
    stop("Invalid type of function call")
  }
}
