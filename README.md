# pipeR

Pipeline operators for R: Making command chaining flexible and straightforward

## Motivation

In data-driven statistical computing and data analysis, applying a chain of commands step by step is a common situation. However, it is neigher straghtforawd nor flexible to write a group of deeply nested functions in that the last functions must be written first. For example, if we need to take the following steps:

1. Generate 10000 random numbers from normal distribution with mean 10 and standard deviation 1
2. Take a sample of 100 without replacement from these numbers
3. Take a log of the sample
4. Take a difference of the log numbers
5. Plot these log differences as red line segments.

Here is a translation from these steps to R commands:

```
plot(diff(log(sample(rnorm(10000,mean=10,sd=1),size=100,replace=FALSE))),col="red",type="l")
```

The code is neither straightforward for reading nor flexible for modification.

This package provides two types of forward-piping mechanisms: first-argument piping and free piping. The two styles of piping are implemented by `%>%` and `%>>%`, respectively.

### First-argument piping

The first-argument pipe operator `%>%` insert the previous expression before all other specified arguments if any. In other words, `x %>% f(a=1)` will be translated to `f(x,a=1)`.

With the first-argument pipe operator `%>%`, you may rewrite the first example like

```
rnorm(10000,mean=10,sd=1) %>%
  sample(size=100,replace=FALSE) %>%
  log %>%
  diff %>%
  plot(col="red",type="l")
```

### Free piping

However, it may not always be the case where the last result serves as the first argument of the next function call. In this situation, you may use free pipe operator `%>>%` to allow `.` to represent the last result and let you decide where it should be piped to.

With the free pipe operator `%>>%`, you can do more with `.`:

```
rnorm(10000,mean=10,sd=1) %>>%
  sample(.,size=length(.)/500,replace=FALSE) %>>%
  log %>%
  diff %>%
  plot(.,col="red",type="l",main=sprintf("length: %d",length(.)))
```

No matter which one you use, or both in one chain, your code will become much clearer and maintainable.

### Lambda piping

In some situations, it can be confusing to see multiple `.` symbols in the same expression as they represent different things. Even though the expression still works in most cases, it may not a good idea to keep it in that way. Here is an example:

```
mtcars %>>%
  lm(mpg ~ ., data=.) %>%
  summary
```

The code above works correctly, although `.` in `mpg~.` represents all variables other than `mpg` and `.` in `data=.` represents `mtcars` dataset, as it is supposed. One way to reduce the ambiguity is to use *lambda expression*. Here we define a syntax like `x -> f(x)` where `->` means *map* rather than *assign* and `x` does not need to exist in the environment. Another symbol, `%|>%` is designed to handle piping with lambda expression, so we can rewrite the example above in this way:

```
mtcars %|>%
  (df -> lm(mpg ~ ., data=df)) %>%
  summary
```

## Installation

This package is not released to CRAN. You may install it through `devtools`.

```
if(!require(devtools)) install.packages("devtools")
require(devtools)
install_github("pipeR","renkun-ken")
```

## Help overview

```
help(package = pipeR)
```

## Example of usage

### First-argument piping with basic functions

```
rnorm(100) %>% plot

rnorm(100) %>% plot(col="red")

rnorm(1000) %>% sample(size=100,replace=F) %>% hist
```

### Free piping with basic functions

```
rnorm(100) %>>% plot(.)

rnorm(100) %>>% plot(.,col="red")

rnorm(1000) %>>% sample(.,length(.)*0.2,F)

rnorm(1000) %>>% 
  sample(.,length(.)*0.2,F) %>>% 
  plot(.,main=sprintf("length: %d",length(.)))

rnorm(100) %>>% {
  par(mfrow=c(1,2))
  hist(.,main="hist")
  plot(.,col="red",main=sprintf("%d",length(.)))
} 
```

### Lambda piping with basic functions

```
rnorm(100) %|>% (x -> plot(x))

rnorm(100) %|>% (x -> plot(x,col="red"))

rnorm(1000) %|>% (pop -> sample(pop,length(pop)*0.2,FALSE))

rnorm(1000) %|>% 
  (pop -> sample(pop,length(pop)*0.2,FALSE)) %|>% 
  (s -> plot(s,main=sprintf("length: %d",length(s))))
```

### Mixed piping

All the pipe operators can be used together and each of them plays a clear role.

```
mtcars %|>%
  (df -> lm(mpg ~ ., data=df)) %>%
  summary %>>%
  .$r.squared
```

### Piping with `dplyr` package

`dplyr` package provides a group of functions that make data transformation much easier. `%.%` is a built-in chain operator that pipes the previous result to the first-argument in the next function call. `%>%` is fully compatible with `dplyr` and can replace `%.%` with more consistency.

The following code demonstrates mixed piping with `dplyr` functions.

```
library(dplyr)
library(hflights)
data(hflights)

hflights %>%
  mutate(Speed=Distance/ActualElapsedTime) %>%
  group_by(UniqueCarrier) %>%
  summarize(n=length(Speed),speed.mean=mean(Speed,na.rm = T),
    speed.median=median(Speed,na.rm=T),
    speed.sd=sd(Speed,na.rm=T)) %>%
  mutate(speed.ssd=speed.mean/speed.sd) %>%
  arrange(desc(speed.ssd)) %>>%
  barplot(.$speed.ssd, names.arg = .$UniqueCarrier,
    main=sprintf("Standardized mean of %d carriers", nrow(.)))
```
