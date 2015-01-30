# compatibility for data.table functions
.datatable.aware <- TRUE

setnames <- `names<-`
setclass <- `class<-`

ndots <- function(dots) {
  any(nzchar(dots))
}

is.formula <- function(expr) {
  inherits(expr, "formula") || (is.call(expr) && expr[[1L]] == "~")
}

is.side_effect <- function(expr) {
  is.formula(expr) &&
    (length(expr) == 2L ||
        length(expr) == 3L &&
        Recall(expr[[2L]]))
}
