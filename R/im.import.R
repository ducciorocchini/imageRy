im.import <- function(im) {
  suppressWarnings({  
    ls <- list.files(system.file("images", package="imageRy"))
    fname <- ls[grep(im, ls)]
    fpath <- system.file("images", fname, package="imageRy")
    r <- rast(fpath)
    plot(r) 
    return(r)
  })  
}
