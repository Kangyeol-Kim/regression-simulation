f <- function(par, x, y) {
  sum(abs(y - t(par %*% t(x))))
}

# Boot Beta

boot_beta_maker <- function(boot_num, x, y, seed) {
  set.seed(seed)
  B <- boot_num
  boot_beta <- matrix(0, B, dim(x)[2])
  n <- length(y)
  
  for (b in 1:B)
  {
    id <- sample(floor(n/3), replace = T)
    boot.x <- x[id,]
    boot.y <- y[id]
    boot.obj <- optim(par = c(0.1, 0.1), f = f, x = boot.x, y = boot.y)
    boot_beta[b,] <- boot.obj$par
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
  p <- 2
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
