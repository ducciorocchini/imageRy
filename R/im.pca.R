im.pca <- function(x){
# random sample
set.seed(1)
sr <- spatSample(x, 10000, method="random")
# principal component
pca <- prcomp(sr)
# variance explained
summary(pca)
# pc map
pci <- predict(x, pca, index = 1:2)
plot(pci[[1]])
}