\name{im.parallel}
\alias{im.parallel}
\title{Visualize Temporal Class Transitions Using Parallel Sets}
\usage{
im.parallel(
  input_classification,
  axis_labels = NULL,
  custom_colors = NULL,
  alpha = 0.7,
  axis.width = 0.13
)
}
\arguments{
  \item{input_classification}{A list returned by \code{im.classify.timeseries()},
  containing at least two classified \code{SpatRaster} objects in its
  \code{result} element.}

  \item{axis_labels}{Optional vector of labels for the temporal axes.
  If \code{NULL}, the names of the classified images are used.
  Defaults to \code{NULL}.}

  \item{custom_colors}{Optional character vector of colors used to represent
  classes according to their membership at the first time step.
  If \code{NULL}, a viridis palette is used. Defaults to \code{NULL}.}

  \item{alpha}{Numeric. Transparency of the flows between classes.
  Defaults to 0.7.}

  \item{axis.width}{Numeric. Width of the flow segments at the axes.
  Defaults to 0.13. The vertical category bars themselves have a fixed
  width of 0.1.}
}
\description{
Creates a parallel sets diagram showing temporal transitions among classes
in a series of raster classifications. Flow widths represent the numbers of
pixels following each class trajectory across time.
}
\details{
The function uses the classified images stored in the \code{result} element
of the output of \code{im.classify.timeseries()}. It combines these images
into a raster stack and extracts pixel classifications across all time steps.
Pixels containing missing values at any time step are excluded.

Unique sequences of class memberships are identified and counted. Each
vertical axis represents a time step, and each category represents a class.
The width of each flow is proportional to the number of pixels following
that temporal trajectory.

Flows are colored according to the class at the first time step, making it
possible to follow the persistence and transitions of initial classes.
By default, the viridis palette is used; \code{custom_colors} can specify
an alternative palette. The \code{axis_labels} argument customizes the
labels displayed along the horizontal axis, while \code{alpha} controls
flow transparency and \code{axis.width} controls the width of flow
segments at each axis.

Because the underlying classifications use common k-means cluster centers,
class labels remain consistent across time. This makes the visualization
useful for investigating land-cover transitions, vegetation dynamics,
and temporal ecological patterns.

The function returns a \code{ggplot2} object that can be further customized
with additional \code{ggplot2} layers.
}
\value{
A \code{ggplot2} object containing a parallel sets diagram of temporal
class transitions.
}
\seealso{
\code{\link{im.classify.timeseries}},
\code{\link{im.classify}},
\code{\link{im.barplot}}
}
\examples{
\dontrun{
library(terra)

# Create three example raster images with three spectral bands
r1 <- rast(nrows = 50, ncols = 50, nlyrs = 3)
values(r1) <- matrix(runif(ncell(r1) * 3), ncol = 3)

r2 <- rast(r1)
values(r2) <- matrix(runif(ncell(r2) * 3), ncol = 3)

r3 <- rast(r1)
values(r3) <- matrix(runif(ncell(r3) * 3), ncol = 3)

# Organize images into a time series
images <- list(time1 = r1, time2 = r2, time3 = r3)

# Perform common k-means classification
classified <- im.classify.timeseries(
  images,
  num_clusters = 3,
  seed = 42,
  do_plot = FALSE
)

# Visualize temporal class transitions
im.parallel(classified)

# Use custom axis labels
im.parallel(
  classified,
  axis_labels = c("Year 1", "Year 2", "Year 3")
)

# Use custom colors
im.parallel(
  classified,
  custom_colors = c("forestgreen", "gold", "firebrick")
)

# Adjust transparency and axis width
im.parallel(
  classified,
  alpha = 0.5,
  axis.width = 0.2
)
}
}
