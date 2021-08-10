library(ggcorrplot)
library(MASS)
library(keras)
library(NeuralNetTools)
library(kableExtra)
library(olsrr)
library(Hmisc)

use_session_with_seed(123)

# functions ############
add_legend <- function(...) {
  opar <- par(fig=c(0, 1, 0, 1), oma=c(0, 0, 0, 0),
              mar=c(0, 0, 0, 0), new=TRUE)
  on.exit(par(opar))
  plot(0, 0, type='n', bty='n', xaxt='n', yaxt='n')
  legend(...)
}

frobenius_loss <- function(x1, x2){
  sqrt(sum(as.matrix((x1-x2)^2))/nrow(x1))
}

BNN_1 <- function(q00, q22){
  set.seed(123)
  Input <- layer_input(shape = c(q00), dtype = 'float32', name = 'Input')
  
  Output = Input %>% 
    layer_dense(units=q22, activation='tanh', use_bias=FALSE, name='Bottleneck') %>% 
    layer_dense(units=q00, activation='linear', use_bias=FALSE, name='Output')
  
  model <- keras_model(inputs = Input, outputs = Output)
  
  model %>% compile(optimizer = optimizer_nadam(), loss = 'mean_squared_error')
  return(model)
}

BNN_3 <- function(q00, q11, q22){  
  set.seed(123)
  Input <- layer_input(shape = c(q00), dtype = 'float32', name = 'Input')
  
  Encoder = Input %>% 
    layer_dense(units=q11, activation='tanh', use_bias=FALSE, name='Layer1') %>%
    layer_dense(units=q22, activation='tanh', use_bias=FALSE, name='Bottleneck') 
  
  Decoder = Encoder %>% 
    layer_dense(units=q11, activation='tanh', use_bias=FALSE, name='Layer3') %>% 
    layer_dense(units=q00, activation='linear', use_bias=FALSE, name='Output')
  
  model <- keras_model(inputs = Input, outputs = Decoder)
  model %>% compile(optimizer = optimizer_nadam(), loss = 'mean_squared_error')
  return(model)
}

# descriptive statistics ####
percentiles = Hmisc::describe(boston$medv)

# detect outliers  ##########
boston = Boston

outliers = apply(boston, 2, function(x){
  boxplot.stats(x)$out
})

percentage = lapply(outliers, function(x){
  
  round( 100*( length(x)/nrow(boston) ), 1)
  
})

perc = unlist(percentage)

# feature selection ##########
regression = lm(medv ~ ., data = boston)
selection = ols_step_all_possible(regression)
bic_selection = data.frame( selection[ which.min(selection$sbic),] )
predictors = strsplit(bic_selection$predictors, " +")[[1]]

fts = c("medv","lstat", "ptratio","tax", "rm","nox")
db_sel = boston[, fts]

tolog = c("medv", "lstat")
db_log = db_sel
db_log[, tolog] = log(db_sel[, tolog])

tosquare = c("nox", "rm")
db_log[, tosquare] = db_sel[, tosquare]^2
dataset = db_log[, fts]

# pca ##########
dati_norm = scale(dataset[, -1])
pca = prcomp(dati_norm, center = F, scale = F)

dati = cbind(dataset, pca1 = pca$x[, 1], pca2 = pca$x[, 2])
dati$medv = exp(dataset$medv)

# svd ############# 
SVD = svd(dati_norm)
SVD$d                              # singular values
pc_1 = dati_norm %*% SVD$v[,1]     # 1st principal component
pc_2 = dati_norm %*% SVD$v[,2]     # 2nd principal component

# reconstruction error of pca
reconstruction <- array(NA, c(length(SVD$d)))
for (p in 1:length(SVD$d)){
  Xp <- SVD$v[,1:p] %*% t(SVD$v[,1:p]) %*% t(dati_norm)
  Xp <- t(Xp)
  reconstruction[p] <- sqrt(sum(as.matrix((dati_norm - Xp)^2))/nrow(dati_norm))
}
round(reconstruction,2)  

# autoencoder #######

# BNN architecture and parameters
q1 <- 7
q2 <- 2
q0 <- ncol(dati_norm)
epochs <- 5000
batch_size <- nrow(dati_norm)

## full BNN #######
model_3 <- BNN_3(q0, q1, q2)
model_3

fit_train_full <- model_3 %>% fit(as.matrix(dati_norm), as.matrix(dati_norm), epochs=epochs, batch_size=batch_size, verbose=0)
fit_test_full <- model_3 %>% predict(as.matrix(dati_norm))
round(frobenius_loss(dati_norm,fit_test_full),4) # reconstruction error of full model

w3 = get_weights(model_3)

## stepwise calibration #####
# outer part
model_1 <- BNN_1(q0, q1)
model_1

fit <- model_1 %>% fit(as.matrix(dati_norm), as.matrix(dati_norm), epochs=epochs, batch_size=batch_size, verbose=0)

# neuron activations in the central layer 
zz <- keras_model(inputs=model_1$input, outputs=get_layer(model_1, 'Bottleneck')$output)
yy <- zz %>% predict(as.matrix(dati_norm))

# inner part
model_2 <- BNN_1(q1, q2)
model_2

fit <- model_2 %>% fit(as.matrix(yy), as.matrix(yy), 
                     epochs= epochs, batch_size= nrow(yy), verbose=0)

# get pre-trained weights
weight_3 <- get_weights(model_3)
weight_1 <- get_weights(model_1)
weight_2 <- get_weights(model_2)
weight_3[[1]] <- weight_1[[1]]
weight_3[[4]] <- weight_1[[2]]
weight_3[[2]] <- weight_2[[1]]
weight_3[[3]] <- weight_2[[2]]
set_weights(model_3, weight_3)
fit0 <- model_3 %>% predict(as.matrix(dati_norm))

# reconstruction error of the pre-calibrated network
round(frobenius_loss(dati_norm,fit0),4)

# reconstruction error using pre-trained weights as initialization
fit_train <- model_3 %>% fit(as.matrix(dati_norm), as.matrix(dati_norm), epochs=epochs, batch_size=batch_size, verbose=0)
fit_test <- model_3 %>% predict(as.matrix(dati_norm))
round(frobenius_loss(dati_norm, fit_test),4)

# bottleneck activations for cluster analysis
encoder <- keras_model(inputs=model_3$input, outputs=get_layer(model_3, 'Bottleneck')$output)
y <- encoder %>% predict(as.matrix(dati_norm))
y0 <- max(abs(y))*1.1

save.image("./factor_analysis.RData")




