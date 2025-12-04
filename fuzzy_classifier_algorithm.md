Right now the function **returns *spectral distance*** to each class centroid — **NOT membership**.

### ✔ What the current function computes

For each pixel and each class *k*:

[
d_{ik} = \sqrt{ \sum_b (x_{ib} - c_{kb})^2 }
]

This is the **Euclidean distance in feature space** (the same metric k-means uses).

* **Small distance → high similarity to the class**
* **Large distance → low similarity**
  But these values are *not normalized* and do *not* sum to 1.

### ✔ What the current maps represent

Example output (4 clusters → 4 layers):

| Layer   | Meaning                          |
| ------- | -------------------------------- |
| class_1 | **Distance** to class 1 centroid |
| class_2 | **Distance** to class 2 centroid |
| class_3 | **Distance** to class 3 centroid |
| class_4 | **Distance** to class 4 centroid |

These are **hard distances**, not fuzzy memberships.

---

## If you want **fuzzy membership**, I can convert distances → memberships

There are many ways to do this. Common fuzzy-c-means style memberships use:

[
u_{ik} = \frac{1}{\sum_j \left(\frac{d_{ik}}{d_{ij}}\right)^{2/(m-1)}}
]

with fuzzifier ( m \approx 2 ).

Or a simpler normalized inverse-distance:

[
u_{ik} = \frac{1/d_{ik}}{\sum_j 1/d_{ij}}
]

These produce values between **0 and 1**, and each pixel’s memberships sum to **1**.

