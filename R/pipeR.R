#' Pipe an object forward
#'
#' The \code{\%>>\%} operator pipes the object on the left-hand side to the
#' right-hand side as either the first argument and \code{.}, or a symbol
#' defined by lambda expression.
#'
#' @param x object
#' @param expr expression
#' @details
#' Pipe operator \code{\%>>\%} determines the piping mechanism by the syntax
#' of the expression on the right-hand side.
#'
#' \code{\%>>\%} supports the following piping mechanisms:
#'
#' 1. Pipe to first argument:
#'
#' Whenever a function name or call with parameters follows the operator,
#' the left-hand side value will be piped to the right-hand side function
#' as the first unnamed argument.
#'
#' \code{x \%>>\% f} as \code{f(x)}
#'
#' \code{x \%>>\% f(...)} as \code{f(x,...)}
#'
#' 2. Pipe to dot (\code{.}):
#'
#' Whenever an expression following the operator is enclosed with \code{\{\}},
#' the expression will be evaluated with \code{.} representing the left-hand
#' side value. It is the same with expression enclosed with \code{()} unless
#' a lambda expression follows.
#'
#' \code{x \%>>\% { expr }} as \code{\{ expr \}} given \code{. = x}
#'
#' \code{x \%>>\% ( expr )} as \code{expr} given \code{. = x}
#'
#' 3. Pipe by lambda expression:
#'
#' A lambda expression is a formula whose left-hand side is a symbol used to
#' represent the value being piped and right-hand side is an expression to be
#' evaluated with the symbol.
#'
#' \code{x \%>>\% (p ~ expr)} as \code{expr} given \code{p = x}
#'
#' 4. Pipe for side-effect:
#'
#' If one only cares about the side effect (e.g. printing intermediate
#' results, plotting graphics) of an expression rather than its returned
#' value, write a lambda expression that starts with \code{~}.
#'
#' \code{x \%>>\% (~ expr)} as \code{\{expr; x\}} given \code{. = x}
#'
#' \code{x \%>>\% (~ p ~ expr)} as \code{\{expr; x\}} given \code{p = x}
#'
#' 5. Pipe for element extraction:
#'
#' If a symbol is enclosed within \code{()}, it tells the operator to
#' extract element from the left-hand side value. It works with vector,
#' list, environment and all other objects for which \code{[[]]}
#' is defined. Moreover, it also works with S4 object.
#'
#' \code{x \%>>\% (name)} as \code{x[["name"]]} when \code{x} is
#' \code{list}, \code{environment}, \code{data.frame}, etc; and
#' \code{x@@name} when \code{x} is S4 object.
#'
#' 6. Pipe for questioning:
#'
#' If a lambda expression start with \code{?}, the expression will be a side
#' effect printing the syntax and the value of the expression. This is a
#' light-weight version of side-effect piping and can be useful for simple
#' inspection and debugging for pipeline operations.
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
