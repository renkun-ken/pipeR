#' Pipe an object forward
#'
#' The \code{\%>>\%} operator pipes the object on the left-hand side to the
#' right-hand side as either the first argument and \code{.}, or a symbol
#' defined by lambda expression.
#'
#' @param x object
#' @param expr expression
#' @details
#' \code{\%>>\%} supports the following pipline mechanisms:
#'
#' 1. Pipe to first argument:
#'
#' \code{x \%>>\% f} as \code{f(x)}
#'
#' \code{x \%>>\% f(...)} as \code{f(x,...)}
#'
#' 2. Pipe to dot (\code{.}):
#'
#' \code{x \%>>\% { expr }} as \code{\{ expr \}} given \code{. = x}
#'
#' \code{x \%>>\% ( expr )} as \code{expr} given \code{. = x}
#'
#' 3. Pipe by lambda expression:
#'
#' \code{x \%>>\% (p ~ expr)} as \code{expr} given \code{p = x}
#'
#' 4. Pipe for side-effect:
#'
#' \code{x \%>>\% (~ expr)} as \code{\{expr; x\}} given \code{. = x}
#'
#' \code{x \%>>\% (~ p ~ expr)} as \code{\{expr; x\}} given \code{p = x}
#'
#' 5. Pipe for element extraction:
#'
#' \code{x \%>>\% (name)} as \code{x[["name"]]} when \code{x} is
#' \code{list}, \code{environment}, \code{data.frame}, etc; and
#' \code{x@@name} when \code{x} is S4 object.
#'
#' 6. Pipe for questioning:
#'
#' \code{x \%>>\% (? expr)} will print the value of \code{expr} and
#' return \code{x}, just like a question.
#'
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
#' # (in this case, parentheses are required)
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
#' lambda expression in the form of x ~ f(x).
#' rnorm(100) %>>% (x ~ plot(x,col="red",main=length(x)))
#'
#' # Pipe to an expression for side effect and return
#' # the input object
#' rnorm(100) %>>%
#'   (~ cat("Number of points:",length(.))) %>>%
#'   summary()
#'
#' rnorm(100) %>>%
#'   (~ x ~ cat("Number of points:",length(x))) %>>%
#'   summary()
#'
#' # Pipe for element extraction
#' mtcars %>>% (mpg)
#'
#' # Pipe for questioning
#' rnorm(100) %>>%
#'   (? summary(.)) %>>%
#'   plot(col="red")
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
