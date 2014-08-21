setnames <- `names<-`
setclass <- `class<-`

ndots <- function(dots) {
  length(dots) >= 1L && any(nzchar(dots))
}
