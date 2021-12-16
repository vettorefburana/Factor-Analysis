# Factor-Analysis

**Factor analysis using PCA, SVD and bottleneck neural network (BNN) autoencoders using the Boston Housing dataset**

Factor analysis is generally used for dimensionality reduction, which is achieved by identifying a low number of latent factors that are able to capture the variability of the data without too much loss of information. 

The R script in this repository implements and compares different factor analysis techniques using data on the Boston real estate market: 

* Principal component analysis
* Singular value decomposition
* Bottleneck neural networks

The different methods are compared based on how well they can discriminate between different house price classes. 

The folder ```R``` contains the RStudio script for the implementation and the Rmarkdown file for generating the report. 

The Dockerfile runs a session of RStudio Server to ensure reproducibility of results. See https://github.com/vettorefburana/Run-Rstudio-Server-from-Docker for instructions on how to run the Docker container.


