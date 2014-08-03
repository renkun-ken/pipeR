#' @export
fun <- function(value, expr) {
  expr <- substitute(expr)
  switch(as.character.default(expr[[1L]]),
    "~" = {
      eval(expr[[3L]],
        "names<-"(list(value),as.character.default(expr[[2L]])),
        parent.frame())
    }, "<-" = {
      eval(expr[[2L]],
        "names<-"(list(value),as.character.default(expr[[3L]])),
        parent.frame())
    }, eval(expr,list(.=value),parent.frame()))
}

#' Pipe object
#'
#' @param value value to pipe
#' @name pipe
#' @export
Pipe <- function(value) {
  envir <- environment()
  class(envir) <- c("Pipe","environment")
  envir
}

#' @export
`$.Pipe` <- function(x,y) {
  fun <-  get(y,envir = parent.frame(),mode = "function")
  value <- get("value",envir = x,inherits = FALSE)
  function(...) {
    Pipe(fun(value,...))
  }
}

#' @export
`[.Pipe` <- function(x,...)
  get("value",envir = x,inherits = FALSE)


#' @export
print.Pipe <- function(x,...) {
  value <- get("value",envir = x,inherits = FALSE)
  if(!is.null(value)) {
    cat("Pipe\n")
    print(value,...)
  }
}
