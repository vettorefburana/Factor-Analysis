# Factor-Analysis

Factor analysis using PCA, SVD and bottleneck neural network (BNN) autoencoders using the Boston Housing dataset.

Objective: 
----------------------------------------------------------------------------------------------------------------------

Implement and compare different factor analysis techniques using data on the Boston real estate market: 

* Principal component analysis
* Singular value decomposition
* Bottleneck neural networks

Factor analysis is generally used for dimensionality reduction, which is achieved by identifying a low number of latent factors that are able to capture the variability of the data without too much loss of information.  

The different methods are compared based on how well they can discriminate between different house price classes. 

Execution: 
------------------------------------------------------------------------------------------------------------------------

The folder ```R``` contains the RStudio script for the implementation and the Rmarkdown file for generating the report. 

The Dockerfile runs a session of RStudio Server to ensure reproducibility of results. See https://github.com/vettorefburana/Run-Rstudio-Server-from-Docker for instructions on how to run the Docker container.

References: 
-------------------------------------------------------------------------------------------------------------------------
Friedman, J., Hastie, T., & Tibshirani, R. (2001). The elements of statistical learning (Vol. 1, No. 10). New York: Springer series in statistics.

James, G., Witten, D., Hastie, T., Tibshirani, R. (2015). An Introduction to Statistical Learning.
With Applications in R. Corrected 6th printing. Springer Texts in Statistics.

Harrison Jr, D., & Rubinfeld, D. L. (1978). Hedonic housing prices and the demand for clean air. Journal of environmental economics and management, 5(1), 81-102.

Hinton, G.E., Salakhutdinov, R.R. (2006). Reducing the dimensionality of data with neural networks.
Science 313, 504-507.

Hothorn, T., Everitt, B.S. (2014). A Handbook of Statistical Analyses using R. 3rd edition. CRC
Press

Kramer, M.A. (1991). Nonlinear principal component analysis using autoassociative neural networks.
AIChE Journal 37/2, 233-243.

Rentzmann, S., & Wuthrich, M. V. (2019). Unsupervised Learning: What is a Sports Car?. Available at SSRN 3439358.
