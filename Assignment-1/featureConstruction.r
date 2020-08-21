data <- read.csv("crossedData.csv")
rownames(data) <- data$X; data$X <- NULL

## distance to neareast neighbors absolute attributes
library(RANN)
n.neighbors <- 12
nns.byfinger <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data[grepl(x, data$fingerprint), c("x", "y")]
    if(nrow(temp) >= (n.neighbors + 1)){ # enough minutiae in this fingerprint
      k <- n.neighbors + 1
      nns <- nn2(temp, k = k)$nn.dists[, -1]
    } else{ # use the maximum number of minutia possible, fill rest with NAs
      k <- nrow(temp) - 1
      nns <- cbind(nn2(temp, k = k)$nn.dists[, -1], matrix(nrow = nrow(temp), ncol = (n.neighbors + 1) - k))
    }
    nns
  }
)
names(nns.byfinger) <- unique(data$fingerprint)
nns.byfinger <- do.call(rbind, nns.byfinger)
data <- cbind.data.frame(data, nns.byfinger)
colnames(data)[7:ncol(data)] <- paste0("d", 0:11) 

## number of nearest neighbors by radius absolute attributes
radi <- seq(15, 90, 15)
n_nns.byradi <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data[grepl(x, data$fingerprint), c("x", "y")]
    euc <- as.matrix(dist(data.matrix(temp)))
    M <- matrix(nrow = nrow(euc), ncol = length(radi))
    for(i in 1:nrow(euc)){
      for(j in 1:length(radi)){
        M[i, j] <- sum(euc[i, ] <= radi[j]) - 1
      }
    }
    M
  }
)
names(n_nns.byradi) <- unique(data$fingerprint)
n_nns.byradi <- do.call(rbind, n_nns.byradi)
data <- cbind.data.frame(data, n_nns.byradi)
colnames(data)[19:ncol(data)] <- paste0("r", radi)

## checkpoint
write.csv(data, "crossedData_v2.csv")

## Relative attributes of nearest neighbors distances
nns.quants.byfinger <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data.matrix(data[grepl(x, data$fingerprint), grepl("d[[:digit:]]", colnames(data))])
    q <- ecdf(as.vector(temp))(as.vector(temp))
    matrix(q, byrow = FALSE, nrow = nrow(temp), ncol = ncol(temp))
  }
) # transforms distances for each fingerprint to quantiles
names(nns.quants.byfinger) <- unique(data$fingerprint)
nns.quants.byfinger <- do.call(rbind, nns.quants.byfinger)
data <- cbind.data.frame(data, nns.quants.byfinger)
colnames(data)[25:ncol(data)] <- paste0("q", 0:11)

## Relative attributes of number of nearest neighbors
n_nns.lags <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data.matrix(data[grepl(x, data$fingerprint), grepl("r[[:digit:]]", colnames(data))])
    t(apply(
      temp,
      1,
      function(y){
        largest_diff <- unname(y[length(y)] - y[1])
        lags <- unname(diff(y))
        append(lags, largest_diff)
      }
    ))
  }
)
names(n_nns.lags) <- unique(data$fingerprint)
n_nns.lags <- do.call(rbind, n_nns.lags)
data <- cbind.data.frame(data, n_nns.lags)
colnames(data)[37:ncol(data)] <- paste0("l", 1:length(radi))

## functions for angle calculation
ang <- function(p_i, p_j){
  xi <- p_i[1]
  yi <- p_i[2]
  xj <- p_j[1]
  yj <- p_j[2]
  dx <- xi - xj
  dy <- yi - yj
  if(dx > 0 && dy >= 0){
    return(atan(dy / dx))
  } else if(dx > 0 && dy < 0){
    return(atan(dy / dx) + (2 * pi))
  } else if(dx == 0 && dy > 0){
    return(pi / 2)
  } else if(dx == 0 && dy < 0){
    return((3 * pi) / 2)
  } else{
    return(atan(dy / dx) + pi)
  }
}
ad2pi <- function(theta1, theta2){
  if(theta2 > theta1){
    return(theta2 - theta1)
  } else{
    return(theta2 - theta1 + (2 * pi))
  }
}

