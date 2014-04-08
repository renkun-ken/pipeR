\name{\%>>\%}
\alias{\%>>\%}
\title{Pipe an object forward as `.`}
\usage{
. \%>>\% f
}
\arguments{
  \item{.}{The object to be piped as represented by
  \code{.}}

  \item{f}{The expression to evaluate with the piped object
  referred to as \code{.}}
}
\description{
The operator \code{\%>\%} pipes the left-hand side foward
and evaluates the call expression on the right-hand side
with the left-hand side object referred to as \code{.}.
}
\examples{
\dontrun{
rnorm(100) \%>>\% plot

rnorm(100) \%>>\% plot(.)

rnorm(100) \%>>\% plot(.,col="red")

rnorm(1000) \%>>\% sample(.,length(.)/20,F)

rnorm(1000) \%>>\% sample(.,length(.)/20,F) \%>>\% plot(.,main=sprintf("length: \%d",length(.)))
}
}

