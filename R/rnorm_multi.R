#' Multiple correlated normal distributions
#' 
#' Make normally distributed vectors with specified relationships. See \href{../doc/rnorm_multi.html}{\code{vignette("rnorm_multi", package = "faux")}} for details.
#'
#' @param n the number of samples required
#' @param vars the number of variables to return
#' @param mu a vector giving the means of the variables (numeric vector of length 1 or vars)
#' @param sd the standard deviations of the variables (numeric vector of length 1 or vars)
#' @param r the correlations among the variables (can be a single number, vars\*vars matrix, vars\*vars vector, or a vars\*(vars-1)/2 vector)
#' @param varnames optional names for the variables (string vector of length vars) defaults if r is a matrix with column names
#' @param empirical logical. If true, mu, sd and r specify the empirical not population mean, sd and covariance 
#' @param as.matrix logical. If true, returns a matrix
#' 
#' @return a tbl of vars vectors
#' 
#' @examples
#' rnorm_multi(100, 3, 0, 1, c(0.2, 0.4, 0.5), varnames=c("A", "B", "C"))
#' rnorm_multi(100, 3, 0, 1, c(1, 0.2, -0.5, 0.2, 1, 0.5, -0.5, 0.5, 1), varnames=c("A", "B", "C"))
#' 
#' @export

rnorm_multi <- function(n, vars = NULL, mu = 0, sd = 1, r = 0,
                       varnames = NULL, empirical = FALSE, 
                       as.matrix = FALSE) {
  # if (!is.null(seed)) {
  #   # reinstate system seed after simulation
  #   gs <- global_seed(); on.exit(global_seed(gs))
  # }
  
  # error handling ----
  if ( !is.numeric(n) || n %% 1 > 0 || n < 1 ) {
    stop("n must be an integer > 0")
  }
  
  if (!(empirical  %in% c(TRUE, FALSE))) {
    stop("empirical must be TRUE or FALSE")
  }
  
  # try to guess vars if not set ----
  if (is.null(vars)) {
    if (!is.null(varnames)) {
      vars <- length(varnames)
    } else if (length(mu) > 1) {
      vars <- length(mu)
    } else if (length(sd) > 1) {
      vars <- length(sd)
    } else if (is.matrix(r)) {
      vars <- ncol(r)
    }
    
    if (!is.null(vars)) {
      if (faux_options("verbose")) {
        message("The number of variables (vars) was guessed from the input to be ", vars)
      }
    } else {
      stop("The number of variables (vars) was not explicitly set and can't be guessed from the input.")
    }
  }
  
  if (length(mu) == 1) {
    mu <- rep(mu, vars)
  } else if (length(mu) != vars) {
    stop("the length of mu must be 1 or vars");
  } else {
    # get rid of names
    mu <- as.matrix(mu) %>% as.vector()
  }
  
  if (length(sd) == 1) {
    sd <- rep(sd, vars)
  } else if (length(sd) != vars) {
    stop("the length of sd must be 1 or vars");
  } else {
    # get rid of names
    sd <- as.matrix(sd) %>% as.vector()
  }
  
  if (n == 1 & empirical == TRUE) {
    warning("When n = 1 and empirical = TRUE, returned data are equal to mu")
    mvn <- mu
    cor_mat <- r # for name-checking later
  } else {
    # get data from mvn ----
    cor_mat <- cormat(r, vars)
    sigma <- (sd %*% t(sd)) * cor_mat
    # tryCatch({
    #   mvn <- MASS::mvrnorm(n, mu, sigma, empirical = empirical)
    # }, error = function(e) {
    #   stop("The correlated variables could not be generated. If empirical = TRUE, try increasing the N or setting empirical = FALSE.")
    # })
    
    err <- "The correlated variables could not be generated."
    if (empirical) err <- paste(err, "Try increasing the N or setting empirical = FALSE.")
    
    # code from MASS:mvrnorm
    p <- length(mu)
    if (!all(dim(sigma) == c(p, p))) stop(err)
    eS <- eigen(sigma, symmetric = TRUE)
    ev <- eS$values
    if (!all(ev >= -1e-06 * abs(ev[1L]))) stop(paste(err))
    X <- matrix(stats::rnorm(p * n), n)
    if (empirical) {
      X <- scale(X, TRUE, FALSE)
      X <- X %*% svd(X, nu = 0)$v
      X <- scale(X, FALSE, TRUE)
    }
    tryCatch({
      X <- drop(mu) + eS$vectors %*% 
        diag(sqrt(pmax(ev, 0)), p) %*%  t(X)
    }, error = function(e) { stop(err) })
    
    mvn <- t(X)
  }
  
  # coerce to matrix if vector when n == 1
  if (n == 1) mvn <- matrix(mvn, nrow = 1)
  
  if (length(varnames) == vars) {
    colnames(mvn) <- varnames
  } else if (!is.null(colnames(cor_mat))) {
    # if r was a matrix with names, use that
    colnames(mvn) <- colnames(cor_mat)
  } else {
    colnames(mvn) <- make_id(ncol(mvn), "X")
  }
  
  if (as.matrix == TRUE) mvn else data.frame(mvn, check.names = FALSE)
}

