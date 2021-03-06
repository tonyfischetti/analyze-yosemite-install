#!/usr/bin/Rscript --vanilla

###########################################################
##                                                       ##
##   analyze-log.R                                       ##
##                                                       ##
##                Author: Tony Fischetti                 ##
##                        tony.fischetti@gmail.com       ##
##                                                       ##
###########################################################

# workspace cleanup
rm(list=ls())

# options
options(echo=TRUE)
options(stringsAsFactors=FALSE)

# cli args
args <- commandArgs(trailingOnly=TRUE)

# libraries
library(dplyr)
library(ggplot2)
library(lubridate)
library(reshape2)


# let's read the log and parse the times and add a column for cumulative seconds
yos.log <- read.delim("./cleaned.log", sep="\t") %>%
  mutate(nice.date=paste(Month, Day, "2014", Time)) %>%
  mutate(lub.time=parse_date_time(nice.date, 
                                  "%b %d! %Y! %H!:%M!:%S!", 
                                  tz="EST"))

# remove rows of dates that refused to parse
yos.log <- yos.log[!is.na(yos.log$lub.time),]

# how long did the whole installation take?
install.time <- yos.log[nrow(yos.log), "lub.time"] - yos.log[1, "lub.time"]
(as.duration(install.time))
# about a half-hour

# let's make a column for cumuative time
yos.log$cumulative <- yos.log$lub.time - min(yos.log$lub.time, na.rm=TRUE)

# lets make a column for elapsed time for a process to complete
shifted <- c(yos.log$lub.time[-1], max(yos.log$lub.time))
yos.log$elapsed <- lead(yos.log$lub.time) - yos.log$lub.time

# remove last row
yos.log <- yos.log[-nrow(yos.log),]



# which service wrote the most to the log
# and took the longest

counts <- yos.log %>%
  group_by(Service) %>%
  summarise(n=n(), totalTime=sum(elapsed)) %>%
  arrange(desc(n)) %>%
  top_n(8, n) %>%
  mutate(percent.n = n/sum(n)) %>%
  mutate(percent.totalTime = as.numeric(totalTime)/sum(as.numeric(totalTime)))
counts



melted <- melt(as.data.frame(counts[,c("Service",
                                       "percent.n",
                                       "percent.totalTime")]))

ggplot(melted, aes(x=Service, y=as.numeric(value), fill=factor(variable))) +
  geom_bar(width=.8, stat="identity", position = "dodge",) +
  ggtitle("Breakdown of services during installation by writes to log") +
  ylab("percent") + xlab("service") +
  scale_fill_discrete(name="Percent of",
                      breaks=c("percent.n", "percent.totalTime"),
                      labels=c("writes to logfile", "time elapsed"))



# when did the OSInstaller processes start


ggplot(yos.log, aes(x=lub.time)) +
  geom_density(adjust=3, fill="#0072B2") +
  ggtitle("Density plot of number of writes to log file during installation") +
  xlab("time") + ylab("")



yos.log %>%
  filter()



smaller <- yos.log %>%
  filter(Service %in% c("OSInstaller", "opendirectoryd",
                        "Unknown", "OS"))

ggplot(smaller, aes(x=lub.time, color=Service)) +
  geom_density(aes( y = ..scaled..)) +
  ggtitle("Faceted density of log file writes by process (scaled)") +
  xlab("time") + ylab("")



yos.log %>% arrange(desc(elapsed)) %>% filter(elapsed>1)


yos.log %>%
  filter(is.in(lub.time, 
               ymd_hms("14-10-18 11:47:00", tz="EST"),
               ymd_hms("14-10-18 11:48:00", tz="EST")))


is.in <- function(time, start, end){
  if(time > start && time < end)
    return(TRUE)
  return(FALSE)
}

is.in.interval <- sapply(yos.log$lub.time, is.in, 
                         ymd_hms("14-10-18 11:47:00", tz="EST"), 
                         ymd_hms("14-10-18 11:48:00", tz="EST"))

in.interval <- yos.log[is.in.interval, ]

silence <- in.interval %>%
  select(Message) %>%
  sample_n(2) %>%
  apply(1, function (x){cat("\n");cat(x);cat("\n")})




yos.log %>%
  arrange(desc(elapsed)) %>%
  select(Service, Message, elapsed) %>%
  head(n=5)




is.in(parse_date_time("Oct 18 2014 11:28:23", "%b %d! %Y! %H!:%M!:%S!", tz="EST"),
      parse_date_time("Oct 18 2014 11:28:22", "%b %d! %Y! %H!:%M!:%S!", tz="EST"),
      parse_date_time("Oct 18 2014 11:28:25", "%b %d! %Y! %H!:%M!:%S!", tz="EST"))
