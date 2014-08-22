

# pipeR

[![Build Status](https://travis-ci.org/renkun-ken/pipeR.png?branch=master)](https://travis-ci.org/renkun-ken/pipeR)

Pipe operator and function based on intuitive syntax

## What's new in 0.4?

[Release notes](https://github.com/renkun-ken/pipeR/releases)

#### 0.4-2

- **API Change**: 
    * lambda expression like `(x -> expr)` is deprecated, use `(x ~ expr)` instead.
    * `fun()` in `Pipe` object is deprecated, use `.()` instead.
- Add side-effect piping: `x %>>% (~ expr)` or `x %>>% (~ i ~ expr)`. `expr` will only be evaluated for its side effect and return `x`.
- Add question piping: `x %>>% (? expr)` where `expr` is an expression or a lambda expression. `expr` will only be printed and return `x`.
- Pipe object now supports subsetting, extracting, and assigning, and preserves Pipe object.

#### 0.4-1

- Add element extraction with `x %>>% (name)`.

#### 0.4

- **Major API Change**: `%>>%` operator now handles all pipeline mechanisms and other operators are deprecated.
- Add `Pipe()` function that supports object-based pipeline operation.

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

`%>>%` operator behaves based on a set of syntax:

* Pipe to first argument and `.` in a function if followed by a function name or call

```r
rnorm(100) %>>%
  plot
```

```r
rnorm(100) %>>%
  plot(col="red")
```

```r
rnorm(100) %>>%
  plot(col="red", main=length(.))
```

* Pipe to `.` in an expression if it is enclosed within `{}` or `()`

```r
mtcars %>>%
  { lm(mpg ~ cyl + wt, data = .) }
```

```r
mtcars %>>%
  ( lm(mpg ~ cyl + wt, data = .) )
```

* Pipe by lambda expression if followed by `(x ~ expr)`

```r
mtcars %>>%
  (df ~ lm(mpg ~ cyl + wt, data = df))
```

```r
rnorm(100) %>>%
  (x ~ plot(x, col="red", main=length(x)))
```

* Pipe for side effect if lambda expression starts by `~`

```r
rnorm(100) %>>%
  (~ cat("number:",length(.),"\n")) %>>%
  summary()
```

```r
rnorm(100) %>>%
  (~ x ~ cat("number:",length(x),"\n")) %>>%
  summary()
```

* Ask question if lambda expression starts by `?`

```r
iris %>>% 
  (? ncol(.)) %>>%
  summary()
```

```r
iris %>>% 
  (? df ~ ncol(df)) %>>%
  summary()
```

* Extract element if followed by name in `()`

```r
mtcars %>>%
  (mpg)
```

* Working with [dplyr](https://github.com/hadley/dplyr/):

```r
library(dplyr)
mtcars %>>%
  filter(mpg <= mean(mpg)) %>>%
  (lm(mpg ~ wt + cyl, data = .)) %>>%
  summary() %>>%
  (coefficients)
```

* Working with [ggvis](http://ggvis.rstudio.com/):

```r
library(ggvis)
mtcars %>>%
  ggvis(~mpg, ~wt) %>>%
  layer_points()
```

* Working with [rlist](http://renkun.me/rlist/):

```r
library(rlist)
1:100 %>>%
  list.group(. %% 3) %>>%
  list.mapv(g ~ mean(g))
```

### `Pipe()`

`Pipe()` creates a Pipe object that supports light-weight chaining without any external operator. Typically, start with `Pipe()` and end with `$value` or `[]` to extract the final value of the Pipe. 

An internal function `.(...)` works in the same way with `x %>>% (...)` for dot piping, by lambda expression, for side effect, and element extraction.

* Examples

```r
Pipe(rnorm(1000))$
  density(kernel = "cosine")$
  plot(col = "blue")
```

```r
Pipe(mtcars)$
  .(mpg)$
  summary()
```

```r
Pipe(mtcars)$
  .(~ cat("number of columns:", ncol(.), "\n"))$
  lm(formula = mpg ~ wt + cyl)$
  summary()$
  .(coefficients)
```

* Subsetting and extracting

```r
df <- Pipe(mtcars)
df[c("mpg","wt")]$lm(formula = mpg ~ wt)
df[["mpg"]]$mean()
```

* Assigning values

```r
df <- Pipe(list(a=1,b=2))
df$a <- 0
df$b <- NULL
```

* Working with dplyr:

```r
Pipe(mtcars)$
  filter(mpg >= mean(mpg))$
  .(lm(mpg ~ wt + cyl, data = .))$
  summary()$
  .(coefficients)$
  value
```

* Working with ggvis:

```r
Pipe(mtcars)$
  ggvis(~ mpg, ~ wt)$
  layer_points()
```

* Working with rlist:

```r
Pipe(1:100)$
  list.group(. %% 3)$
  list.mapv(g ~ mean(g))$
  value
```

* For side effect:

```r
Pipe(iris)$
  .(~ cat(length(.), "columns","\n"))$
  .(~ plot(.))$
  summary()
```

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
