# \name{im.classify{imageRy}}
# \alias{im.classify}
# \title{
# Image pixels classification
# }
# \description{
# Unsupervised classification of a given SpatRaster.
# }
# \usage{
# im.classify(x, num_clusters = 3, seed = NULL,
#             do_plot = TRUE, use_viridis = TRUE,
#             colors = c('yellow','black','red'),
#             num_colors = 100)
# }
# \arguments{
#   \item{x}{a SpatRaster object}
#   \item{num_clusters}{cluster number (numeric)}
#   \item{seed}{TRUE for setting the seed on, FALSE to set it off}
#   \item{do_plot}{TRUE to plot the result}
#   \item{use_viridis}{TRUE to use viridis}
#   \item{colors}{a vector containing color names to personalize the palette for the plot}
#   \item{num_colors}{color hues (numeric)}
# }
# \details{
# The classification of the image is made using kmeans() function from stats package.
# The algorithm divides the pixels in clusters based on their similarities creating the number of classes specified by the user.
# }
# \value{
# SpatRaster
# }
# \references{
# Check kmeans(), set.seed()
# }
# \author{
# Ludovico Chieffallo, Elisa Thouverai, Duccio Rocchini
# }
# \note{
# }
# \seealso{
# https://github.com/ducciorocchini/imageRy/
# }
# \examples{
# GL15 <- im.import("greenland.2015.tif")
# im.classify(GL15, num_clusters = 3, seed = NULL,
#             do_plot = TRUE, use_viridis = TRUE,
#             colors = c('yellow','black','red'),
#             num_colors = 100)
