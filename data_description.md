# ImageRy data description 🛰️

Data are stored in: https://github.com/ducciorocchini/imageRy/tree/main/inst/images
and can be seen in R by the function im.list() and further imported by im.import(). Here is a description of the set in alphabetical order:

We did our best to reduce the weight of data in order to facilitate RS data analysis.
Hence, most of the data are original sets with coordinate systems recorderded. Other sets are pre-analysed data mainly downloadable from the NASA Earth Observatory () site.
In case of NASA Earth Observatory data we basically maintained the same name of images. In this manner a simple search of the name in any browser will directly lead to the original storybeyond each image. 

## Raw datasets
### sentinel.dolomites.b*.tif
Four bands of a Sentinel-2 Level-2A image acquired in June 2022 are provided over the area of Tofane, Dolomites, Italy.
These images allow dealing with coordinate reference systems, multiframe plots, imagery stacks, RGB visualisation.

## Sentinel2_NDVI_2020*.tif
Images of the Brenta region (italian Alps) with NDVI for each season (using February, May, August and November)

## S2_AllBands_temperate_passo_falzarego.tif
Sentinel-2 Level-2A image of the temperate mixed forests near Passo Falzarego, in the Dolomites.

## S2_AllBands_tropical.tif
Sentinel-2 Level-2A image of the Taboca area, located along the Rio Carabinani in the Amazonas region of Brazil, is a remote and largely pristine section of the Amazon rainforest.
 
## Pre-analysed data

### bletterbach.jpg
RGB winter drone imageRy of Bletterbach - image gathered under the project Horizon Europe EarthBridge. doi: 
[10.5281/zenodo.14975265](https://zenodo.org/records/14975266)

### EN_*
This set is related to the decrease of nitrogen during pandemics, due to the massive decrease of human activities. It is based on sketch from Sentinel-2 data available at: 
[https://www.youtube.com/watch?v=oHWXjOCDrvY](https://earthobservatory.nasa.gov/blogs/earthmatters/2020/03/13/airborne-nitrogen-dioxide-decreases-over-italy/?src=earthmatters-rss)https://earthobservatory.nasa.gov/blogs/earthmatters/2020/03/13/airborne-nitrogen-dioxide-decreases-over-italy/?src=earthmatters-rss

### Solar_Orbiter_s_first_views_of_the_Sun_pillars.jpg
ESA's Solar Orbiter, launched on 10 February 2020, performed its first close approach to the Sun in mid-June, capturing unique views of our nearest star. No other images of the Sun have been taken from such a close distance, enabling scientists to catch a glimpse of new, interesting phenomena.

This image is particularly useful for performing classification analysis of e.g. different levels of energy.

The complete story of this image is available at:
https://www.esa.int/Science_Exploration/Space_Science/Solar_Orbiter/Solar_Orbiter_s_first_views_of_the_Sun_image_gallery

### dolansprings_oli_2013088_canyon_lrg.jpg
When John Wesley Powell led an expedition down the Colorado River and through the Grand Canyon in 1869, he was confronted with a daunting landscape. At its highest point, the serpentine gorge plunged 1,829 meters (6,000 feet) from rim to river bottom, making it one of the deepest canyons in the United States. In just 6 million years, water had carved through rock layers that collectively represented more than 2 billion years of geological history, nearly half of the time Earth has existed.

This is image is useful for detecting different types of rocks; hence making an unsuprvised classification of the landscape.

The complete story of this image is available at:
https://landsat.visibleearth.nasa.gov/view.php?id=80948

### greenland.**
This set, derived from Copernicus, represents temperature over four different years in Greenland. 

This set could be particularly useful for multitemoral analysis of RS data.

### matogrosso_l5_1992219_lrg.jpg and matogrosso_ast_2006209_lrg.jpg
An inland state of central Brazil, deep in the Amazon interior, Mato Grosso was long isolated from the outside world. A railroad, followed by highways and airplanes, eventually connected this state with other regions in the twentieth century. By the early twenty-first century, modern technology had clearly reached Mato Grosso—and produced widespread change.

These images are particularly useful for multitemporal analysis, spectral indices calculations and image classification.

The complete story is available at:
https://earthobservatory.nasa.gov/images/35891/deforestation-in-mato-grosso-brazil

### sentinel.png
This image is a preanalysed Sentinel-2 image of the Similaun Glaciers, Alps, Italy. It is useful for image visualisation and classification.
