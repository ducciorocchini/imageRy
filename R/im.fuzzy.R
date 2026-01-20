#' Fuzzy clustering of a raster image (k-means + fuzzy memberships)
#'
#' Performs fuzzy classification of a \code{SpatRaster} image by first estimating
#' cluster centers with k-means and then computing fuzzy membership maps from
#' pixel-to-center distances using a fuzzifier parameter \code{m}.
#'
#' @param input_image A \code{SpatRaster} object containing one or more bands to be used as features.
#'   Pixels with \code{NA} in any band are excluded from the analysis.
#' @param num_clusters Integer. Number of clusters (classes) to compute. Default: \code{3}.
#' @param seed Integer or \code{NULL}. Optional random seed for reproducible k-means results. Default: \code{NULL}.
#' @param m Numeric. Fuzzifier parameter (\eqn{m > 1}) controlling the degree of fuzziness in membership assignment;
#'   a common choice is \eqn{m = 2}. Default: \code{2}.
#' @param do_plot Logical. If \code{TRUE}, membership rasters are plotted using \code{\link[terra]{plot}}. Default: \code{TRUE}.
#' @param custom_colors Character vector. Optional custom colors used to build a plotting palette. If \code{NULL},
#'   a default palette is used. If fewer colors than \code{num_clusters} are provided, colors are interpolated.
#' @param num_colors Integer. Number of colors to generate for plotting palettes (when plotting). Default: \code{100}.
#'
#' @return A named \code{list} with components:
#' \describe{
#'   \item{distances}{A \code{SpatRaster} with \code{num_clusters} layers giving the Euclidean distance of each valid pixel to each cluster center.}
#'   \item{memberships}{A \code{SpatRaster} with \code{num_clusters} layers giving fuzzy membership values in \eqn{[0,1]} for each cluster (memberships per valid pixel sum to 1 across classes).}
#'   \item{centers}{A numeric matrix of k-means cluster centers with \code{num_clusters} rows and one column per input band (bands scaled to 0--255 prior to clustering).}
#' }
#'
#' @details
#' Pixel values are extracted from \code{input_image} and only complete cases across all bands are retained.
#' Each band is independently rescaled to the range \eqn{0-255} (constant bands are set to 0) prior to clustering.
#' Cluster centers are estimated with \code{\link[stats]{kmeans}} on non-\code{NA} pixels.
#'
#' For each valid pixel, Euclidean distances to all centers are computed and fuzzy memberships are derived from distances as:
#' \deqn{u_k(x) = \left[\sum_{j=1}^{K} \left(\frac{d_k(x)}{d_j(x)}\right)^{\frac{2}{m-1}}\right]^{-1},}
#' where \eqn{d_k(x)} is the distance from pixel \eqn{x} to center \eqn{k}, \eqn{K} is the number of clusters,
#' and \eqn{m} is the fuzzifier. If a pixel matches one or more centers exactly (distance 0),
#' membership is equally shared among the zero-distance centers.
#'
#' If \code{do_plot = TRUE}, membership rasters are displayed using the selected palette.
#'
#' @references
#' Fuzzy C-means / membership formulas are standard (see Bezdek, 1981). K-means is used here to obtain initial centers.
#' @seealso \code{\link[stats]{kmeans}}, \code{\link[terra:SpatRaster-class]{SpatRaster}}, \code{\link[grDevices]{colorRampPalette}}
#'
#' @examples
#' \dontrun{
#' library(terra)
#' # Load example image (replace with your own)
#' r <- rast(system.file("ex/logo.tif", package = "terra"))
#'
#' # Run fuzzy clustering with 4 clusters
#' res <- im.fuzzy(r, num_clusters = 4, m = 2, seed = 1, do_plot = TRUE)
#'
#' # Inspect outputs
#' res$memberships
#' res$distances
#' res$centers
#' }
#'
#' @export
