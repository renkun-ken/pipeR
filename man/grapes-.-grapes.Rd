\name{\%.\%}
\alias{\%.\%}
\title{Pipe an object forward as the first argument to a function}
\usage{
x \%.\% f
}
\arguments{
  \item{x}{The object to be piped}

  \item{f}{The expression to evaluate with the piped object
  as the first argument.}
}
\description{
The \code{\%.\%} operator pipes the left-hand side foward
and evaluates the call expression on the right-hand side
with the left-hand side object as the first argument.
}
\examples{
\dontrun{
rnorm(100) \%.\% plot

rnorm(100) \%.\% plot(col="red")

rnorm(1000) \%.\% sample(size=100,replace=F) \%.\% hist
}
}

