#' Build a self-organizing map
#'
#' @param data  Matrix containing the training data
#' @param xdim  Width of the grid
#' @param ydim  Hight of the grid
#' @param rlen  Number of times to loop over the training data for each MST
#' @param mst   Number of times to build an MST
#' @param alpha Start and end learning rate
#' @param radius Start and end radius
#' @param init  Initialize cluster centers in a non-random way
#' @param initf Use the given initialization function if init == T
#'              (default: Initialize_KWSP)
#' @param distf Distance function (1 = manhattan, 2 = euclidean, 3 = chebyshev,
#'              4 = cosine)
#' @param silent If FALSE, print status updates
#' @param map If FALSE, data is not mapped to the SOM. Default TRUE.
#' @param codes Cluster centers to start with
#' @param importance array with numeric values. Parameters will be scaled
#'                   according to importance
#'
#' @return A list containing all parameter settings and results
#'
#' @seealso \code{\link{BuildSOM}}
#'
#' @references This code is strongly based on the \code{kohonen} package.
#'             R. Wehrens and L.M.C. Buydens, Self- and Super-organising Maps
#'             in R: the kohonen package J. Stat. Softw., 21(5), 2007
#' @useDynLib FlowSOM, .registration = TRUE
#' @export

LOLSOM <- function (
    data,
    xdim = 10,
    ydim = 10,
    rlen = 10,
    mst = 1,
    alpha = c(0.05, 0.01),
    radius = stats::quantile(nhbrdist, 0.67) * c(1, 0),
    distf = 2,
    silent = FALSE,
    map = TRUE,
    codes = NULL,
    importance = NULL
)
{
  if (!is.null(codes)){
    if((ncol(codes) != ncol(data)) | (nrow(codes) != xdim * ydim)){
      stop("If codes is not NULL, it should have the same number of
                columns as the data and the number of rows should correspond with
                xdim*ydim")
    }
  }
  
  if(!is.null(importance)){
    data <- data * rep(importance, each = nrow(data))
  }
  
  if (is.null(colnames(data))) {
    colnames(data) <- as.character(seq_len(ncol(data)))
  }
  
  # Initialize the grid
  grid <- expand.grid(seq_len(xdim), seq_len(ydim))
  nCodes <- nrow(grid)
  if(is.null(codes)){
    codes <- data[sample(1:nrow(data), nCodes, replace = FALSE), , drop = FALSE]
  }
  #print("grid")
  #print(grid)
  #print("\ncodes")
  #print(codes)
  
  # Initialize the neighborhood
  nhbrdist <- as.matrix(stats::dist(grid, method = "maximum"))
  print("nhbrdis:")
  print(typeof(nhbrdist))
  print(dim(nhbrdist))
  #print(nhbrdist)
  
  # Initialize the radius
  if(mst == 1){
    radius <- list(radius)
    alpha <- list(alpha)
  } else {
    radius <- seq(radius[1], radius[2], length.out = mst+1)
    radius <- lapply(1:mst, function(i){c(radius[i], radius[i+1])})
    alpha <- seq(alpha[1], alpha[2], length.out = mst+1)
    alpha <- lapply(1:mst, function(i){c(alpha[i], alpha[i+1])})
  }
  
  # Compute the SOM
  for(i in seq_len(mst)){
    print("# starting mst iteration ########")
    cat("mst: "); print(mst)
    #cat("data: "); print(data)
    #cat("codes: "); print(codes)
    #cat("nhbrdist: "); print(nhbrdist)
    cat("alpha: "); print(alpha[[i]])
    cat("radius: "); print(radius[[i]])
    cat("xdistsv: "); print(nCodes)
    cat("n: "); print(nrow(data))
    cat("px: "); print(ncol(data))
    cat("ncodes: "); print(nCodes)
    cat("rlen: "); print(rlen)
    cat("distf: "); print(distf)

    
    #codes <- matrix(res$codes, nrow(codes), ncol(codes))
    #colnames(codes) <- colnames(data)
    #nhbrdist <- Dist.MST(codes)
  }
}

dat = read.csv("example_som_input.csv")
LOLSOM(data=as.matrix(dat), rlen=10, xdim=10, ydim=10, map=FALSE, mst=10)
