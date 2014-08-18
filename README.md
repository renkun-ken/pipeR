

# pipeR

[![Build Status](https://travis-ci.org/renkun-ken/pipeR.png?branch=master)](https://travis-ci.org/renkun-ken/pipeR)

High-performance pipeline operator and light-weight Pipe function based on a set of simple and intuitive rules, making command chaining definite, readable and fast.

## What's new in 0.4?

- **Major API Change**: `%>>%` operator now handles all pipeline mechanisms and other operators are deprecated.
- Add `Pipe()` function that supports object-based pipeline operation.

[Release notes](https://github.com/renkun-ken/pipeR/releases)

## Installation

Install from CRAN:

```r
install.packages("pipeR")
```

Install the development version from GitHub (`devtools` package is required):

```r
devtools::install_github("pipeR","renkun-ken")
```

## Usage

### `%>>%`

`%>>%` operator behaves based on a set of rules:

* Pipe to first argument and `.` in a function

```r
rnorm(100) %>>%
  plot

rnorm(100) %>>%
  plot(col="red")
  
rnorm(100) %>>%
  plot(col="red", main=length(.))
```

* Pipe to `.` in an expression

```r
mtcars %>>%
  { lm(mpg ~ cyl + wt, data = .) }

mtcars %>>%
  ( lm(mpg ~ cyl + wt, data = .) )
```

* Pipe by lambda expression

```r
mtcars %>>%
  (df ~ lm(mpg ~ cyl + wt, data = df))
  
rnorm(100) %>>%
  (x ~ plot(x, col="red", main=length(x)))
```

* Pipe for side effect (dev only)

```r
rnorm(100) %>>%
  (~ cat("number:",length(.),"\n")) %>>%
  summary() %>>%
```

```r
mtcars %>>%
  (~ par(mfrow=c(1,2))) %>>%
  (~ plot(mpg ~ cyl, data = .)) %>>%
  (~ plot(mpg ~ wt, data = .)) %>>%
  summary()
```

```r
mtcars %>>%
  ((df) ~ plot(mpg ~ ., data = df)) %>>%
  summary()
```  

* Pipe for extracting element

```r
mtcars %>>%
  (mpg)
```

Working with [dplyr](https://github.com/hadley/dplyr/):

```r
library(dplyr)
mtcars %>>%
  filter(mpg <= mean(mpg)) %>>%
  select(mpg, wt, qsec) %>>%
  (lm(mpg ~ ., data = .)) %>>%
  summary() %>>%
  (coefficients)
```

Working with [ggvis](http://ggvis.rstudio.com/):

```r
library(ggvis)
mtcars %>>%
  ggvis(~mpg, ~wt) %>>%
  layer_points()
```

Working with [rlist](http://renkun.me/rlist/):

```r
library(rlist)
1:100 %>>%
  list.group(. %% 3) %>>%
  list.mapv(g -> mean(g))
```

### `Pipe()`

`Pipe()` creates a Pipe object that supports light-weight chaining without any external operator. Typically, start with `Pipe()` and end with `$value` or `[]` to extract the final value of the Pipe. An internal function `.(...)` works in the same way with `x %>>% (...)` for dot piping, by lambda expression, for side effect, and element extraction.

Expressions using `%>>%` can be easily translated to `Pipe()`. But `Pipe()` is shipped with more features. See details in vignettes.

```r
Pipe(iris)$
  .(~ cat(length(.), "columns","\n"))$
  .(~ plot(.))$
  summary()
```

Working with dplyr:

```r
Pipe(mtcars)$
  filter(mpg >= mean(mpg))$
  select(mpg, wt, qsec)$
  .(lm(mpg ~ ., data = .))$
  summary()$
  .(coefficients)$
  value
```

Working with ggvis:

```r
Pipe(mtcars)$
  ggvis(~ mpg, ~ wt)$
  layer_points()
```

Working with rlist:

```r
Pipe(1:100)$
  list.group(. %% 3)$
  list.mapv(g -> mean(g))$
  value
```

## Performance

[Benchmark tests](http://cran.r-project.org/web/packages/pipeR/vignettes/Performance.html) show that pipeR operator and Pipe object has higher performance especially when they are intensively called compared to alternative packages.

- If you do not care about the performance of intensive calling and need heuristic distinction between different piping mechanisms, you may use `%>%` in [magrittr](https://github.com/smbache/magrittr) which also provides additional aliases of basic functions. 
- If you care about performance issues, want uniform operator, or need full control of the piping mechanism, pipeR can be a helpful choice.

## Vignettes

The package also provides the following vignettes:

- [Introduction](http://cran.r-project.org/web/packages/pipeR/vignettes/Introduction.html)
- [Examples](http://cran.r-project.org/web/packages/pipeR/vignettes/Examples.html)
- [Performance](http://cran.r-project.org/web/packages/pipeR/vignettes/Performance.html)


## Help overview

```r
help(package = pipeR)
```

## License

This package is under [MIT License](http://opensource.org/licenses/MIT).
