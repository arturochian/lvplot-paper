#' Determine depth of letter values needed for n observations.
#' 
#' @details Supply one of \code{k}, \code{alpha} or \code{perc}.
#'
#' @param n number of observation to be shown in the LV boxplot
#' @param k number of letter value statistics used 
#' @param alpha if supplied, depth k is calculated such that confidence
#'   intervals of width \code{alpha} of an LV statistic do not extend into
#'   neighboring LV statistics. 
#' @param perc if supplied, depth k is adjusted such that \code{perc} percent
#'   outliers are shown 
#' @export
determineDepth <- function(n, k = NULL, alpha = NULL, perc = NULL) {
  if (!is.null(perc)) {
  	# we're aiming for perc percent of outlying points
  	k <- ceiling((log2(n))+1) - ceiling((log2(n*perc*0.01))+1)+1
  }
  if (is.null(k)) { 
  	# confidence intervals around an LV statistic 
  	# should not extend into surrounding LV statistics

  	k <- ceiling((log2(n))-log2(2*qnorm(alpha+(1-alpha)/2)^2))  
  }
  if (k < 1) k <- 1
 
  return (k)
}
