#' LV box plot.
#'
#' An extension of standard boxplots which draws k letter statistics.
#' 
#' This is a generic method: please see specific methods for details.
#'
#' @family letter-value boxplots
#' @keywords internal
#' @export
LVboxplot <- function(x, ...) UseMethod("LVboxplot",x)

#' Side-by-side LV boxplots.
#'
#' An extension of standard boxplots which draws k letter statistics. 
#' Conventional boxplots (Tukey 1977) are useful displays for conveying rough
#' information about the central 50\% of the data and the extent of the data.
#' 
#' For moderate-sized data sets (\eqn{n < 1000}), detailed estimates of tail
#' behavior beyond the quartiles may not be trustworthy, so the information
#' provided by boxplots is appropriately somewhat vague beyond the quartiles,
#' and the expected number of ``outliers'' and ``far-out'' values for a
#' Gaussian sample of size \eqn{n} is often less than 10 (Hoaglin, Iglewicz,
#' and Tukey 1986). Large data sets (\eqn{n \approx 10,000-100,000}) afford
#' more precise estimates of quantiles in the tails beyond the quartiles and
#' also can be expected to present a large number of ``outliers'' (about 
#' \eqn{0.4 + 0.007 n}).
#' 
#' The letter-value box plot addresses both these shortcomings: it conveys
#' more detailed information in the tails using letter values, only out to the
#' depths where the letter values are reliable estimates of their
#' corresponding quantiles (corresponding to tail areas of roughly
#' \eqn{2^{-i}}); ``outliers'' are defined as a function of the most extreme
#' letter value shown. All aspects shown on the letter-value boxplot are
#' actual observations, thus remaining faithful to the principles that
#' governed Tukey's original boxplot.
#' 
#' @param formula a plotting formula of the form \code{y ~ x}, where \code{x}
#'   is a string or factor. The values of \code{y} will be split into groups
#'   according to their values on \code{x} and separate letter value box plots
#'   of \code{y} are drawn side by side in the same display.
#' @param xlab x axis label
#' @param ylab y axis label
#' @param bg background colour
#' @inheritParams determineDepth
#' @inheritParams drawLVplot
#' @param ... passed onto \code{\link{plot}}
#' @export
#' @method LVboxplot formula
#' @keywords hplot
#' @family letter-value boxplots
#' @examples
#' n <- 10
#' oldpar <- par()
#' par(mfrow=c(4,2), mar=c(3,3,3,3))
#' for (i in 1:4) {
#'   x <- rexp(10 ^ (i + 1))
#'   boxplot(x, col = "grey", horizontal = TRUE)
#'   title(paste("Exponential, n = ", length(x)))
#'   LVboxplot(x, col = "grey", xlab = "")
#' }
#' par(oldpar)
LVboxplot.formula <- function(formula,alpha=0.95, k=NULL, perc=NULL, horizontal=TRUE, xlab=NULL, ylab=NULL, col="grey30", bg="grey90", ...) {
    deparen <- function(expr) {
        while (is.language(expr) && !is.name(expr) && deparse(expr[[1]]) == 
            "(") expr <- expr[[2]]
        expr
    }
    bad.formula <- function() stop("invalid formula; use format y ~ x")
    bad.lengths <- function() stop("incompatible variable lengths")
    
    formula <- deparen(formula)
    if (!inherits(formula, "formula")) 
        bad.formula()
    z <- deparen(formula[[2]])
    x <- deparen(formula[[3]])
    rhs <- deparen(formula[[3]])
    if (is.language(rhs) && !is.name(rhs) && (deparse(rhs[[1]]) == 
        "*" || deparse(rhs[[1]]) == "+")) {
        bad.formula()
    }
    z.name <- deparse(z)
    z <- eval(z,  parent.frame())
    x.name <- deparse(x)
    x <- eval(x,  parent.frame())
	setx <- sort(unique(x))
    src.k <- k 
    src.col <- col 

# don't know what to do with missing data - for right now, we will delete
	dft <- data.frame(x=x,z=z)
	dft <- na.omit(dft)
	x <- dft$x
	z <- dft$z

    pt <- 1
	if (horizontal) {
	  if (is.null(xlab)) xlab=z.name
	  if (is.null(ylab)) ylab=x.name
	  plot(z,rep(pt,length(z)),ylim=c(0.5,length(setx)+.5),ylab=ylab,xlab=xlab, axes=FALSE,type="n",...)
	  rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = bg)
	  box()
	  axis(1)
	  axis(2,at=1:length(setx), labels=as.character(setx))	  
	  grid(lty=1, col="white", ny=NA)
	  abline(h=1:length(setx), col="white")
	} else {
	  if (is.null(ylab)) ylab=z.name
	  if (is.null(xlab)) xlab=x.name
	  plot(rep(pt,length(z)),z,xlim=c(0,length(setx))+0.5, xlab=xlab, ylab=ylab, axes=FALSE, type="n", ...)
	  rect(par("usr")[1], par("usr")[3], par("usr")[2], par("usr")[4], col = bg)
	  box()
	  axis(2)
	  axis(1,at=1:length(setx),labels=as.character(setx))
	  grid(lty=1, col="white")
	  abline(v=1:length(setx), col="white")
	}

