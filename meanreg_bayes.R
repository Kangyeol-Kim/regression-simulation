gibbs_sampler <- function(x, y, n.samples) {
  # hyperparameters
  n.samples <- n.samples + 100
  n <- length(y)
  a <- 0.0001
  b <- 0.0001
  
  tau <- rep(1000, 2)
  mu <- rep(0, 2)
  
  # intial values:
  sigma2 <- 1
  beta <- rep(10, 2)
  
  samples <- matrix(0, n.samples, 3)
  colnames(samples) <- c("beta1", "beta2", "sigma2")

  # Gibs_sampler
  for(i in 1:n.samples){
    # update sigma2:
    SSE <- sum((y - beta[1] - x * beta[2])^2)
    sigma2 <- 1/rgamma(1, n/2 + a, SSE/2 + b)
    
    # update beta1:
    v <- n/sigma2 + 1/tau[1]^2
    m <- sum(y - x * beta[2])/sigma2 + mu[1]/tau[1]^2
    beta[1] <- rnorm(1, m/v, 1/sqrt(v))
    
    # update beta2:
    v <- sum(x^2)/sigma2 + 1/tau[2]^2
    m <- sum(x*(y-beta[1]))/sigma2 + mu[2]/tau[2]^2
    beta[2] <- rnorm(1,m/v,1/sqrt(v))
    
    samples[i,] <- c(beta, sigma2)
  }
  samples <- samples[-(1:100),]
  return(samples)
}


bayesian_standard_ci <- function(alphas, betas, per) {
  
  z_alpha <- qnorm(1 - per/2)
  hat_beta <- c(mean(alphas), mean(betas))
  se <- c(sqrt(var(alphas)), sqrt(var(betas)))
  
  lo <- hat_beta - z_alpha * se
  up <- hat_beta + z_alpha * se
  ci <- cbind(lo, up)
  return(ci)
}
