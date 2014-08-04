#' Pipe an object forward
#'
#' The \code{\%>>\%} operator pipes the object on the left-hand side to the
#' right-hand side as either the first argument or a symbol defined by lambda
#' expression.
#'
#' @param x object
#' @param expr expression
#' @export
#' @examples
#' \dontrun{
#' # Pipe as first-argument to a function name
#' rnorm(100) %>>% plot
#'
#' # Pipe as first-argument to a function call
#' rnorm(100) %>>% plot()
#' rnorm(100) %>>% plot(col="red")
#' rnorm(100) %>>% plot(col="red",main=length(.))
#'
#' # Pipe as first-argument to a function call in namespace
#' rnorm(100) %>>% base::mean()
#'
#' # Pipe to an expression enclosed by braces with .
#' representing the piped object
#' rnorm(100) %>>% { plot(.,col="red",main=length(.)) }
#'
#' # Pipe to an expression enclosed by parentheses with .
#' representing the piped object
#' rnorm(100) %>>% (plot(.,col="red",main=length(.)))
#'
#' # Pipe to an expression enclosed by parentheses with
#' lambda expression in the form of x -> f(x) or x ~ f(x).
#' rnorm(100) %>>% (x -> plot(x,col="red",main=length(x)))
#' rnorm(100) %>>% (x ~ plot(x,col="red",main=length(x)))
#'
#' # Pipe to fun to use lambda expression
#' rnorm(100) %>>% fun(. + 1)
#' rnorm(100) %>>% fun(x -> x + 1)
#' rnorm(100) %>>% fun(x ~ x + 1)
#'
#' # Pipe to an anomymous function
#' rnorm(100) %>>% (function(x) mean(x))()
#' rnorm(100) %>>% {function(x) mean(x)}()
#'
#' # Pipe to an enclosed function to make a closure
#' z <- rnorm(100) %>>% (function(x) mean(x+.))
#' z(1) # 3
#'
#' z <- rnorm(100) %>>% {function(x) mean(x+.)}
#' z(1) # 3
#'
#' # Data manipulation with dplyr
#' library(dplyr)
#' iris %>>%
#'   mutate(Sepal.Size=Sepal.Length*Sepal.Width,
#'     Petal.Size=Petal.Length*Petal.Width) %>>%
#'   select(Sepal.Size,Petal.Size,Species) %>>%
#'   group_by(Species) %>>%
#'   do(arrange(.,desc(Sepal.Size+Petal.Size)) %>>% head(3))
#'
#' # Data manipulation with rlist
#' library(rlist)
#' list(1,2,3) %>>%
#'   list.map(. + 1) %>>%
#'   list.filter(. <= 5) %>>%
#'   list.sort(.)
#' }
`%>>%` <- pipe.op
