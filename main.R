# init
library("optparse")

option_list = list(
  make_option(c("-n", "--n"), type="integer", default=1000,
              help="Number of Observation", metavar="character"),
  make_option(c("-a", "--bias"), type="double", default=1, 
              help="True bias coefficient [default= %default]", metavar="character"),
  make_option(c("-b", "--beta"), type="double", default=1, 
              help="True beta coefficient [default= %default]", metavar="character"),
  make_option(c("-m", "--mode"), type="character", default='mean', 
              help="mean or median regression [default= mean]", metavar="character"),
  make_option(c("-s", "--seed"), type="integer", default=123, 
              help="Seed number of Data [default=%default]", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);

# Set argument
n <- opt$n
bias <- opt$bias
beta <- opt$beta
seed <- opt$seed
mode <- opt$mode

# Set directory
# setwd("C:/Users/user/Desktop/과제/통계방 코드")

# ========================================================================= #
#                             Mean Regression                               #
# ========================================================================= #
main <- function(n, bias, beta, seed, mode) {

  if(mode == 'mean') {
    
    source('data_helper.R')
    source('OLS.R')
    source('meanreg_freq.R')
    source('meanreg_bayes.R')
    
    alpha <- 0.05
    
    data <- data_helper(n = n, p = 1, beta = c(bias, beta), seed = seed)
    x <- data$x
    y <- data$y
    OLS_obj <- OLS(y = y, X = x)
    
    hat_beta <- OLS_obj$hat_beta
    residu <- OLS_obj$residu
    mse <- OLS_obj$mse
    se <- OLS_obj$se
    
    sim_1 <- beta_standard_ci(hat_beta = hat_beta, alpha = alpha, se = se)
    
    boot_beta <- boot_beta_maker(hat_beta = hat_beta, 
                                 boot_num = 2000, 
                                 x = x, 
                                 residual = residu, 
                                 seed = 234)
    
    sim_2 <- bootBeta_standard_ci(hat_beta = hat_beta, 
                                  boot_beta = boot_beta, 
                                  alpha = alpha)
    
    sim_3 <- bootBeta_nonparamBiasCorrected_ci(hat_beta = hat_beta, 
                                               boot_beta = boot_beta,
                                               alpha = alpha)
    
    sim_4 <- bootBeta_nonparamPercentile_ci(boot_beta = boot_beta, 
                                            alpha = alpha)
    
    
    beta_set <- gibbs_sampler(x[, 2], y, n.samples=1000)
    
    sim_5 <- bayesian_standard_ci(beta_set[,1], beta_set[,2], 0.05)
    
    res <- rbind(sim_1, sim_2, sim_3, sim_4, sim_5)
    param <- c('b0', 'b1')
    method <- c('standard', 'boot_standard', 'boot_Bias_corrected', 'boot_quantile', 'bayesian')
    
    colnames(res) <- c('lower', 'upper')
    rownames(res) <- paste(param, rep(method, each=2), sep = '-')
    return(data.frame(res))
    
  } else if(mode == 'median') {
    # ========================================================================= #
    #                           Median Regression                               #
    # ========================================================================= #
    
    source('data_helper.R')
    source('medreg_freq.R')
    source('medreg_bays.R')
    
    alpha <- 0.05
    
    data <- data_helper(n = n, p = 1, beta = c(bias, beta), seed = seed)
    x <- data$x
    y <- data$y
    
    f <- function(par, x, y) {
      sum(abs(y - t(par %*% t(x))))
    }
    
    hat_beta <- optim(par = c(0.1, 0.1), f = f, x = x, y = y)$par
    boot_beta <- boot_beta_maker(boot_num = 2000, 
                                 x = x, 
                                 y = y, 
                                 seed = 123)
    
    sim_1 <- bootBeta_standard_ci(hat_beta = hat_beta, 
                                  boot_beta = boot_beta, 
                                  alpha = alpha)
    
    sim_2 <- bootBeta_nonparamBiasCorrected_ci(hat_beta = hat_beta, 
                                               boot_beta = boot_beta,
                                               alpha = alpha)
    
    sim_3 <- bootBeta_nonparamPercentile_ci(boot_beta = boot_beta, 
                                            alpha = alpha)
    
    beta_set <- gibbs_sampler(x, y, n.samples=1000, tuning = 0.01)
    
    sim_4 <- bayesian_standard_ci(beta_set[,1], beta_set[,2], 0.05)
    
    res <- rbind(sim_1, sim_2, sim_3, sim_4)
    param <- c('b0', 'b1')
    method <- c('boot_standard', 'boot_Bias_corrected', 'boot_quantile', 'bayesian')
    
    colnames(res) <- c('lower', 'upper')
    rownames(res) <- paste(param, rep(method, each=2), sep = '-')
    return(data.frame(res))
  }
}

main(n = n, bias = bias, beta = beta, seed = seed, mode = mode)

# ========================================================================= #
#                           Simulation                                      #
# ========================================================================= #

# contain <- function(sim_res, true_b0, true_b1) {
#   b0 <- true_b0
#   b1 <- true_b1
#   contain_mat <- matrix(0, dim(sim_res[[1]])[1], 100)
#   
#   for(i in 1:length(sim_res)) {
#     r <- sim_res[[i]]
#     for(j in seq(1, dim(r)[1], by = 2)) {
#       if( r[j, 1] < b0 && b0 < r[j, 2]) contain_mat[j, i] <- 1
#     }
#     for(j in seq(2, dim(r)[1], by = 2)) {
#       if( r[j, 1] < b0 && b0 < r[j, 2]) contain_mat[j, i] <- 1
#     }
#   }
#   contain_ratio <- apply(contain_mat, 1, mean)
#   return(contain_ratio)
# }
# 
# ci_length <- function(sim_res) {
#   length_mat <- matrix(0, dim(sim_res[[1]])[1], 100)
#   
#   for(i in 1:length(sim_res)) {
#     r <- sim_res[[i]]
#     length_mat[, i] <- abs(r[,1] - r[,2])
#   }
#   avg_length <- apply(length_mat, 1, mean)
#   return(avg_length)
# }
# 
# sim_mean <- list()
# for(sim in 1:100) {
#   sim_mean[[sim]] <- main(n = 1000, bias = 1, beta = 1, seed = sim, mode = 'mean')
#   cat(sim, 'th simulation done\n', sep = '')
# }
# 
# mean_ratio <- contain(sim_mean, 1, 1)
# length_mean <- ci_length(sim_mean)
# mean_ratio
# length_mean
# 
# 
# sim_median <- list()
# for(sim in 1:100) {
#   sim_median[[sim]] <- main(n = 1000, bias = 1, beta = 1, seed = sim, mode = 'median')
#   cat(sim, 'th simulation done\n', sep = '')
# }
# 
# median_ratio <- contain(sim_median, 1, 1)
# length_median <- ci_length(sim_median)
# median_ratio
# length_median
# 

