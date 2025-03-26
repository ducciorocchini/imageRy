#' Export a Raster to GeoTIFF, PNG, or JPG
#'
#' This function saves a `SpatRaster` object to disk in **GeoTIFF**, **PNG**, or **JPG** format.
#'
#' @param x A `SpatRaster` object representing the raster to be saved.
#' @param filename A character string specifying the output file path with `.tif`, `.png`, or `.jpg` extension.
#' @param overwrite A logical value indicating whether to overwrite an existing file (default: TRUE).
#'
#' @return No return value. The function writes the raster to disk.
#'
#' @details
#' - **GeoTIFF (`.tif`)**: Uses `terra::writeRaster()`, preserving geospatial information.
#' - **PNG/JPG (`.png`, `.jpg`, `.jpeg`)**: Converts the raster to an image and saves it with `png()` or `jpeg()`.
#' - **If the raster has multiple bands**, only the first band is saved in PNG/JPG format.
#'
#' @seealso [im.import()], [writeRaster()]
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Create a sample raster
#' r <- rast(nrows = 10, ncols = 10)
#' values(r) <- runif(ncell(r))
#'
#' # Export as GeoTIFF
#' im.export(r, "output.tif")
#'
#' # Export as PNG
#' im.export(r, "output.png")
#' }
#'
#' @export
im.export <- function(x, filename, overwrite = TRUE) {
  
  # Validate that x is a SpatRaster object
  if (!inherits(x, "SpatRaster")) {
    stop("Input must be a SpatRaster object.")
  }
  
  # Validate that filename is a character string
  if (!is.character(filename) || length(filename) != 1) {
    stop("Filename must be a single character string.")
  }
  
  # Detect file extension
  ext <- tolower(tools::file_ext(filename))
  
  # Handle GeoTIFF export
  if (ext == "tif") {
    writeRaster(x, filename, overwrite = overwrite, wopt = list(datatype = "FLT4S"))
    message("Raster successfully exported as GeoTIFF: ", filename)
    
    # Handle PNG/JPG export (convert to image)
  } else if (ext %in% c("png", "jpg", "jpeg")) {
    
    # Convert raster to a matrix for image export
    img <- as.matrix(x[[1]])  # Use only the first band
    img <- (img - min(img, na.rm = TRUE)) / (max(img, na.rm = TRUE) - min(img, na.rm = TRUE))  # Normalize
    
    if (ext == "png") {
      png(filename, width = ncol(img), height = nrow(img))
      par(mar = c(0, 0, 0, 0))  # Remove margins
      image(img, col = gray.colors(256), axes = FALSE)
      dev.off()
      message("Raster successfully exported as PNG: ", filename)
      
    } else if (ext %in% c("jpg", "jpeg")) {
      jpeg(filename, width = ncol(img), height = nrow(img))
      par(mar = c(0, 0, 0, 0))
      image(img, col = gray.colors(256), axes = FALSE)
      dev.off()
      message("Raster successfully exported as JPG: ", filename)
    }
    
  } else {
    stop("Unsupported file format. Use '.tif', '.png', or '.jpg'.")
  }
}