# compute one set of colours for the rectangles
	xtable <- table(x, useNA="ifany")
	kmax <- determineDepth(max(xtable),src.k,alpha,perc)
    if (! is.na(src.col)) { 
   		#col <- c(brewer.pal(k-1,"Blues"),"Black") # break dependency of ColorBrewer package
   		
   		colrgb <- col2rgb(src.col)
   		colhsv <- rgb2hsv(colrgb)
		if (colhsv[2,1] == 0) {
   			val <- seq(0.9,colhsv[3,1], length.out=kmax)
   			colrgb <- col2rgb(hsv(colhsv[1,1], colhsv[2,1], val))
		} else {
   			sat <- seq(0.1,colhsv[2,1], length.out=kmax)
   			colrgb <- col2rgb(hsv(colhsv[1,1], sat, colhsv[3,1]))
		}
   		col <- rgb(colrgb[1,],colrgb[2,],colrgb[3,], maxColorValue=255) 	
   	 } else { col <- rep("grey",kmax) }
	
	result <- list(length(setx))
    for (i in setx) {
       xx <- z[x==i]
	   n <- length(xx)
	   k <- determineDepth(n,src.k,alpha,perc) 
	   
	 # compute letter values based on depth  
	   depth    <- rep(0,k)
	   depth[1] <- (1 + n)/2
	   if (k > 1) {
		 for (j in 2:k) {depth[j] <- (1 + floor(depth[j-1]))/2 } 
	   }
	   
	   y <- sort(xx)
	   d <- c(rev(depth),n-depth+1)
	   qu <- (y[floor(d)] + y[ceiling(d)])/2 	
		 # floor and ceiling is the same for .0 values
		 # .5 values yield average of two neighbours
	   
	 # determine outliers
	   out <- (xx<qu[1]) | (xx>qu[2*k])            

	   drawLVplot(xx,pt,k,out,qu,horizontal,col=col[(kmax-k) +1:k],...)
	   result[[pt]] <- outputLVplot(xx,qu,k,out,depth,alpha)      
	   pt <- pt+1
    }
    invisible(as.list(result))
}

#' Draw a single LV boxplot.
#' 
#' @param x numeric vector of data
#' @inheritParams LVboxplot.formula
#' @inheritParams determineDepth
#' @inheritParams drawLVplot
#' @family letter-value boxplots
#' @export
#' @method LVboxplot numeric
LVboxplot.numeric <- function(x,alpha=0.95, k=NULL, perc=NULL, horizontal=TRUE, xlab="", col="grey30", bg="grey90", ...) {
# extension of standard boxplots
# draws k letter statistics

  n <- length(x)
  k <- determineDepth(n,k,alpha,perc) 
  src.col <- col 

  if (! is.na(src.col)) { #col <- c(brewer.pal(k-1,"Blues"),"Black")  	   		
	colrgb <- col2rgb(src.col)
	colhsv <- rgb2hsv(colrgb)
	if (colhsv[2,1] == 0) {
	  val <- seq(0.9,colhsv[3,1], length.out=k)
	  colrgb <- col2rgb(hsv(colhsv[1,1], colhsv[2,1], val))
	} else {
	  sat <- seq(0.1,colhsv[2,1], length.out=k)
	  colrgb <- col2rgb(hsv(colhsv[1,1], sat, colhsv[3,1]))
	}
	col <- rgb(colrgb[1,],colrgb[2,],colrgb[3,], maxColorValue=255) 	
  } else { col <- rep("grey",k) }
  
# compute letter values based on depth  
  depth    <- rep(0,k)
  depth[1] <- (1 + n)/2
  if (k > 1) {
    for (j in 2:k) {depth[j] <- (1 + floor(depth[j-1]))/2 } 
  }
  
  y <- sort(x)
  d <- c(rev(depth),n-depth+1)
  qu <- (y[floor(d)] + y[ceiling(d)])/2 	
    # floor and ceiling is the same for .0 values
  	# .5 values yield average of two neighbours
  
# determine outliers
  out <- (x<qu[1]) | (x>qu[2*k])               
  if (k < 1) out <- x

  pt <- 0.5
  if (horizontal) {
    plot(x,rep(pt,length(x)),ylim=c(pt-0.5,pt+0.5),ylab="",axes=FALSE,type="n",bg="grey80",...)
	box()
	axis(1)
  } else {
	plot(rep(pt,length(x)),x,xlim=c(pt-0.5,pt+0.5), xlab="", axes=FALSE, type="n",bg="grey80", ...)
	box()
	axis(2)
  }
     
  drawLVplot(x,pt,k,out,qu,horizontal,col,...)

  result <- outputLVplot(x,qu,k,out,depth,alpha)
  invisible(result)
}
