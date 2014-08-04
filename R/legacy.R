#' Pipe an object forward to expression (deprecated)
#' @param . object
#' @param expr expression
#' @name deprecated
#' @export
`%:>%` <- function(.,expr) {
  warning("%:>% operator has been deprecated since version 0.4, please use %>>% with enclosed expression instead. \nExamples: \n\tx %>>% { f(.) } \n\tx %>>% ( f(.) )")
  eval(substitute(expr),list(.=.),parent.frame())
}

#' @rdname deprecated
#' @export
`%|>%` <- function(.,expr) {
  warning("%|>% operator has been deprecated since version 0.4, please use %>>% with enclosed expression instead. \nExamples: \n\tx %>>% (x -> f(x)) \n\tx %>>% (x ~ f(x))")
  eval(expr[[3L]],
    setnames(list(.),as.character.default(expr[[2L]])),
    parent.frame())
}
