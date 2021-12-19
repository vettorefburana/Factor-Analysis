
.libPaths(new = "/packages")
library(markdown)

source("./R/factor_analysis.R")
rmarkdown::render("./R/report_factor_analysis.Rmd")