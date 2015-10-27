#' Pipe an object forward
#'
#' The \code{\%>>\%} operator pipes the object on the left-hand side to the
#' right-hand side according to the syntax.
#'
#' @param x object
#' @param expr expression
#' @details
#' Pipe operator \code{\%>>\%} determines the piping mechanism by the syntax
#' of the expression on the right-hand side.
#'
#' \code{\%>>\%} supports the following syntaxes:
#'
#' 1. Pipe to first unnamed argument:
#'
#' Whenever a function name or call with or without parameters follows
#' the operator, the left-hand side value will be piped to the right-hand
#' side function as the first unnamed argument.
#'
#' \code{x \%>>\% f} evaluated as \code{f(x)}
#'
#' \code{x \%>>\% f(...)} evaluated as \code{f(x,...)}
#'
#' \code{x \%>>\% package::name(...)} evaluated as \code{package::name(x, ...)}
#'
#' 2. Pipe to \code{.} in enclosed expression:
#'
#' Whenever an expression following the operator is enclosed by \code{\{\}},
#' the expression will be evaluated with \code{.} representing the left-hand
#' side value. It is the same with expression enclosed with \code{()} unless
#' it contains a lambda expression or assignment expression.
#'
#' \code{x \%>>\% { expr }} evaluated as \code{\{ expr \}} given \code{. = x}
#'
#' \code{x \%>>\% ( expr )} evaluated as \code{expr} given \code{. = x}
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
#' results, plotting graphics, assigning value to symbol) of an expression
#' rather than its returned value, write a lambda expression that starts
#' with \code{~} indicating side effect (or branching, in the sense of
#' pipeline building).
#'
#' \code{x \%>>\% (~ f(.))} evaluated as \code{\{f(x); x\}}.
#'
#' \code{x \%>>\% (~ p ~ f(p))} evaluated as \code{\{f(x); x\}}
#'
#' 5. Pipe for assignment
#'
#' Equal operator (\code{=}) and assignment operators (\code{<-} and \code{->}) perform assignment.
#' This is particularly useful when one needs to save an intermediate value in the middle
#' of a pipeline without breaking it.
#'
#' Assignment as side-effect
#'
#' In general, \code{x \%>>\% (~ y = ...)} is evaluated as
#' \code{y <- x \%>>\% (...)} and returns \code{x}.
#'
#' \code{x \%>>\% (~ y)} evaluated as \code{y <- x} and returns \code{x},
#' where \code{y} must be a symbol.
#'
#' \code{x \%>>\% (~ y = f(.))} evaluated as \code{y <- f(x)} and returns
#' \code{x}.
#'
#' \code{x \%>>\% (~ y = p ~ f(p))} evaluated as \code{y <- f(x)} and
#' returns \code{x}.
#'
#' Piping with assignment
#'
#' In general, \code{x \%>>\% (y = ...)} is evaluated as
#' \code{y <- x \%>>\% (...)}.
#'
#' \code{x \%>>\% (y = f(.))} evaluated as \code{y <- f(x)} and returns
#' \code{f(x)}.
#'
#' \code{x \%>>\% (y = p ~ f(p))} evaluated as \code{y <- f(x)} and returns
#' \code{f(x)}.
#'
#' The equal sign above can be interchangeably used as the assignment operator \code{<-}.
#' Note that the global assignment operator \code{<<-} and \code{->>} in a pipeline also
#' performs global assignment that is subject to side-effect outside the calling
#' environment.
#'
#' In some cases, users might need to create a group of symbols. The following code
#' calls \code{assign} to dynamically determine the symbol name when its value is
#' evaluated.
#'
#' \code{for (i in 1:5) rnorm(i) \%>>\% (assign(paste0("rnorm", i), .))}
#'
#' 6. Pipe for element extraction:
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
#' 7. Pipe to string:
#'
#' If an object is piped to a single \code{character} value, then the string will
#' be \code{cat()} and starts a new paragraph. This is useful for indicating the
#' executing process of a pipeline.
#'
#' \code{x \%>>\% "print something" \%>>\% f(y)} will \code{cat("print something")}
#' and then evaluate \code{f(x,y)}.
#'
#' 8. Pipe for questioning:
#'
#' If a lambda expression start with \code{?}, the expression will be a side
#' effect printing the syntax and the value of the expression. This is a
#' light-weight version of side-effect piping and can be useful for simple
#' inspection and debugging for pipeline operations.
#'
#' \code{x \%>>\% (? expr)} will print the value of \code{expr} and
#' return \code{x}, just like a question.
#'
#' \code{x \%>>\% ("title" ? expr)} will print \code{"title"} as the question, the
#' value of \code{expr}, and return \code{x}.
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
#' # Pipe to . in an expression enclosed by braces
#' representing the piped object
#' rnorm(100) %>>% { plot(.,col="red",main=length(.)) }
#'
#' # Pipe to . in an expression enclosed by parentheses
#' representing the piped object
#' rnorm(100) %>>% (plot(.,col="red",main=length(.)))
#'
#' # Pipe to an expression enclosed by parentheses with
#' lambda expression in the form of x ~ f(x).
#' rnorm(100) %>>% (x ~ plot(x,col="red",main=length(x)))
#'
#' # Pipe to an expression for side effect and return
#' # the input value
#' rnorm(100) %>>%
#'   (~ cat("Number of points:",length(.))) %>>%
#'   summary
#'
#' rnorm(100) %>>%
#'   (~ x ~ cat("Number of points:",length(x))) %>>%
#'   summary
#'
#' # Assign the input value to a symbol in calling environment
#' # as side-effect
#' mtcars %>>%
#'   subset(mpg <= mean(mpg)) %>>%
#'   (~ sub_mtcars) %>>%
#'   summary
#'
#' # Assign to a symbol the value calculated by lambda expression
#' # as side effect
#' mtcars %>>%
#'   (~ summary_mtcars = summary(.)) %>>%
#'   (~ lm_mtcars = df ~ lm(mpg ~ ., data = df)) %>>%
#'   subset(mpg <= mean(mpg)) %>>%
#'   summary
#'
#' # Modifying values in calling environment
#' "col_" %>>%
#'   paste0(colnames(mtcars)) %>>%
#'   {names(mtcars) <- .}
#'
#' rnorm(100) %>>% {
#'   num_mean <- mean(.)
#'   num_sd <- sd(.)
#'   num_var <- var(.)
#' }
#'
#' for(i in 1:10) rnorm(i) %>>% (assign(paste0("var", i), .))
#'
#' # Pipe for element extraction
#' mtcars %>>% (mpg)
#'
#' # Pipe for questioning and printing
#' rnorm(100) %>>%
#'   (? summary(.)) %>>%
#'   plot(col="red")
#'
#' mtcars %>>%
#'   "data prepared" %>>%
#'   lm(formula = mpg ~ wt + cyl) %>>%
#'   summary %>>%
#'   coef
#'
#' mtcars %>>%
#'   ("Sample data" ? head(., 3)) %>>%
#'   lm(formula = mpg ~ wt + cyl) %>>%
#'   summary %>>%
#'   coef
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
`%>>%` <- pipe_op
