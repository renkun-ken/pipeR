setnames <- `names<-`
setclass <- `class<-`

ndots <- function(dots) {
  length(dots) >= 1L && any(nzchar(dots))
}

is.formula <- function(expr) {
  is.language(expr) && as.character(expr) == "~"
}

is.side_effect <- function(expr) {
  if(length(expr) == 2L && is.call(expr) && as.character(expr) == "~")
    # side-effect symbol
    TRUE
  else if(length(expr) == 3L && Recall(expr[[2L]]))
    # side-effect formula
    TRUE
  else
    FALSE
}
