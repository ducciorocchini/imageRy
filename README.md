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
│   ├── im.bivariate.R
│   ├── im.boxplot.classes.R
│   ├── im.boxplot.layers.R
│   ├── im.classify.R
│   ├── im.dvi.R
│   ├── im.export.R
│   ├── im.fuzzy.R
│   ├── im.ggplot.R
│   ├── im.ggplotRGB.R
│   ├── im.import.R
│   ├── im.kernel.R
│   ├── im.levelplot.R
│   ├── im.list.R
│   ├── im.multiframe.R
│   ├── im.ndvi.R
│   ├── im.pairs.R
│   ├── im.pca.R
│   ├── im.plotRGB.R
│   ├── im.plotRGB.auto.R
│   ├── im.print.R
│   ├── im.refresh.R
│   └── im.ridgeline.R
│
├── inst/
│   └── images/
│       └── example remotely sensed raster datasets
│
├── man/
│   ├── im.barplot.Rd
│   ├── im.bivariate.Rd
│   ├── im.boxplot.classes.Rd
│   ├── im.boxplot.layers.Rd
│   ├── im.classify.Rd
│   ├── im.dvi.Rd
│   ├── im.export.Rd
│   ├── im.fuzzy.Rd
│   ├── im.ggplot.Rd
│   ├── im.ggplotRGB.Rd
│   ├── im.import.Rd
│   ├── im.kernel.Rd
│   ├── im.levelplot.Rd
│   ├── im.list.Rd
│   ├── im.multiframe.Rd
│   ├── im.ndvi.Rd
│   ├── im.pairs.Rd
│   ├── im.pca.Rd
│   ├── im.plotRGB.Rd
│   ├── im.plotRGB.auto.Rd
│   ├── im.print.Rd
│   ├── im.refresh.Rd
│   └── im.ridgeline.Rd
│
├── tests/
│   └── testthat/
│       └── test-*.R
│
├── vignette/
│   ├── imagery_vignette_update_files/
│   │   └── figure-gfm/
│   │       ├── im.barplot basic use-1.png
│   │       ├── im.barplot options-1.png
│   │       ├── im.bivariate-1.png
│   │       ├── im.boxplot.classes basic use-1.png
│   │       ├── im.boxplot.classes options-1.png
│   │       ├── im.boxplot.classes options-2.png
│   │       ├── im.boxplot.layers simple usage-1.png
│   │       ├── im.boxplot.layers usage-1.png
│   │       ├── im.boxplot.layers violin-1.png
│   │       ├── im.classify-1.png
│   │       ├── im.dvi plot-1.png
│   │       ├── im.fuzzy rasters-1.png
│   │       ├── im.fuzzy rasters-2.png
│   │       ├── im.fuzzy-1.png
│   │       ├── im.ggplot layerfill-1.png
│   │       ├── im.ggplot-1.png
│   │       ├── im.ggplotRGB-1.png
│   │       ├── im.import-1.png
│   │       ├── im.kernel-1.png
│   │       ├── im.levelplot basic usage-1.png
│   │       ├── im.levelplot usage-1.png
│   │       ├── im.levelplot usage-2.png
│   │       ├── im.multiframe-1.png
│   │       ├── im.ndvi-1.png
│   │       ├── im.pairs simple usage-1.png
│   │       ├── im.pairs usage-1.png
│   │       ├── im.pca-1.png
│   │       ├── im.plotRGB-1.png
│   │       ├── im.plotRGB.auto-1.png
│   │       ├── im.ridgeline direction-1.png
│   │       └── im.ridgeline-1.png
│   │
│   └── vignette.md
│
├── DESCRIPTION
└── NAMESPACE
├── README.md
└── data_description.md
```
---

Here is a **revised “What’s Inside” section** aligned with the new positioning of *imageRy* (framework + statistical visualization layer, not just utilities):

---

## 📌 What’s Inside

### 🔹 `R/`

All core **R functions** are implemented here, organized around a unified workflow that connects data access, spatial analysis, and statistical visualization. Each file contains a single function, contributing to different components of the analytical framework:

#### **📥 Data access and import**

- `im.list()` — list available bundled raster datasets
- `im.import()` — import raster images as `SpatRaster` objects
- `im.export()` — export raster outputs to standard formats
- `im.print()` — print raster information and package outputs
- `im.refresh()` — refresh the imageRy working environment

#### **🛰️ Remote sensing analysis**

- `im.classify()` — unsupervised raster classification using k-means
- `im.fuzzy()` — fuzzy classification with probabilistic membership
- `im.ndvi()` — calculate the Normalized Difference Vegetation Index (NDVI)
- `im.dvi()` — calculate the Difference Vegetation Index (DVI)
- `im.kernel()` — calculate moving-window statistics on raster data
- `im.pca()` — perform principal component analysis on raster layers

#### **🔗 Multivariate and spatial relationships**

- `im.bivariate()` — explore and visualize relationships between two raster variables
- `im.pairs()` — explore pairwise relationships among multiple raster layers

#### **🗺️ Raster and RGB visualization**

- `im.plotRGB()` — create RGB raster composites
- `im.plotRGB.auto()` — automatically create RGB composites
- `im.ggplot()` — visualize raster data using `ggplot2`
- `im.ggplotRGB()` — create RGB raster visualizations within the `ggplot2` framework
- `im.multiframe()` — arrange multiple graphical outputs in the same plotting window

#### **📊 Distribution-based and statistical visualization**

- `im.levelplot()` — explore the spatial distribution of raster values with optional row- and column-wise marginal summaries
- `im.ridgeline()` — explore raster-value distributions across multiple layers using kernel density ridgelines
- `im.boxplot.layers()` — compare distributions among raster layers using boxplots, half-eye kernel density estimates or violin plots, with optional non-parametric statistical testing
- `im.boxplot.classes()` — compare raster-value distributions among discrete spatial classes using boxplots, half-eye kernel density estimates or violin plots, with optional Wilcoxon or Kruskal–Wallis tests
- `im.barplot()` — visualize class proportions and frequencies

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

### 🧾 `DESCRIPTION`

Standard R package metadata, including:

* Package name and version
* Authors and maintainers
* Dependencies: *terra*, *ggplot2*, *viridis*, etc.
* Suggested packages for testing and vignettes ([R Archive Network][1])

---

## 🛠 Installation

From GitHub with new functions:

```r
From GitHub with new functions
remotes::install_github("ducciorocchini/imageRy")
```

---

## 📌 Notes

* Designed primarily as a **teaching tool** in remote sensing and raster analysis. ([R Archive Network][1])
* Built to integrate with well-known R spatial workflows using **terra** and **ggplot2**.

---

## ❓ Getting Help

* Browse the vignette 
* Use `help(package = "imageRy")` in R
* Raise issues on GitHub

---

## Work in progress

* im.boxplot.layers() coordinates
* im.boxplot.classes() colors 
