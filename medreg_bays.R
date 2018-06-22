# sigma posterior target kernel 
# prior - Uniform(0,1 )
# candidate - Normal(cond, tuning) only positive 
post_sigma_rho <- function(cand, alpha, beta, x, y, sigma2) {
  rho <-   exp(sum(-abs(y - alpha - beta*x[,2]))/cand + sum(abs(y - alpha - beta*x[,2]))/sigma2)
  return(rho)
}

# alpha posterior target kernel
# prior - Normal(0, 1)
# candidate - Normal(cond, tuning)
post_alpha_rho <- function(cand, alpha, beta, x, y, sigma2) {
  rho <- exp(sum(-abs(y - cand - beta*x[,2]))/sigma2 + sum(abs(y - alpha - beta*x[,2]))/sigma2
             - cand^{2} + alpha^{2})
  return(rho)
}

# beta posterior target kernel 
# prior - Normal(0, 1)
# candidate - Normal(cond, tuning)
post_beta_rho <- function(cand, alpha, beta, x, y, sigma2) {
  rho <- exp(sum(-abs(y - alpha - cand*x[,2]))/sigma2 + sum(abs(y - alpha - beta*x[,2]))/sigma2
             - cand^{2} + beta^{2})
  return(rho)
}

gibbs_sampler <- function(x, y, n.samples, tuning) {
  # hyperparameters
  n.samples <- n.samples

  # candidate parameter
  # value of sigma
  tuning <- tuning

  # intial values:
  sigma2 <- 0.3
  alpha <- beta <- 1

  samples <- matrix(0, n.samples, 3)
  colnames(samples) <- c("alpha", "beta", "sigma2")
  samples[1, ] <- c(alpha, beta, sigma2)

  # Gibs_sampler
  for(i in 2:n.samples){
    old_al <- samples[i-1, 1]
    old_be <- samples[i-1, 2]
    old_si <- samples[i-1, 3]
    
    # update sigma2:
    while(1) {
      r <- rnorm(1, old_si, tuning)
      rho <- post_sigma_rho(cand = r, alpha = old_al, beta = old_be, x = x, y = y, sigma2 = old_si)
      if (runif(1) < min(1, rho) && r > 0) {new_si <- r; break;}
    }
    samples[i, 3] <- new_si
    
    # update alpha:
    while(1) {
      r <- rnorm(1, old_al, tuning)
      rho <- post_sigma_rho(cand = r, alpha = old_al, beta = old_be, x = x, y = y, sigma2 = new_si)
      if (runif(1) < min(1, rho)) {new_al <- r; break;}
    }
    samples[i, 1] <- new_al
    
    # update beta:
    while(1) {
      r <- rnorm(1, old_be, tuning)
      rho <- post_sigma_rho(cand = r, alpha = new_al, beta = old_be, x = x, y = y, sigma2 = new_si)
      if (runif(1) < min(1, rho)) {new_be <- r; break;}
    }
    samples[i, 2] <- new_be
  }
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
