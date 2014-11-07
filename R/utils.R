# compatibility for data.table functions
.datatable.aware <- TRUE

setnames <- `names<-`
setclass <- `class<-`

dots <- function(...) {
  eval(substitute(alist(...)))
}

ndots <- function(dots) {
  length(dots) >= 1L && any(nzchar(dots))
}

is.formula <- function(expr) {
  is.call(expr) && as.character(expr) == "~"
}

is.side_effect <- function(expr) {
  if(!is.formula(expr)) FALSE
  else if(length(expr) == 2L) TRUE
  else if(length(expr) == 3L && Recall(expr[[2L]])) TRUE
  else FALSE
}
