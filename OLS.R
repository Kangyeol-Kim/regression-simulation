gauss <- function(Ab){
  p <- nrow(Ab)
  for (i in 1:p){
    # Diagonal element should not be 0
    if((abs(Ab[i,i]) < 1e-05) & (i < p)){
      temp.v <- Ab[i+1,] 
      Ab[i+1,] <- Ab[i,]
      Ab[i,] <- temp.v
    }
    for (j in (i+1):(p+1)) Ab[i,j] <- Ab[i,j]/Ab[i,i]
    Ab[i,i] <- 1
    if (i < p) {
      for (k in (i+1):p) Ab[k,] <- Ab[k,] - (Ab[k,i]/Ab[i,i])*Ab[i,]
    }
  }
  return(Ab)
}

backsub <- function(Ab) {
  p <- nrow(Ab)
  x <- rep(0,p)
  for (i in p:1){
    if (i < p){
      temp <- 0
      for (j in (i+1):p) temp <- temp + Ab[i,j]*x[j]
      x[i] <- Ab[i,p+1] - temp
    }
    else x[i] <- Ab[i,p+1]
  }
  return(x)
}

solveEqutaion <- function(A, b) {
  Ab <- cbind(A,b)
  x <- backsub(gauss(Ab))
  return(x)
}

OLS <- function(y, X) {
  n <- dim(X)[1]
  p <- dim(X)[2]
  
  obj <- qr(X)
  Q <- qr.Q(obj)
  R <- qr.R(obj)
  
  hat_beta <- solveEqutaion(t(R) %*% t(Q) %*% Q %*% R, t(R) %*% t(Q) %*% y)
  residu <- as.vector(y - X %*% hat_beta)
  mse <- sum(as.vector(y - X %*% hat_beta)^2)/(n -p -1)
  chol.obj <- chol(t(X) %*% X)
  inv.XX <- chol2inv(chol.obj)
  se <- sqrt(diag(inv.XX * mse))
  
  return(list(hat_beta = hat_beta,
              residu = residu,
              mse = mse,
              se = se))
}