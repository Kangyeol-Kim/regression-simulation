data_helper <- function(n, p, beta, seed) {
  
  if(length(beta) != p+1) {
    print('Length of beta should be (p+1)')
    return(0)
  }
  
  set.seed(seed)
  n <- n
  p <- p
  beta <- beta
  
  # predictors
  x <- matrix(rnorm(n * p), n, p)
  x <- cbind(rep(1, n), x)
  
  # errors
  eps  <- rnorm(n, 0, 1)
  y <- x %*% beta + eps
  
  return(list(y = y,
              x = x))
}