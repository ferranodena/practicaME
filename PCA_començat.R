################################################################################
#
# ME - GIA. PCA Introduction (1)
#
#--------------------------------------
# Conceptes
#--------------------------------------
#
# Principal components
# Loadings
# Screeplot
# Biplot
################################################################################

##-- Load necessary libraries
library(ggplot2)      # For advanced plotting
library(FactoMineR)   # For PCA and supplementary variables
library(factoextra)   # For PCA visualization

##-- Load the wine dataset
student_data <- read.csv("C:/Users/polri/Downloads/clean-data.csv", header=TRUE, sep=',')

# Elimina les variables redundants indicades explícitament
variables_a_eliminar <- c(
  "Curricular_units_1st_sem_credited",
  "Curricular_units_1st_sem_evaluations",
  "Curricular_units_1st_sem_without_evaluations",
  "Curricular_units_2nd_sem_credited",
  "Curricular_units_2nd_sem_evaluations",
  "Curricular_units_2nd_sem_without_evaluations",
  "Application_order",
  "Gender"
)

student_data <- student_data[, !(names(student_data) %in% variables_a_eliminar)]
cat('Variables eliminades:', paste(variables_a_eliminar, collapse = ', '), '\n')

##-- Inspect
View(student_data)
summary(student_data)

# Only numeric variables
numeric_student_data <- student_data[, sapply(student_data, is.numeric)]

##-- Step 1: Scale the data to ensure all features have equal weight in PCA
student_data_scaled <- scale(numeric_student_data)

##-- Step 2: Perform PCA using prcomp, with centering and scaling
pca_result <- prcomp(student_data_scaled)

##-- Compare
# VAPs
pca_result$sdev                           # standard deviations of principal components
sqrt(eigen(cov(student_data_scaled))$values) # square roots of eigenvalues

# VEPs
pca_result$rotation[,1]                     # loadings
eigen(cov(student_data_scaled))$vec[,1]        # eigenvectors

##-- Step 3: Scree Plot - visualizing the variance explained by each principal component
plot(pca_result)             # first option
plot(pca_result, type='l')   # second option
# third option
fviz_screeplot(pca_result, addlabels = TRUE, ylim = c(0, 50)) +
  ggtitle("Scree Plot: Variance Explained by Each Component") +
  xlab("Principal Component") +
  ylab("Percentage of Variance Explained")

# How many components?
summary(pca_result)

# Step 4: Graphical representation
# Individuals
fviz_pca_ind(pca_result, 
             repel = TRUE,          # Avoid overlapping text labels
             geom = c("point"),
             col.ind = "red",       # Color of individuals
             title = "Individuals") +
  theme_minimal()

# Variables
fviz_pca_var(pca_result, 
             repel = TRUE,          # Avoid overlapping text labels
             col.var = "blue",       # Color of individuals
             title = "Variables") +
  theme_minimal()


# Biplot - showing both variables and observations in PCA space
fviz_pca_biplot(pca_result, 
                repel = TRUE,          # Avoid overlapping text labels
                geom = c("point"),
                col.var = "blue",      # Color of variable arrows
                col.ind = "red",       # Color of individuals
                alpha.ind = 0.4,
                title = "PCA Biplot of Wine Data") +
  theme_minimal()

# Biplot - Axes 1 and 3
fviz_pca_biplot(pca_result,
                axes = c(1, 3),
                repel = TRUE,          # Avoid overlapping text labels
                geom = c("point"),
                col.var = "blue",      # Color of variable arrows
                col.ind = "red",       # Color of individuals
                alpha.ind = 0.4,
                title = "PCA Biplot of Wine Data") +
  theme_minimal()

# Additional Step: Visualize the individual contributions of variables to each component
fviz_pca_var(pca_result, col.var = "contrib", 
             gradient.cols = c("blue", "yellow", "red"),
             title = "Contribution of Variables to PCA Components") +
  theme_minimal()

# New components
head(pca_result$x)
