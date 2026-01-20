\name{im.fuzzy}
\alias{im.fuzzy}
\title{Fuzzy image clustering and membership maps}
\description{
Performs fuzzy clustering of a \code{terra} \code{SpatRaster} image by first
running k-means to estimate cluster centers and then computing fuzzy
memberships from pixel-to-center distances using a fuzzifier parameter.
Returns distance and membership rasters for each class, along with cluster centers.
}
\usage{
im.fuzzy(
  input_image,
  num_clusters = 3,
  seed = NULL,
  m = 2,
  do_plot = TRUE,
  custom_colors = NULL,
  num_colors = 100
)
}
\arguments{
  \item{input_image}{
A \code{\link[terra:SpatRaster-class]{SpatRaster}}. One or more layers (bands) are used as features for clustering.
All pixels with \code{NA} in any band are excluded from the analysis.
}
  \item{num_clusters}{
Integer. Number of clusters (classes) to compute.
}
  \item{seed}{
Integer or \code{NULL}. If provided, sets a reproducible random seed before running k-means.
}
  \item{m}{
Numeric. Fuzzifier (\eqn{m > 1}) controlling the degree of fuzziness in the membership assignment.
A common choice is \eqn{m = 2}.
}
  \item{do_plot}{
Logical. If \code{TRUE}, plots the membership rasters using \code{\link[terra]{plot}}.
}
  \item{custom_colors}{
Character vector of colors used to build a palette. If \code{NULL}, a default set of colors is used.
If fewer colors than \code{num_clusters} are provided, colors are interpolated.
}
  \item{num_colors}{
Integer. Number of colors to generate for the palette. Currently not used by the function output
(but kept for compatibility and future plotting customization).
}
}
\value{
A named list with:
\describe{
  \item{distances}{A \code{SpatRaster} with \code{num_clusters} layers giving the distance of each pixel to each cluster center.}
  \item{memberships}{A \code{SpatRaster} with \code{num_clusters} layers giving fuzzy membership values in \eqn{[0,1]} for each cluster.}
  \item{centers}{A numeric matrix of k-means cluster centers with \code{num_clusters} rows and one column per input band (scaled to 0--255).}
}
}
\details{
Pixel values are extracted from \code{input_image} and only complete cases across all bands are retained.
Each band is independently rescaled to the range 0--255 prior to clustering (constant bands are set to 0).
Cluster centers are obtained via \code{\link[stats]{kmeans}}.

For each pixel, Euclidean distances to all centers are computed, and fuzzy memberships are derived from distances as:
\deqn{
u_k(x) = \left[\sum_{j=1}^{K} \left(\frac{d_k(x)}{d_j(x)}\right)^{\frac{2}{m-1}}\right]^{-1},
}
where \eqn{d_k(x)} is the distance from pixel \eqn{x} to center \eqn{k}, \eqn{K} is the number of clusters,
and \eqn{m} is the fuzzifier. Exact matches to a center (distance 0) are handled by assigning equal membership
among the zero-distance centers.
}
\examples{
\dontrun{
library(terra)

# Example raster (replace with your own)
r <- rast(system.file("ex/logo.tif", package = "terra"))

res <- im.fuzzy(r, num_clusters = 4, m = 2, seed = 1, do_plot = TRUE)

res$memberships
res$distances
res$centers
}
}
\seealso{
\code{\link[terra:SpatRaster-class]{SpatRaster}},
\code{\link[stats]{kmeans}}
}
\author{
Duccio Rocchini
}