## alpha angles
nnids.byfinger <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data[grepl(x, data$fingerprint), c("x", "y")]
    if(nrow(temp) >= (n.neighbors + 1)){
      k <- n.neighbors + 1
      nns <- nn2(temp, k = k)$nn.idx[, -1]
    } else{
      k <- nrow(temp) - 1
      nns <- cbind(nn2(temp, k = k)$nn.idx[, -1], matrix(nrow = nrow(temp), ncol = (n.neighbors + 1) - k))
    }
    nns
  }
)
names(nnids.byfinger) <- unique(data$fingerprint)

alphas.byfinger <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data.matrix(data[grepl(x, data$fingerprint), c("x", "y", "angle")])
    M <- matrix(nrow = nrow(temp), ncol = ncol(nnids.byfinger[[x]]) * 2)
    for(i in 1:nrow(temp)){
      p_i <- temp[i, c("x", "y")]
      neighbors <- nnids.byfinger[[x]][i, ]
      angles <- c()
      for(j in neighbors){
        if(is.na(j)){
          angles <- append(angles, c(NA, NA))
        } else{
          p_j <- temp[j, c("x", "y")]
          angles <- append(angles, ad2pi(ang(p_i, p_j), temp[i, "angle"]))
          angles <- append(angles, ad2pi(ang(p_j, p_i), temp[j, "angle"]))
        }
      }
      M[i, ] <- unname(angles)
    }
    M
  }
)
names(alphas.byfinger) <- unique(data$fingerprint)
alphas.byfinger <- do.call(rbind, alphas.byfinger)
data <- cbind.data.frame(data, alphas.byfinger)
colnames(data)[43:ncol(data)] <- c(rbind(paste0("alpha", 0:(n.neighbors - 1)), paste0("alpha", 0:(n.neighbors - 1), "r")))

betas.byfinger <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data[grepl(x, data$fingerprint), "angle"]
    M <- matrix(nrow = length(temp), ncol = ncol(nnids.byfinger[[x]]))
    for(i in 1:length(temp)){
      neighbors <- nnids.byfinger[[x]][i, ]
      angles <- c()
      for(j in neighbors){
        if(is.na(j)){
          angles <- append(angles, NA)
        } else{
          angles <- append(angles, ad2pi(temp[i], temp[j]))
        }
      }
      M[i, ] <- angles
    }
    M
  }
)
names(betas.byfinger) <- unique(data$fingerprint)
betas.byfinger <- do.call(rbind, betas.byfinger)
data <- cbind.data.frame(data, betas.byfinger)
colnames(data)[67:ncol(data)] <- paste0("beta", 0:(n.neighbors - 1))

## checkpoint
write.csv(data, "crossedData_v3.csv")

## final format
# accumulated number of nns at different radi (absolute)
cols <- which(grepl("r[[:digit:]]", colnames(data)))
# differences in the number of accumulated number of nns between radi (relative)
cols <- append(cols, which(grepl("l[[:digit:]]", colnames(data))))
# eucledian distance to nns (absolute)
cols <- append(cols, which(grepl("d[[:digit:]]", colnames(data))))
# distanc to nns expressed in quantiles for a single fingerprint (relative)
cols <- append(cols, which(grepl("q[[:digit:]]", colnames(data))))
cols <- append(cols, which(grepl("alpha", colnames(data))))
cols <- append(cols, which(grepl("beta", colnames(data))))
cols <- append(cols, which(grepl("score_change", colnames(data))))

data <- data[, cols]
# discreticize the target variable
score <- factor(sapply(data$score_change, function(x) if(x < 0) "0" else "1"))
data$score_change <- score
save(data, file = "final_dataset_v1.RData")
write.csv(data, "final_dataset_v1.csv", row.names = FALSE)
