# pipeR

Pipeline operators for R

## Installation

This package is not yet released to CRAN, so you may install it through `devtools`.

```
library(devtools)
install_github("renkun-ken/pipeR")
```

## Help overview

```
help(package = pipeR)
```

## Motivation

In data-driven statistical computing and data analysis, applying a chain of commands step by step is a common situation. However, it is neigher straghtforawd nor flexible to write a group of deeply nested functions in that the last functions must be written first. For example, if we need to take the following steps:

1. Generate 10000 random numbers from normal distribution with mean 10 and standard deviation 1
2. Take a sample of 100 without replacement from these numbers
3. Take a log of the sample
4. Take a difference of the log numbers
5. Plot these log differences as red line segments.

To do it, we need to write the following code in R:

```
plot(diff(log(sample(rnorm(10000,mean=10,sd=1),size=100,replace=FALSE))),col="red",type="l")
```

But with this package, which provides various operators for chaining commands with two forward-piping mechanisms: first-argument piping and free piping, you have two more ways to write the procedure in the logical order of data transformation and manipulation.

With the first-argument pipe operator `%>%`, you may write:

```
rnorm(10000,mean=10,sd=1) %>%
  sample(size=100,replace=FALSE) %>%
  log %>%
  diff %>%
  plot(col="red",type="l")
```

With the free pipe operator `%>>%`, you can do more with `.` to represent the last result:

```
rnorm(10000,mean=10,sd=1) %>>%
  sample(.,size=length(.)/500,replace=FALSE) %>>%
  log %>>%
  diff %>>%
  plot(.,col="red",type="l",main=sprintf("length: %d",length(.)))
```

No matter which one you use, or both in one chain, your code will become much clearer and maintainable.

## Example of usage

### First-argument piping with basic functions

```
rnorm(100) %>% plot

rnorm(100) %>% plot(col="red")

rnorm(1000) %>% sample(size=100,replace=F) %>% hist
```

### Free piping with basic functions

```
rnorm(100) %>>% plot

rnorm(100) %>>% plot(.)

rnorm(100) %>>% plot(.,col="red")

rnorm(1000) %>>% sample(.,length(.)/20,F)

rnorm(1000) %>>% sample(.,length(.)/20,F) %>>% plot(.,main=sprintf("length: %d",length(.)))

rnorm(100) %>>% {
  par(mfrow=c(1,2))
  hist(.,main="hist")
  plot(.,col="red",main=sprintf("%d",length(.)))
} 
```

### Mixed piping with `dplyr`

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
  assign("hflights.speed",.,.GlobalEnv) %>>%
  barplot(.$speed.ssd, names.arg = .$UniqueCarrier,
    main=sprintf("Standardized mean of %d carriers", nrow(.)))
```

