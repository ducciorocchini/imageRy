# **`im.fuzzy()` – Fuzzy Image Classification Using K-Means and Membership Maps**

## **Overview**

`im.fuzzy()` performs **unsupervised classification** of raster images (RGB or single-band) using **k-means clustering**, but instead of producing a single hard classification map, it computes:

1. **Spectral distance maps** — one raster per class showing the Euclidean distance of each pixel to that cluster centroid.
2. **Fuzzy membership maps** — one raster per class showing how strongly each pixel belongs to that cluster, following fuzzy c-means logic.

This means that instead of assigning each pixel to only one class (hard clustering), the function produces **soft/fuzzy membership values**, which are especially useful for:

* Mixed pixels
* Transitional areas (forest–grassland, soil–crop, shallow water)
* Uncertainty analysis
* Sub-pixel interpretation

The function returns both **distance rasters** and **membership rasters**, and optionally plots the membership maps using **terra’s default color palette**.

---

## **Key Features**

### ✔ **K-means clustering**

* Fast and robust unsupervised algorithm
* Computes **spectral centroids** in feature space
* All structure from your original classification function is preserved

### ✔ **Spectral distance maps**

For each class *k*, a raster layer contains:

[
d_{ik} = \sqrt{\sum_b (x_{ib} - c_{kb})^2}
]

where

* ( x_{ib} ) = pixel value of band *b*
* ( c_{kb} ) = centroid of class *k*

Small values = high similarity to that class.

### ✔ **Fuzzy membership maps**

Using the fuzzy c-means membership formula:

[
u_{ik} = \frac{1}{\sum_j \left( \frac{d_{ik}}{d_{ij}} \right)^{2/(m - 1)} }
]

With fuzzifier:

* ( m = 2 ) by default (classical fuzzy C-means)
* ( u_{ik} \in [0,1] )
* (\sum_k u_{ik} = 1) for every pixel

### ✔ **Output**

The function returns a list:

```r
list(
  distances   = SpatRaster (one layer per class),
  memberships = SpatRaster (one layer per class, values 0–1),
  centers     = matrix of class centroids
)
```

---

# **Function Description**

```r
im.fuzzy <- function(input_image, 
                     num_clusters = 3, 
                     seed = NULL,
                     m = 2,                 # fuzzifier (m > 1), m=2 is common
                     do_plot = TRUE, 
                     custom_colors = NULL, 
                     num_colors = 100) {
  ...
}
```

## **Arguments**

| Argument                      | Description                                                      |
| ----------------------------- | ---------------------------------------------------------------- |
| `input_image`                 | A `SpatRaster` object (RGB or 1-band).                           |
| `num_clusters`                | Number of clusters (classes) for k-means.                        |
| `seed`                        | Optional random seed for reproducibility.                        |
| `m`                           | Fuzzifier for membership calculation; must be > 1.               |
| `do_plot`                     | If `TRUE`, plot membership maps using terra defaults.            |
| `custom_colors`, `num_colors` | Retained for compatibility, but not used in plotting fuzzy maps. |

---

# **How It Works**

## **1. Preprocessing**

* Converts raster to matrix form.
* Scales each band to **0–255** to match typical imagery and your original function.
* Removes NA pixels before clustering.

## **2. K-means clustering**

* Runs unsupervised k-means with `num_clusters` centers.
* Extracts centroid matrix for fuzzy distance calculations.

## **3. Compute distances**

For each pixel and class, compute Euclidean spectral distance to the centroid.

## **4. Compute fuzzy memberships**

Apply fuzzy-c-means membership formula:

* Membership = high if the pixel is close to the centroid
* Membership = low if far
* Sum of memberships across classes = 1 per pixel

Handles edge case when a pixel exactly matches a centroid (distance = 0).

## **5. Build raster stacks**

Two `SpatRaster` stacks are created:

### **Distances**

```
class_1_distance
class_2_distance
...
class_k_distance
```

### **Memberships**

```
class_1_membership
class_2_membership
...
class_k_membership
```

## **6. Plotting**

If `do_plot = TRUE`, then:

```r
terra::plot(membership_rast)
```

This uses **terra's default color ramp** (your request).

---

# **Example Usage**

```r
library(terra)

# Load an RGB or single-band raster
img <- rast("my_image.tif")

# Perform fuzzy classification with 4 clusters
result <- im.fuzzy(img, num_clusters = 4, seed = 123)

# Access outputs
dist_maps <- result$distances        # spectral distance rasters
mem_maps  <- result$memberships      # fuzzy membership rasters
centers   <- result$centers          # k-means centroids
```

## **Plot memberships manually**

```r
plot(mem_maps)
```

## **Inspect membership of class 1**

```r
plot(mem_maps[[1]], main = "Membership to class 1")
```

Values close to:

* **1.0** → pixel very close to class center
* **0.0** → pixel far from class center

---

# **Interpretation**

## **Distances vs. Memberships**

| Output              | Meaning                                             | Range              |
| ------------------- | --------------------------------------------------- | ------------------ |
| **Distance maps**   | Raw spectral dissimilarity from each class centroid | 0 → large positive |
| **Membership maps** | Soft classification probabilities (fuzzy sets)      | 0–1                |

Membership maps are more intuitive for interpretation; distance maps are useful for analyzing uncertainty and centroid geometry.

---

# **When to Use This Function**

* Unsupervised land-cover mapping
* Mixed pixel environments (urban–rural, ecotones)
* Spectral unmixing groundwork
* Change detection (compare memberships over time)
* Assessing uncertainty in k-means classification

---

# **Optional Extensions**

Let me know if you'd like to add:

* Hard classification derived from fuzzy memberships
* Automatic naming of clusters based on user input
* PCA dimensionality reduction before clustering
* Fuzzy entropy / uncertainty map
* Softmax or alternative membership transforms
* GPU acceleration

---

