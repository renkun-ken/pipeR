setnames <- `names<-`
setclass <- `class<-`

ndots <- function(dots) {
  length(dots) >= 1L && any(nzchar(dots))
}

is.formula <- function(expr) {
  is.language(expr) && as.character(expr) == "~"
}

is.side_effect <- function(expr) {
  length(expr) == 2L &&  as.character(expr) == "~"
}
