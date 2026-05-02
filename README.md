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

```text
imageRy/
├── R/
│   ├── im.barplot.R
│   ├── im.boxplot.R
│   ├── im.classify.R
│   ├── im.dvi.R
│   ├── im.export.R
│   ├── im.fuzzy.R
│   ├── im.ggplot.R
│   ├── im.ggplotRGB.R
│   ├── im.import.R
│   ├── im.kernel.R
│   ├── im.list.R
│   ├── im.multiframe.R
│   ├── im.ndvi.R
│   ├── im.pca.R
│   ├── im.plotRGB.R
│   ├── im.plotRGB.auto.R
│   ├── im.print.R
│   └── im.ridgeline.R
│
├── inst/
│   └── images/
│       └── example remotely sensed raster datasets
│
├── man/
│   ├── im.barplot.Rd
│   ├── im.boxplot.Rd
│   ├── im.classify.Rd
│   ├── im.dvi.Rd
│   ├── im.export.Rd
│   ├── im.fuzzy.Rd
│   ├── im.ggplot.Rd
│   ├── im.ggplotRGB.Rd
│   ├── im.import.Rd
│   ├── im.kernel.Rd
│   ├── im.list.Rd
│   ├── im.multiframe.Rd
│   ├── im.ndvi.Rd
│   ├── im.pca.Rd
│   ├── im.plotRGB.Rd
│   ├── im.plotRGB.auto.Rd
│   ├── im.print.Rd
│   └── im.ridgeline.Rd
│
├── tests/
│   └── testthat/
│       └── test-*.R
│
├── vignette/
│   └── vignette.md
│
├── DESCRIPTION
├── NAMESPACE
├── README.md
├── data_description.md
```
---

Here is a **revised “What’s Inside” section** aligned with the new positioning of *imageRy* (framework + statistical visualization layer, not just utilities):

---

## 📌 What’s Inside

### 🔹 `R/`

All core **R functions** are implemented here, organized around a unified workflow that connects data access, spatial analysis, and statistical visualization. Each file contains a single function, contributing to different components of the analytical framework:

#### **📥 Data access and import**

* `im.list()` — list available bundled raster datasets
* `im.import()` — load raster images as `SpatRaster` objects
* `im.export()` — export raster outputs to standard formats (GeoTIFF, PNG, JPG)

#### **🛰️ Remote sensing analysis**

* `im.classify()` — unsupervised classification using k-means
* `im.fuzzy()` — fuzzy classification with probabilistic membership
* `im.ndvi()` / `im.dvi()` — vegetation indices
* `im.kernel()` — moving-window statistics (e.g., SD, mean, variability)
* `im.pca()` — principal component analysis

#### **🎨 Spatial visualization**

* `im.plotRGB()` / `im.plotRGB.auto()` — RGB composites
* `im.ggplot()` — raster visualization using `ggplot2`
* `im.ggplotRGB()` — RGB visualization within the `ggplot2` framework
* `im.multiframe()` — arrange multiple plots

#### **📊 Statistical visualization layer (core novelty)**

* `im.ridgeline()` — distribution of raster values across layers
* `im.barplot()` — class proportions and frequencies
* `im.boxplot()` — spectral distributions across classes

These functions share a common design: they transform raster data into structured representations (spatial or statistical), enabling users to move seamlessly between maps and distributional interpretation within a single workflow.

All functions are fully documented and exported via the **NAMESPACE**.

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
