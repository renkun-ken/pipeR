#' Evaluate an expression pipeline
#'
#' Evaluate an expression pipeline enclosed by \code{\{\}} or a sequence of expressions
#' as as pipeline. This functions works to chain expressions without using \code{\%>>\%}
#' operator but produce the same result.
#'
#' @details
#' When \code{pipeline(...)} is called with multiple arguments, the arguments will be
#' regarded as pipeline expressions.
#'
#' When \code{pipeline(...)} is called with a single argument, the argument is expected to
#' be a block expression enclosed by \code{\{\}} in which each expression will be regarded
#' as a pipeline expression.
#'
#' The pipeline expressions will be chained sequentially by \code{\%>>\%} and be evaluated
#' to produce the same results as if using the pipe operator.
#'
#' @param ... Pipeline expressions. Supply multiple pipeline expressions as arguments or
#' only an enclosed expression within \code{\{\}} as the first argument.
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
pipeline <- function(...) {
  if(missing(...)) return(invisible(NULL))
  dots <- match.call(expand.dots = FALSE)$...
  if(length(dots) == 1L) {
    dots <- .subset2(dots, 1L)
    if(class(dots) == "{") dots <- .subset(dots, -1L)
    else return(eval(dots, envir = parent.frame()))
  }
  expr <- Reduce(function(pl, p) as.call(list(pipe_op, pl, p)), dots)
  eval(expr, envir = parent.frame())
}
