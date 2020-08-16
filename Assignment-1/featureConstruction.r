data <- read.csv("crossedData.csv")
rownames(data) <- data$X; data$X <- NULL

library(RANN)
nns.byfinger <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data[grepl(x, data$fingerprint), c("x", "y")]
    if(nrow(temp) >= 13){
      k <- 13
      nns <- nn2(temp, k = k)$nn.dists[, -1]
    } else{
      k <- nrow(temp) - 1
      nns <- cbind(nn2(temp, k = k)$nn.dists[, -1], matrix(nrow = nrow(temp), ncol = 13 - k))
    }
    nns
  }
)
names(nns.byfinger) <- unique(data$fingerprint)
nns.byfinger <- do.call(rbind, nns.byfinger)

data <- cbind.data.frame(data, nns.byfinger)
colnames(data)[7:ncol(data)] <- paste0("d", 0:11) 

n_nns.byradi <- lapply(
  unique(data$fingerprint),
  function(x){
    temp <- data[grepl(x, data$fingerprint), c("x", "y")]
    euc <- as.matrix(dist(data.matrix(temp)))
    intervals <- seq(15, 90, 15)
    M <- matrix(nrow = nrow(euc), ncol = length(intervals))
    for(i in 1:nrow(euc)){
      for(j in 1:length(intervals)){
        M[i, j] <- sum(euc[i, ] <= intervals[j]) - 1
      }
    }
    M
  }
)
names(n_nns.byradi) <- unique(data$fingerprint)
n_nns.byradi <- do.call(rbind, n_nns.byradi)

data <- cbind.data.frame(data, n_nns.byradi)
colnames(data)[19:ncol(data)] <- paste0("r", seq(15, 90, 15)) 





