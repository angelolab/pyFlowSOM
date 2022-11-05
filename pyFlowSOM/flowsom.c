#include <stdlib.h>
#include <stdio.h>
#include <float.h>
#include <math.h>

#define RANDIN  srand(42)
#define UNIF rand() / RAND_MAX

#define EPS 1e-4                /* relative test of equality of distances */

double eucl(double * p1, double * p2, int px, int n, int ncodes){
    int j;
    double tmp;

    double xdist = 0.0;
    for (j = 0; j < px; j++) {
        tmp = p1[j*n] - p2[j*ncodes];
        xdist += tmp * tmp;
    }
    return sqrt(xdist);
}

double manh(double * p1, double * p2, int px, int n, int ncodes){
    int j;
    double xdist = 0.0, tmp;
    for (j = 0; j < px; j++) {
        tmp = p1[j*n] - p2[j*ncodes];
        xdist += fabs(tmp);
    }
    return xdist;
}

double chebyshev(double * p1, double * p2, int px, int n, int ncodes){
    int j;
    double xdist = 0.0, tmp;
    for (j = 0; j < px; j++) {
        tmp = p1[j*n] - p2[j*ncodes];
        tmp = fabs(tmp);
        if(tmp > xdist) xdist = tmp;
    }
    return xdist;
}

double cosine(double * p1, double * p2, int px, int n, int ncodes){
    int j;
    double nom = 0;
    double denom1 = 0;
    double denom2 = 0;
    for (j = 0; j < px; j++) {
        nom += p1[j*n] * p2[j*ncodes];
        denom1 += p1[j*n] * p1[j*n];
        denom2 +=  p2[j*ncodes] * p2[j*ncodes];
    }
    return (-nom/(sqrt(denom1)*sqrt(denom2)))+1;
}

void C_SOM(
    double *data,
    double *codes,
    double *nhbrdist,
    double *alphas,
    double *radii,
    double *xdists, /* working arrays */
    int *pn,
    int *ppx,
    int *pncodes,
    int *prlen,
    int *dist
    )
{
    int n = *pn, px = *ppx, ncodes = *pncodes, rlen = *prlen;
    int cd, i, j, k, nearest, niter;
    double tmp, threshold, alpha, thresholdStep;
    double change;
    double (*distf)(double*,double*,int,int,int);

    if(*dist == 1){
        distf = &manh;
    } else if (*dist == 2){
        distf = &eucl;
    } else if (*dist == 3){
        distf = &chebyshev;
    } else if (*dist == 4){
        distf = &cosine;
    } else {
        distf = &eucl;
    }

    RANDIN;
    niter = rlen * n;
    threshold = radii[0];
    thresholdStep = (radii[0] - radii[1]) / (double) niter;
    change = 1.0;


    for (k = 0; k < niter; k++) {

        if(k%n == 0){
            if(change < 1){
                k = niter;
            }
            change = 0.0;
        }

        /* i is a counter over objects in data, cd is a counter over units
        in the map, and j is a counter over variables */
        i = (int)(n * UNIF); /* Select a random sample */

        /*Rprintf("\ni: %d\n",i+1);
        for (j = 0; j < px; j++) {
            Rprintf(" j%d: %f",j,data[i*px + j]);
        }*/

        nearest = 0;
        /* calculate distances in x and y spaces, and keep track of the
        nearest code */
        for (cd = 0; cd < ncodes; cd++) {
            xdists[cd] = distf(&data[i], &codes[cd], px, n, ncodes);
            if (xdists[cd] < xdists[nearest]) nearest = cd;
        }

        if (threshold < 1.0) threshold = 0.5;
        alpha = alphas[0] - (alphas[0] - alphas[1]) * (double)k/(double)niter;

        for (cd = 0; cd < ncodes; cd++) {
            if(nhbrdist[cd + ncodes*nearest] > threshold) continue;

            for(j = 0; j < px; j++) {
                tmp = data[i + j*n] - codes[cd + j*ncodes];
                change += fabs(tmp);
                codes[cd + j*ncodes] += tmp * alpha;
            }
        }

        threshold -= thresholdStep;
    }

}

void C_mapDataToCodes(
    double *data,
    double *codes,
    int ncodes,
    int nd,
    int p,
    int *nnCodes,
    double *nnDists,
    int dist
    )
{
    int i, cd, counter, minid;
    double tmp, mindist;
    double (*distf)(double*,double*,int,int,int);

    if(dist == 1){
        distf = &manh;
    } else if (dist == 2){
        distf = &eucl;
    } else if (dist == 3){
        distf = &chebyshev;
    } else if (dist == 4){
        distf = &cosine;
    } else {
        distf = &eucl;
    }

    /* i is a counter over objects in data, cd  is a counter over SOM
    units, p is the number of columns, nd is the number of datapoints
    and ncodes is the number of SOM units*/
    counter = -1;
    for (i = 0; i < nd; i++) {
        minid = -1;
        mindist = DBL_MAX;
        for (cd = 0; cd < ncodes; cd++) {
            tmp = distf(&data[i], &codes[cd], p, nd, ncodes);
            if(tmp < mindist){
                mindist = tmp;
                minid = cd;
            }
        }
        nnCodes[++counter] = minid+1;
        nnDists[counter] = mindist;
    }
}
