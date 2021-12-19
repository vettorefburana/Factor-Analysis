

install.packages("markdown")
install.packages("MASS")
install.packages("xts")
install.packages("ggcorrplot")
install.packages("kableExtra")
install.packages("NeuralNetTools")
install.packages("Hmisc")
install.packages("olsrr")

# install keras and tensorflow
install.packages("remotes")
remotes::install_github(paste0("rstudio/", c("reticulate", "tensorflow", "keras")))
reticulate::install_miniconda() 
keras::install_keras()