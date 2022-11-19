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

SOM <- function (
    data,
    xdim = 10,
    ydim = 10,
    rlen = 10,
    mst = 1,
    alpha = c(0.05, 0.01),
    radius = stats::quantile(nhbrdist, 0.67) * c(1, 0),
    distf = 2,
    silent = FALSE,
    codes = NULL,
    importance = NULL
    )
{
    # feel like there needs to way more input checking than just this
    if (!is.null(codes)){
        if((ncol(codes) != ncol(data)) | (nrow(codes) != xdim * ydim)){
            stop("If codes is not NULL, it should have the same number of
                columns as the data and the number of rows should correspond with
                xdim*ydim")
        }
    }

    if(!is.null(importance)){
        # straightforward way to scale the data
        data <- data * rep(importance, each = nrow(data))
    }

    if (is.null(colnames(data))) {
        # this will be handleed by pandas wrapper
        colnames(data) <- as.character(seq_len(ncol(data)))
    }

    # Initialize the grid
    grid <- expand.grid(seq_len(xdim), seq_len(ydim))
    # Basically the grid is a list of all coordinates in neighborhood
    # [1] "grid"
    #     Var1 Var2
    # 1      1    1
    # 2      2    1
    # 3      3    1
    # 4      4    1
    # 5      5    1
    # 6      6    1
    # 7      7    1
    # 8      8    1
    # 9      9    1
    # 10    10    1
    # 11     1    2
    # 12     2    2
    # 13     3    2
    # 14     4    2


    #if we don't supply codes, we randomly sample them from the data
    nCodes <- nrow(grid)
    if(is.null(codes)){
        codes <- data[sample(1:nrow(data), nCodes, replace = FALSE), , drop = FALSE]
    }

    # Initialize the neighborhood
    nhbrdist <- as.matrix(stats::dist(grid, method = "maximum"))
    # [1] "double"
    # [1] 100 100
    #     1 2 3 4 5 6 7 8 9 10 ...
    # 1   0 1 2 3 4 5 6 7 8  9
    # 2   1 0 1 2 3 4 5 6 7  8
    # 3   2 1 0 1 2 3 4 5 6  7
    # 4   3 2 1 0 1 2 3 4 5  6
    # 5   4 3 2 1 0 1 2 3 4  5
    # 6   5 4 3 2 1 0 1 2 3  4
    # 7   6 5 4 3 2 1 0 1 2  3
    # 8   7 6 5 4 3 2 1 0 1  2
    # 9   8 7 6 5 4 3 2 1 0  1
    # 10  9 8 7 6 5 4 3 2 1  0
    # ........... .  .  .  .  .


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
        # [1] "# starting mst iteration ########"
        # mst: [1] 3
        # alpha: [1] 0.05000000 0.03666667
        # radius: [1] 6 4
        # xdistsv: [1] 100
        # n: [1] 41646
        # px: [1] 16
        # ncodes: [1] 100
        # rlen: [1] 10
        # distf: [1] 2
        # [1] "# starting mst iteration ########"
        # mst: [1] 3
        # alpha: [1] 0.03666667 0.02333333
        # radius: [1] 4 2
        # xdistsv: [1] 100
        # n: [1] 41646
        # px: [1] 16
        # ncodes: [1] 100
        # rlen: [1] 10
        # distf: [1] 2
        # [1] "# starting mst iteration ########"
        # mst: [1] 3
        # alpha: [1] 0.02333333 0.01000000
        # radius: [1] 2 0
        # xdistsv: [1] 100
        # n: [1] 41646
        # px: [1] 16
        # ncodes: [1] 100
        # rlen: [1] 10
        # distf: [1] 2
        res <- .C("C_SOM",
            data = as.double(data),
            codes = as.double(codes),
            nhbrdist = as.double(nhbrdist),
            alpha = as.double(alpha[[i]]),
            radius = as.double(radius[[i]]),
            xdists = double(nCodes),
            n = as.integer(nrow(data)),
            px = as.integer(ncol(data)),
            ncodes = as.integer(nCodes),
            rlen = as.integer(rlen),
            distf = as.integer(distf)
            )

        codes <- matrix(res$codes, nrow(codes), ncol(codes))
        colnames(codes) <- colnames(data)
        nhbrdist <- Dist.MST(codes)
    }

    return(
        list(
            xdim = xdim,
            ydim = ydim,
            rlen = rlen,
            mst = mst,
            alpha = alpha,
            radius = radius,
            init = init,
            distf = distf,
            grid = grid,
            codes = codes,
            nNodes = nCodes
          )
    )
}

#' Assign nearest node to each datapoint
#
#' @param codes matrix with nodes of the SOM
#' @param newdata datapoints to assign
#' @param distf Distance function (1 = manhattan, 2 = euclidean, 3 = chebyshev,
#'              4 = cosine)
#'
#' @return Array with nearest node id for each datapoint
#'
MapDataToCodes <- function (codes, newdata, distf = 2) {

  nnCodes <- .C("C_mapDataToCodes",
    as.double(newdata[, colnames(codes)]),
    as.double(codes),
    as.integer(nrow(codes)),
    as.integer(nrow(newdata)),
    as.integer(ncol(codes)),
    nnCodes = integer(nrow(newdata)),
    nnDists = double(nrow(newdata)),
    distf = as.integer(distf)
    )
  return(cbind(nnCodes$nnCodes, nnCodes$nnDists))
}
