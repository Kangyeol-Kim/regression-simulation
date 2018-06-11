beta_standard_ci <- function(hat_beta, alpha, se) {
  
  z_alpha <- qnorm(1 - alpha/2)
  lo <- hat_beta - z_alpha * se
  up <- hat_beta + z_alpha * se
  ci <- cbind(lo, up)
  return(ci)
}

# Boot Beta

boot_beta_maker <- function(hat_beta, boot_num, x, residual, seed) {
  set.seed(seed)
  B <- boot_num
  r <- residual
  n <- length(r)
  boot_beta <- matrix(0, B, dim(x)[2])
  
  for (b in 1:B) {
    id <- sample(n, replace = T)
    boot_r <- r[id]
    boot_y <- x %*% hat_beta + boot_r
    boot_obj <- OLS(boot_y, x)
    boot_beta[b,] <- boot_obj$hat_beta
  }
  return(boot_beta)
}

# Boot standard ci

bootBeta_standard_ci <- function(hat_beta, boot_beta, alpha) {
  z_alpha <- qnorm(1 - alpha/2)
  se_boot <- sqrt(diag(cov(boot_beta)))
  lo_boot <- hat_beta - z_alpha * se_boot
  up_boot <- hat_beta + z_alpha * se_boot
  ci_boot <- cbind(lo_boot, up_boot)
  return(ci_boot)
}

# Boot nonparametric percentile

bootBeta_nonparamPercentile_ci <- function(boot_beta, alpha) {
  ci_boot <- t(apply(boot_beta, 2, quantile, prob = c(alpha/2, 1-alpha/2)))
  return(ci_boot)
}

# Boot nonparametric bias-corrected

bootBeta_nonparamBiasCorrected_ci <- function(hat_beta, boot_beta, alpha) {
  
  z_alpha <- qnorm(1 - alpha/2)
  p <- length(boot_beta)
  ci_boot <- matrix(0, p, 2)
  
  for (j in 1:p)
  {
    p0 <- mean(boot_beta[,j] <= hat_beta[j])
    z0 <- qnorm(p0)
    p_lo <- pnorm(2 * z0 - z_alpha)
    p_up <- pnorm(2 * z0 + z_alpha)
    ci_boot[j,] <- quantile(boot_beta[,j], prob = c(p_lo, p_up))
  }
  return(ci_boot)
}