# pipeR

[![Build Status](https://travis-ci.org/renkun-ken/pipeR.png?branch=master)](https://travis-ci.org/renkun-ken/pipeR)

Specialized, high-performance pipeline operators for R: making command chaining clear, fast, readable and flexible.

## What's New?

**Major operator change** (See issue [#12](https://github.com/renkun-ken/pipeR/issues/12))

[Release notes](https://github.com/renkun-ken/pipeR/releases)

## Installation

Install from CRAN:

```s
install.packages("pipeR")
```

Install the devel version from GitHub (`devtools` package is required):

```s
devtools::install_github("pipeR","renkun-ken")
```

## Getting started

### First-argument piping: `%>>%`

The first-argument pipe operator `%>>%` inserts the expression on the left-hand side to the first argument of the **function** on the right-hand side. In other words, `x %>>% f(a=1)` will be transformed to and be evaluated as `f(x,a=1)`. This operator accepts both function call, e.g. `plot()` or `plot(col="red")`, and function name, e.g. `log` or `plot`.

```s
rnorm(100) %>>% plot
# plot(rnorm(100))

rnorm(100) %>>% plot()
# plot(rnorm(100))

rnorm(100) %>>% plot(col="red")
# plot(rnorm(100),col="red")

rnorm(100) %>>% sample(size=100,replace=FALSE) %>>% hist
# hist(sample(rnorm(100),size=100,replace=FALSE))
```

With the first-argument pipe operator `%>>%`, you can write code like

```s
rnorm(10000,mean=10,sd=1) %>>%
  sample(size=100,replace=FALSE) %>>%
  log %>>%
  diff %>>%
  plot(col="red",type="l")
```

### Free piping: `%:>%`

You may not always want to pipe the object to the first argument of the next function. Then you can use free pipe operator `%:>%`, which takes `.` to represent the piped object on the left-hand side and evaluate the *expression* on the right-hand side with `.` as the piped object. In other words, you have the right to decide where the object should be piped to.

```s
rnorm(100) %:>% plot(.)
# plot(rnorm(100))

rnorm(100) %:>% plot(., col="red")
# plot(rnorm(100),col="red")

rnorm(100) %:>% sample(., size=length(.)*0.5)
# (`.` is piped to multiple places)

mtcars %:>% lm(mpg ~ cyl + disp, data=.) %>>% summary
# summary(lm(mgp ~ cyl + disp, data=mtcars))

rnorm(100) %:>% 
  sample(.,length(.)*0.2,FALSE) %:>% 
  plot(.,main=sprintf("length: %d",length(.)))
# (`.` is piped to multiple places and mutiple levels)

rnorm(100) %:>% {
  par(mfrow=c(1,2))
  hist(.,main="hist")
  plot(.,col="red",main=sprintf("%d",length(.)))
}
# (`.` is piped to an enclosed expression)

rnorm(10000,mean=10,sd=1) %:>%
  sample(.,size=length(.)*0.2,replace=FALSE) %>>%
  log %>>%
  diff %:>%
  plot(.,col="red",type="l",main=sprintf("length: %d",length(.)))
# (`%>>%` and `%:>%` are used together. Be clear what they mean)
```

### Lambda piping: `%|>%`

It can be confusing to see multiple `.` symbols in the same context. In some cases, they may represent different things in the same expression. Even though the expression mostly still works, it may not be a good idea to keep it in that way. Here is an example:

```s
mtcars %:>%
  lm(mpg ~ ., data=.) %>>%
  summary
```

The code above works correctly with `%:>%` and `%>>%`, even though the two dots in the second line have different meanings. `.` in formula `mpg ~ .` represents all variables other than `mpg` in data frame `mtcars`; `.` in `data=.` represents `mtcars` itself. One way to reduce ambiguity is to use *lambda expression* that names the piped object on the left of `~` and specifies the expression to evaluate on the right.

A new pipe operator `%|>%` is defined, which works with lambda expression in the formula form `x ~ f(x)`. More specifically, the expression will be interpreted as *`f(x)` is evaluated with `x` being the piped object*. Therefore, the previous example can be rewritten with `%|>%` like this:

```s
mtcars %|>%
  (df ~ lm(mpg ~ ., data=df)) %>>%
  summary
```

Moreover, you can store the lambda expressions by assigning the formula to symbols.

```s
runlm <- df ~ lm(mpg ~ ., data=df)
plotlm <- m ~ {
  par(mfrow=c(2,2))
  plot(m,ask=FALSE)
}

mtcars %|>%
  runlm %|>%
  plotlm
``` 

### Mixed piping

All the pipe operators can be used together and each of them only works in their own way.

```s
mtcars %|>%
  (df ~ lm(mpg ~ ., data=df)) %>>%
  summary %:>%
  .$fstatistic
```

### Piping with `dplyr` package

`dplyr` package provides a group of functions that make data transformation much easier. These operators are fully compatible with `dplyr` and provide higher performance than its default pipe operator.

The following code demonstrates mixed piping with `dplyr` functions.

```s
library(dplyr)
library(hflights)
library(pipeR)
data(hflights)

hflights %>>%
  mutate(Speed=Distance/ActualElapsedTime) %>>%
  group_by(UniqueCarrier) %>>%
  summarize(n=length(Speed),speed.mean=mean(Speed,na.rm = T),
    speed.median=median(Speed,na.rm=T),
    speed.sd=sd(Speed,na.rm=T)) %>>%
  mutate(speed.ssd=speed.mean/speed.sd) %>>%
  arrange(desc(speed.ssd)) %:>%
  barplot(.$speed.ssd, names.arg = .$UniqueCarrier,
    main=sprintf("Standardized mean of %d carriers", nrow(.)))
```

## Performance

Each operator defined in this package specializes in its work and is made as simple as possible. Therefore the overhead is extremely low and their performance is very close to traditional approach. This allow you to build long pipelines and perform intensive computations without worrying much about the performance cost of it.

## Help overview

```s
help(package = pipeR)
```

## License

This package is under [MIT License](http://opensource.org/licenses/MIT).
