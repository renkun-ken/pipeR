#' Evaluate an expression pipeline
#'
#' Evaluate an expression pipeline enclosed by \code{\{\}} or a sequence of expressions
#' as as pipeline. This functions works to chain expressions without using \code{\%>>\%}
#' operator but produce the same result.
#'
#' @details
#' When \code{...} is missing, \code{x} should be an expression enclosed in \code{\{\}} and
#' will be evaluated as a pipeline expression, that is, the expression works as if they are
#' chained by \code{\%>>\%} operator.
#'
#' When \code{...} is not missing but given a number of function names or calls, or enclosed
#' expressions, \code{x} will be evaluated as an ordinary expression as the first object
#' being piped forward.
#'
#' @param x An object or expression
#' @param ... The expressions in pipeline. Ignored when
#' @export
#' @examples
#' pipeline(1:10, sin, sum)
#'
#' pipeline(1:10, plot(col = "red", type = "l"))
#'
#' pipeline(mtcars,
#'   lm(formula = mpg ~ cyl + wt),
#'   summary,
#'   coef)
#'
#' pipeline({
#'   mtcars
#'   lm(formula = mpg ~ cyl + wt)
#'   summary
#'   coef
#' })
#'
#' pipeline({
#'   mtcars
#'   "Sample data" ? head(., 3)
#'   lm(formula = mpg ~ cyl + wt)
#'   ~ lmodel
#'   summary
#'   ? .$r.squared
#'   coef
#' })
#'
#' pipeline({
#'  mtcars
#'  "estimating a linear model ..."
#'  lm(formula = mpg ~ cyl + wt)
#'  "summarizing the model ..."
#'  summary
#' })
pipeline <- function(x, ...) {
  if(missing(x)) return(NULL)
  x <- substitute(x)
  expr <- if(missing(...) && !is.null(x) && x == "{") x[-1L] else c(list(x), dots(...))
  expr <- Reduce(function(pl, p) as.call(list(pipe_op, pl, p)), expr)
  eval(expr, envir = parent.frame())
}
