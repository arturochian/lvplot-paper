library(lvplot)

library(RColorBrewer)
cols <- c("white", brewer.pal(9, "Blues"), "black")

set.seed(14101979)

# Internet sessions ----------------------------------------------------------

sessions <- read.csv("sessions.csv")

names(sessions) <- c("time", "length", "SIP", "DIP", "Dport", "Sport",
 "Npacket", "Nbyte")
sessions[, 3:6] <- round(65536 * sessions[, 3:6])

cut2.byte <- cut(log(1 + sqrt(sessions$Nbyte)), 
  breaks = c(-1, 0, seq(3, 5.4, by = 0.1), 5.6, 5.8, 6.0, 6.5, 9.0))

pdf("../images/box2.pdf", width = 10, height = 5)
boxplot(split(log(1 + sqrt(sessions$length)), cut2.byte), 
  varwidth = T,notch = T)
title("Message Duration and Length",
  xlab = "log(1 + sqrt{Nbyte})", 
  ylab = "log(1 + sqrt{duration}")
dev.off()

pdf("../images/lvbox2.pdf", width = 10, height = 5)
LVboxplot(log(1 + sqrt(sessions$length)) ~ cut2.byte, 
  horizontal = FALSE, col=cols, 
  xlab = "log(1 + sqrt{Nbyte})", 
  ylab = "log(1 + sqrt{duration})")
dev.off()

# Standard distributions -----------------------------------------------------

pdf("../images/boxplots.pdf", width = 6, height = 2)
par(mfrow = c(2,3), mar = c(4.1, 1, 0, 1))
n <- 10000

rn <- rnorm(n)
re <- rexp(n)
ru <- runif(n)
boxplot(rn, xlab="", horizontal=TRUE)
boxplot(re, xlab="", horizontal=TRUE)
boxplot(ru, xlab="", horizontal=TRUE)
LVboxplot(rn, xlab="Gaussian, n=10,000", horizontal=TRUE, col=cols)
LVboxplot(re, xlab="Exponential, n=10,000", horizontal=TRUE, col=cols)
LVboxplot(ru, xlab="Uniform, n=10,000", horizontal=TRUE, col=cols)
dev.off()

pdf("../images/t-dist.pdf", width = 6, height = 2)
par(mfrow = c(2,3), mar = c(4.1, 1, 0, 1))
n <- 10000
t2 <- rt(n, df = 2)
t3 <- rt(n, df = 3)
t9 <- rt(n, df = 9)

boxplot(t2, horizontal=TRUE, xlab="")
boxplot(t3, horizontal=TRUE, xlab="")
boxplot(t9, horizontal=TRUE, xlab="")
LVboxplot(t2, horizontal=TRUE, 
  xlab="t distribution, df=2, n=10,000", col=cols)
LVboxplot(t3, horizontal=TRUE, 
  xlab="t distribution, df=3, n=10,000", col=cols)
LVboxplot(t9, horizontal=TRUE, 
  xlab="t distribution, df=9, n=10,000", col=cols)
dev.off()

# County populations ---------------------------------------------------------

census <- read.csv("counties.csv")

pdf("../images/counties-qq.pdf", width = 6, height = 4)
par(mfrow = c(2,2), mar = c(4.1, 3, 2, 1))

# (a)
foo <- qqnorm(census$totalpop / 1e6, ylab="Total Population (millions)", 
  main="(A) Population")
qqline(census$totalpop / 1e6)
# (b)
logfoo <- qqnorm(log10(census$totalpop), ylab="Log10(Total Population)",
  main="(B) Logarithms")
qqline(log10(census$totalpop))

# (c)
LVy <- lvtable(census$totalpop / 1e6, 13)
LVx <- lvtable(foo$x, 13)
plot(LVx[,2], LVy[,2], main="(C) Population, Letter Values", 
  xlab="Theoretical Quantiles", ylab="Log10(Total Population)")
qqline(census$totalpop / 1e6)

# (d)
LVy <- lvtable(log10(census$totalpop), 13)
LVx <- lvtable(logfoo$x, 13)
plot(LVx[,2], LVy[,2], main="(D) Logarithms, Letter Values", 
  xlab="Theoretical Quantiles", ylab="Total Population")
qqline(log10(census$totalpop))
dev.off()


pdf("../images/counties-lvpop-a.pdf", height=2, width=6)
par(mar=c(4.1, 1, 1, 1))
with(census, boxplot(totalpop / 1e6, horizontal=TRUE, 
  xlab="total population (millions)"))
dev.off()
pdf("../images/counties-lvpop-b.pdf", height=2, width=6)
par(mar=c(4.1, 1, 1, 1))
with(census, LVboxplot(totalpop  / 1e6, horizontal=TRUE, 
  xlab="total population (millions)", col=cols))
dev.off()

pdf("../images/counties-lvpop-c.pdf", height=2, width=6)
par(mar=c(4.1, 1, 1, 1))
with(census, boxplot(log(totalpop), horizontal=TRUE, xlab="(log) total population"))
dev.off()

pdf("../images/counties-lvpop-d.pdf", height=2, width=6)
par(mar=c(4.1, 1, 1, 1))
with(census, LVboxplot(log(totalpop), horizontal=TRUE, xlab="(log) total population", col=cols))
dev.off()
