#include <stdlib.h>
#include <stdio.h>
#include <float.h>
#include <math.h>

#define C_RAND_MAX 32767

#define UNIF (C_RAND() / (C_RAND_MAX + 1.0))

#define EPS 1e-4                /* relative test of equality of distances */


static unsigned int C_SEED = 3459173429;

void C_SEED_RAND(unsigned int seed) {
    C_SEED = seed;
}

int C_RAND()
{
    C_SEED = C_SEED * 1103515245 + 12345;
    return ((C_SEED / 65536) % (C_RAND_MAX+1));
}


double eucl(double * p1, double * p2, int px, int n, int n_nodes){
    int j;
    double tmp;

    double xdist = 0.0;
    for (j = 0; j < px; j++) {
        tmp = p1[j*n] - p2[j*n_nodes];
        xdist += tmp * tmp;
    }
    return sqrt(xdist);
}

double manh(double * p1, double * p2, int px, int n, int n_nodes){
    int j;
    double xdist = 0.0, tmp;
    for (j = 0; j < px; j++) {
        tmp = p1[j*n] - p2[j*n_nodes];
        xdist += fabs(tmp);
    }
    return xdist;
}

double chebyshev(double * p1, double * p2, int px, int n, int n_nodes){
    int j;
    double xdist = 0.0, tmp;
    for (j = 0; j < px; j++) {
        tmp = p1[j*n] - p2[j*n_nodes];
        tmp = fabs(tmp);
        if(tmp > xdist) xdist = tmp;
    }
    return xdist;
}

double cosine(double * p1, double * p2, int px, int n, int n_nodes){
    int j;
    double nom = 0;
    double denom1 = 0;
    double denom2 = 0;
    for (j = 0; j < px; j++) {
        nom += p1[j*n] * p2[j*n_nodes];
        denom1 += p1[j*n] * p1[j*n];
        denom2 +=  p2[j*n_nodes] * p2[j*n_nodes];
    }
    return (-nom/(sqrt(denom1)*sqrt(denom2)))+1;
}

void C_SOM(
    double *data,
    double *nodes,
    double *nhbrdist,
    double alpha_start,
    double alpha_end,
    double radius_start,
    double radius_end,
    double *xdists, /* working arrays */
    int n,
    int px,
    int n_nodes,
    int rlen,
    int dist
    )
{
    int cd, i, j, nearest;
    double niter, k, tmp, threshold, alpha, thresholdStep;
    double change;
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

    niter = rlen * n;
    threshold = radius_start;
    thresholdStep = (radius_start - radius_end) / (double) niter;
    change = 1.0;


    for (k = 0; k < niter; k++) {
        if(fmod(k, n) == 0){
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
        nearest node */
        for (cd = 0; cd < n_nodes; cd++) {
            xdists[cd] = distf(&data[i], &nodes[cd], px, n, n_nodes);
            if (xdists[cd] < xdists[nearest]) nearest = cd;
        }

        if (threshold < 1.0) threshold = 0.5;
        alpha = alpha_start - (alpha_start - alpha_end) * (double)k/(double)niter;

        for (cd = 0; cd < n_nodes; cd++) {
            if(nhbrdist[cd + n_nodes*nearest] > threshold) continue;

            for(j = 0; j < px; j++) {
                tmp = data[i + j*n] - nodes[cd + j*n_nodes];
                change += fabs(tmp);
                nodes[cd + j*n_nodes] += tmp * alpha;
            }
        }

        threshold -= thresholdStep;
    }
}

void C_mapDataToNodes(
    double *data,
    double *nodes,
    int n_nodes,
    int nd,
    int p,
    int *nn_nodes,
    double *nn_dists,
    int dist
    )
{
    int i, cd, minid;
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
    and n_nodes is the number of SOM units*/
    for (i = 0; i < nd; i++) {
        minid = -1;
        mindist = DBL_MAX;
        for (cd = 0; cd < n_nodes; cd++) {
            tmp = distf(&data[i], &nodes[cd], p, nd, n_nodes);
            if(tmp < mindist){
                mindist = tmp;
                minid = cd;
            }
        }
        nn_nodes[i] = minid+1;
        nn_dists[i] = mindist;
    }
}
