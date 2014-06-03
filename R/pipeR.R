#' Pipe an object forward as the first argument to a function
#'
#' The \code{\%>>\%} operator evaluates the function call on the right-hand side
#' with the left-hand side object being the first argument.
#'
#' @param . The object to be piped as the first argument
#' @param fun The function call to evaluate with the piped object as the first argument.
#' @name first-argument piping
#' @export
#' @examples
#' \dontrun{
#' rnorm(100) %>>% plot
#'
#' rnorm(100) %>>% plot(col="red")
#'
#' rnorm(1000) %>>% sample(size=100,replace=F) %>>% hist
#' }
`%>>%` <- .pipe

#' Pipe an object forward as `.` to an expression
#'
#' The operator \code{\%:>\%} evaluates the expression on the right-hand side
#' with the left-hand side object referred to as \code{.}.
#'
#' @param . The object to be piped as represented by \code{.}
#' @param expr The expression to evaluate with the piped object referred to as \code{.}
#' @name free-piping
#' @export
#' @examples
#' \dontrun{
#' rnorm(100) %:>% plot(.)
#'
#' rnorm(100) %:>% plot(.,col="red")
#'
#' rnorm(1000) %:>% sample(.,size=length(.)*0.1,replace=FALSE)
#'
#' rnorm(1000) %:>%
#'   sample(.,length(.)*0.1,FALSE) %>>%
#'   plot(.,main=sprintf("length: %d",length(.)))
#' }
`%:>%` <- .fpipe

#' Pipe an object by lambda expression
#'
#' The operator \code{\%|>\%} pipes the left-hand side to the
#' symbol defined by the lambda expression on the right-hand side
#' and evaluates the target expression.
#'
#' @param . The object to be piped
#' @param lambda The lambda expression which should always be in the form like \(x ~ g\(x\)\)
#' @name lambda-piping
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
`%|>%` <- .lpipe
