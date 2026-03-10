# imageRy

![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)
![Made with R](https://img.shields.io/badge/Made%20with-R-blue.svg)
![GitHub last commit](https://img.shields.io/github/last-commit/ducciorocchini/imageRy)
![CRAN status](https://www.r-pkg.org/badges/version/imageRy)
![CRAN downloads](https://cranlogs.r-pkg.org/badges/imageRy)

<p align="center">
  <img
    src="https://github.com/user-attachments/assets/9ee62cc3-8d56-4ccf-bb98-8e0427729a82"
    alt="imageRy logo"
    width="300"
  />
</p>

**Tools for manipulating, visualizing, and exporting raster images in R** — designed as an educational resource for students and practitioners of remote sensing. ([R Archive Network][1])

---

## 📦 Package Overview

**imageRy** is an R package that simplifies fundamental raster image operations such as import, classification, vegetation indexes, visualization, and export. It builds on top of **terra** and **ggplot2** for handling spatial data and plotting. ([R Archive Network][1])

---

## 📁 Repository Structure

```
imageRy/
├── R/
│   ├── im.classify.R
│   ├── im.dvi.R
│   ├── im.export.R
│   ├── im.fuzzy.R
│   ├── im.ggplot.R
│   ├── im.kernel.R
│   ├── im.import.R
│   ├── im.list.R
│   ├── im.multiframe.R
│   ├── im.ndvi.R
│   ├── im.pca.R
│   ├── im.plotRGB.R
│   ├── im.plotRGB.auto.R
│   ├── im.print.R
│   └── im.ridgeline.R
├── man/
│   ├── *.Rd
│   └── documentation for exported functions
├── tests/
│   └── testthat/
│       └── test-*.R
├── inst/
│   └── images/
│       └── example raster data files
├── data_description.md
├── README.md
├── DESCRIPTION
├── NAMESPACE
├── vignette.html
├── imageRy.html
└── imageRy_rapid_manual.html
```

---

## 📌 What’s Inside

### 🔹 `R/`

All of the **R code** lives here — one file per function. These include core utility functions such as:

* `im.import()` — load one or more raster images
* `im.export()` — save rasters to GeoTIFF/PNG/JPG
* `im.classify()` — unsupervised classification with k-means
* `im.ndvi()` / `im.dvi()` — vegetation indexes
* `im.ggplot()` — ggplot2 visualizations
* `im.plotRGB()` / `im.plotRGB.auto()` — RGB composites
* `im.multiframe()` — layout multiple plots
* `im.ridgeline()` — ridgeline density plots
* `im.print()` — simple package info output
* `im.list()` — list bundled example data

Each function has appropriate documentation and is exported through the **NAMESPACE**. ([cran.r-universe.dev][2])

---

### 📄 `man/`

Contains **Rd documentation files** for every exported function so that users can access manual pages via `?function_name()` in R.

---

### 🧪 `tests/`

Contains **unit tests** (likely using *testthat*) to check expected behavior of functions and ensure package reliability.

---

### 📦 `inst/images`

Example image files included for demonstration and testing. These are installed with the package and can be referenced in examples and vignettes.

---

### 📘 Documentation & Vignettes

* **vignette.html** — a comprehensive user guide / tutorial
* **imageRy.html** — full reference manual
* **imageRy_rapid_manual.html** — a rapid manual for quick usage examples
* **data_description.md** — explanation of example datasets

---

### 🧾 `DESCRIPTION`

Standard R package metadata, including:

* Package name and version
* Authors and maintainers
* Dependencies: *terra*, *ggplot2*, *viridis*, etc.
* Suggested packages for testing and vignettes ([R Archive Network][1])

---

## 🛠 Installation

You can install **imageRy** from CRAN or directly from GitHub if desired:

```r
# From CRAN/universe
install.packages("imageRy")

# Or from GitHub
# remotes::install_github("ducciorocchini/imageRy")
```

---

## 📌 Notes

* Designed primarily as a **teaching tool** in remote sensing and raster analysis. ([R Archive Network][1])
* Built to integrate with well-known R spatial workflows using **terra** and **ggplot2**.

---

## ❓ Getting Help

* Browse the vignette and manual in `inst/doc/`
* Use `help(package = "imageRy")` in R
* Raise issues on GitHub

---
[1]: https://cran.r-project.org/web//packages/imageRy/imageRy.pdf?utm_source=chatgpt.com "Package ‘imageRy’ - The Comprehensive R Archive Network"
[2]: https://cran.r-universe.dev/imageRy?utm_source=chatgpt.com "imageRy: Modify and Share Images"

---

## Ongoing

> Check greenland data import

> horizontal and vertical coloring in im.ridgeline() (optional)

<details>
<summary>R code click here </summary>
 
``` r
#' Generate Ridgeline Plots from Satellite Raster Data
#'
#' This function generates ridgeline plots from stacked satellite imagery data.
#'
#' @param im A `SpatRaster` object representing the raster data to be visualized.
#' @param scale A numeric value that defines the vertical scale of the ridgeline plot.
#' @param palette A character string specifying the `viridis` color palette option to use.
#' Available options: `"viridis"`, `"magma"`, `"plasma"`, `"inferno"`, `"cividis"`, `"mako"`, `"rocket"`, `"turbo"`.
#'
#' @return A `ggplot` object displaying the ridgeline plot.
#'
#' @details
#' Ridgeline plots are useful for analyzing temporal variations in raster-based satellite imagery.
#' This function extracts raster values and visualizes their distribution across layers.
#'
#' @references
#' See also `im.import()`, `im.ggplot()`.
#'
#' @seealso [GitHub Repository](https://github.com/ducciorocchini/imageRy/)
#'
#' @examples
#' library(terra)
#' library(ggridges)
#' library(ggplot2)
#'
#' # Create a 5-layer raster
#' r <- rast(nrows = 10, ncols = 10, nlyrs = 5)
#' values(r) <- runif(ncell(r) * 5)
#'
#' # Generate ridgeline plot
#' im.ridgeline(r, scale = 2, palette = "viridis") + theme_minimal()
#' @export
im.ridgeline22 <- function(im, scale, dir = c("h", "v"), palette = c("viridis", "magma", "plasma", "inferno", "cividis", "mako", "rocket", "turbo")) {
  
  palette <- palette[1]
  
  #Checking inputs
  if(!is(im, "SpatRaster")) stop("im must be a SpatRaster")
  if(!is.numeric(scale)) stop("scale must be numeric")
  if(!is.character(palette)) stop("palette must be a character")
  if(!palette %in% c("viridis", "magma", "plasma", "inferno", "cividis", "mako", "rocket", "turbo")) stop("palette must be one of the color options in the viridis package (viridis, magma, plasma, inferno, cividis, mako, rocket, turbo)")
  if(!dir %in% c("h", "v")) stop("dir must be horizontal (h) or vertical (v)")
  
  switch(palette, 
         viridis = 'D',
         magma = 'A',
         inferno = 'B',
         plasma = 'C',
         cividis = 'E',
         rocket = 'F',
         mako = 'G',
         turbo = 'H')
  
  #Transforming im in a dataframe
  df <- as.data.frame(im, wide = FALSE)
  
  #Final graph
  if(dir == "h") {
    pl <- ggplot2::ggplot(df, ggplot2::aes(x = values, y = layer, fill = after_stat(x))) +
      ggridges::geom_density_ridges_gradient(scale = scale, rel_min_height = 0.01) +
      ggplot2::scale_fill_viridis_c(option = palette)
  } else {
    pl <- ggplot2::ggplot(df, ggplot2::aes(x = values, y = layer, fill = after_stat(y))) +
      ggridges::geom_density_ridges_gradient(scale = scale, rel_min_height = 0.01) +
      ggplot2::scale_fill_viridis_c(option = palette)
  }
  
  return(pl)
 
}
```
 </details>

> Fuzzy classification
``` r
im.fuzzyclass()
```

> Avoid alphabetical order and use elements
``` r 
im.ridgeline()
```

> In PCA, retain the whole set
``` r
im.pca()
```

> im.flip()
``` r
im.flip <- function(a){
a = flip(a)
plot(a)
return(a)
}
```

> im.export()

> im.ggplpotRGB()

> im.ggplot() # insert different color ramp palettes

> ggpairs() with images

> stretch in im.plotRGB()
