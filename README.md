# pipeR

Pipeline operators for R: Making command chaining flexible and straightforward

## Installation

Install from CRAN:

```
install.packages("pipeR")
```

Install the devel version from GitHub (`devtools` package is required):

```
devtools::install_github("pipeR","renkun-ken")
```

## Motivation

In data-driven statistical computing and analysis, applying a chain of commands is a frequent situation. Consider the following example.

Suppose we need to take these steps:

1. Generate 10000 random numbers from normal distribution with mean 10 and standard deviation 1
2. Take a sample of 100 without replacement from these numbers
3. Take a log of the sample
4. Take a difference of the log numbers
5. Plot these log differences with red line segments.

Here is the ordinary way we do this in R programming langauge:

```
plot(diff(log(sample(rnorm(10000,mean=10,sd=1),size=100,replace=FALSE))),col="red",type="l")
```

The code is neither straightforward for reading nor flexible for modification. It is because the functions in the first few steps are hiding in the nested brackets, and the written order of the functions goes against the order of logic.

pipeR borrows the idea of F# pipeline operator which allows you to write the *object* first and *pipe* it to a following *function*. This package defines three binary pipe operators that provide different types of forward-piping mechanisms: first-argument piping (`%>>%`), free piping (`%:>%`), and lambda piping (`%|>%`). And the real magic of this kind of operators is chaining commands by the right order.

### First-argument piping: `%>>%`

The first-argument pipe operator `%>>%` inserts the expression on the left-hand side to the first argument of the **function** on the right-hand side. In other words, `x %>>% f(a=1)` will be transformed to and be evaluated as `f(x,a=1)`. This operator accepts both function call, e.g. `plot()` or `plot(col="red")`, and function name, e.g. `log` or `plot`.

```
rnorm(100) %>>% plot
# plot(rnorm(100))

rnorm(100) %>>% plot()
# plot(rnorm(100))

rnorm(100) %>>% plot(col="red")
# plot(rnorm(100),col="red")

rnorm(100) %>>% sample(size=100,replace=FALSE) %>>% hist
# hist(sample(rnorm(100),size=100,replace=FALSE))
```

With the first-argument pipe operator `%>>%`, you may rewrite the first example as

```
rnorm(10000,mean=10,sd=1) %>>%
  sample(size=100,replace=FALSE) %>>%
  log %>>%
  diff %>>%
  plot(col="red",type="l")
```

### Free piping: `%:>%`

You may not always want to pipe the object to the first argument of the next function. Then you can use free pipe operator `%:>%`, which takes `.` to represent the piped object on the left-hand side and evaluate the *expression* on the right-hand side with `.` as the piped object. In other words, you have the right to decide where the object should be piped to.

```
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
  sample(.,size=length(.)/500,replace=FALSE) %>>%
  log %>>%
  diff %:>%
  plot(.,col="red",type="l",main=sprintf("length: %d",length(.)))
# (`%>>%` and `%:>%` are used together. Be clear what they mean)
```

### Lambda piping: `%|>%`

It can be confusing to see multiple `.` symbols in the same context. In some cases, they may represent different things in the same expression. Even though the expression mostly still works, it may not be a good idea to keep it in that way. Here is an example:

```
mtcars %:>%
  lm(mpg ~ ., data=.) %>>%
  summary
```

The code above works correctly with `%:>%` and `%>>%`, even though the two dots in the second line have different meanings. `.` in formula `mpg ~ .` represents all variables other than `mpg` in data frame `mtcars`; `.` in `data=.` represents `mtcars` itself. One way to reduce ambiguity is to use *lambda expression* that names the piped object on the left of `~` and specifies the expression to evaluate on the right.

A new pipe operator `%|>%` is defined, which works with lambda expression in the formula form `x ~ f(x)`. More specifically, the expression will be interpreted as *`f(x)` is evaluated with `x` being the piped object*. Therefore, the previous example can be rewritten with `%|>%` like this:

```
mtcars %|>%
  (df ~ lm(mpg ~ ., data=df)) %>>%
  summary
```

Moreover, we could store the lambda expressions by assigning the formula to symbols.

```
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

```
mtcars %|>%
  (df ~ lm(mpg ~ ., data=df)) %>>%
  summary %:>%
  .$fstatistic
```

### Piping with `dplyr` package

`dplyr` package provides a group of functions that make data transformation much easier. `%.%` is a built-in chain operator that pipes the previous result to the first-argument in the next function call. `%>>%` is fully compatible with `dplyr` and can replace `%.%` with more consistency.

The following code demonstrates mixed piping with `dplyr` functions.

```
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

## Notice

The reason why the three operators are not "integrated" into one is that I want to make the functionality of each operator as clear and independent as possible, so that guessing and ambiguity could be sharply reduced. When you decide to use pipe operators to build a chain of expressions, you need to know clearly how you want to pipe your results to the next level. The following bullets are a brief summary:

1. `%>>%` only pipes an object to the first-argument of the next *function*, that is, `x %>>% f(...)` runs as `f(x,...)`.
2. `%:>%` only evaluates the next *expression* with `.` representing the object being piped, that is, `x %:>% f(a,.,g(.))` runs as `f(a,x,g(x))`.
3. `%|>%` only evaluates the *expression* on the right-hand side of `~` in the lambda expression formula with symbol on the left representing the object being piped, that is, `x %|>% (a ~ f(a,g(a)))` runs as `f(x,g(x))`.

## Performance

Since each pipe operators defined in this package specializes in its work and is made as simple as possible, the overhead is significantly lower than its peer implmentation in `magrittr` package. In general, `pipeR` is more than 3 times faster than `magrittr` and can be more than 30 times faster when the pipeline gets longer or when the data gets bigger. The detailed performance tests can be seen in issues.

## Help overview

```
help(package = pipeR)
```

## License

This package is under [MIT License](http://opensource.org/licenses/MIT).
