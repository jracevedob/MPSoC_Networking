#pragma once

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int prim_poly[9] =
    {
        0,
        /*  1 */ 1,
        /*  2 */ 07,
        /*  3 */ 013,
        /*  4 */ 023,
        /*  5 */ 045,
        /*  6 */ 0103,
        /*  7 */ 0211,
        /*  8 */ 0435, //100 011 101
};

static int nw[9] = {0, (1 << 1), (1 << 2), (1 << 3), (1 << 4),
                    (1 << 5), (1 << 6), (1 << 7), (1 << 8)};

static int nwm1[9] = {0, (1 << 1) - 1, (1 << 2) - 1, (1 << 3) - 1, (1 << 4) - 1,
                      (1 << 5) - 1, (1 << 6) - 1, (1 << 7) - 1, (1 << 8) - 1};

static int *galois_log_tables[9] = {NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL};

static int *galois_ilog_tables[9] = {NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL};

static int *galois_mult_tables[9] = {NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                     NULL, NULL};

static int *galois_div_tables[9] = {NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                                    NULL, NULL};

// log_table for future 
int galois_create_log_tables(int w)
{
    int j, b;

    if (w > 30)
        return -1;
    if (galois_log_tables[w] != NULL)
        return 0;
    galois_log_tables[w] = (int *)malloc(sizeof(int) * nw[w]);
    if (galois_log_tables[w] == NULL)
        return -1;

    galois_ilog_tables[w] = (int *)malloc(sizeof(int) * nw[w] * 3);
    if (galois_ilog_tables[w] == NULL)
    {
        free(galois_log_tables[w]);
        galois_log_tables[w] = NULL;
        return -1;
    }

    for (j = 0; j < nw[w]; j++)
    {
        galois_log_tables[w][j] = nwm1[w];
        galois_ilog_tables[w][j] = 0;
    }

    b = 1;
    for (j = 0; j < nwm1[w]; j++)
    {
        if (galois_log_tables[w][b] != nwm1[w])
        {
      fprintf(stderr, "Galois_create_log_tables Error: j=%d, b=%d, B->J[b]=%d, J->B[j]=%d (0%o)\n",
              j, b, galois_log_tables[w][b], galois_ilog_tables[w][j], (b << 1) ^ prim_poly[w]);
      exit(1);
        }
        galois_log_tables[w][b] = j;
        galois_ilog_tables[w][j] = b;
        b = b << 1;
        if (b & nw[w])
            b = (b ^ prim_poly[w]) & nwm1[w];
    }
    for (j = 0; j < nwm1[w]; j++)
    {
        galois_ilog_tables[w][j + nwm1[w]] = galois_ilog_tables[w][j];
        galois_ilog_tables[w][j + nwm1[w] * 2] = galois_ilog_tables[w][j];
    }
    galois_ilog_tables[w] += nwm1[w];
    return 0;
}

// create a lookup table for multiplication in finite field 2^w 
int galois_create_mult_tables(int w)
{
    int j, x, y, logx;

    if (w >= 14)
        return -1;
    // generate tables if not exist
    if (galois_mult_tables[w] != NULL)
        return 0;
    galois_mult_tables[w] = (int *)malloc(sizeof(int) * nw[w] * nw[w]);
    if (galois_mult_tables[w] == NULL)
        return -1;

    galois_div_tables[w] = (int *)malloc(sizeof(int) * nw[w] * nw[w]);
    if (galois_div_tables[w] == NULL)
    {
        free(galois_mult_tables[w]);
        galois_mult_tables[w] = NULL;
        return -1;
    }
    if (galois_log_tables[w] == NULL)
    {
        if (galois_create_log_tables(w) < 0)
        {
            free(galois_mult_tables[w]);
            free(galois_div_tables[w]);
            galois_mult_tables[w] = NULL;
            galois_div_tables[w] = NULL;
            return -1;
        }
    }

    /* Set mult/div tables for x = 0 */
    j = 0;
    galois_mult_tables[w][j] = 0; /* y = 0 */
    galois_div_tables[w][j] = -1;
    j++;
    for (y = 1; y < nw[w]; y++)
    { /* y > 0 */
        galois_mult_tables[w][j] = 0;
        galois_div_tables[w][j] = 0;
        j++;
    }

    for (x = 1; x < nw[w]; x++)
    {                                 /* x > 0 */
        galois_mult_tables[w][j] = 0; /* y = 0 */
        galois_div_tables[w][j] = -1;
        j++;
        logx = galois_log_tables[w][x];
        for (y = 1; y < nw[w]; y++)
        { /* y > 0 */
            galois_mult_tables[w][j] = galois_ilog_tables[w][logx + galois_log_tables[w][y]];
            galois_div_tables[w][j] = galois_ilog_tables[w][logx - galois_log_tables[w][y]];
            j++;
        }
    }
    return 0;
}

// !!!only use std::vector<uint8_t> for this func, using array uint8_t[] will cause memory problems
// Case 1 r2=NULL: multiply "*region" with "multby", stored in "*region". Number of values in "*region" equal to "nbytes".
// Case 2 r2!=NULL, add=0: multiply "*region" with "multby", stored in "*r2"
// Case 3 r2!=NULL, add=1: multiply "*region" with "multby", add the results with the values in "*r2" and stored in "*r2"
void galois_w08_region_multiply(uint8_t *region,      /* Region to multiply */
                                  uint8_t multby,       /* Number to multiply by */
                                  uint64_t nbytes,        /* Number of bytes in region */
                                  uint8_t *r2,          /* If r2 != NULL, products go here */
                                  int add)
{
  uint8_t *ur1, *ur2, *cp; //unsigned char *ur1, *ur2, *cp;
  uint8_t  prod; //unsigned char prod;
  uint64_t i,j,sol;
  //srow;//int i, srow, j;
  unsigned long l, *lp2; //unsigned long l, *lp2;
  uint8_t *lp;  //unsigned char *lp;
  uint64_t srow; 
  ur1 =  region;
  ur2 = (r2 == NULL) ? ur1 :  r2;

  if (galois_mult_tables[8] == NULL) {
    if (galois_create_mult_tables(8) < 0) {
      fprintf(stderr, "galois_08_region_multiply -- couldn't make multiplication tables\n");
      exit(1);
    }
  }
  srow = multby * nw[8];
  if (r2 == NULL || !add) {
    for (i = 0; i < nbytes; i++) {
      prod = galois_mult_tables[8][srow+ur1[i]];
      ur2[i] = prod;
    }
  } else {
    sol = sizeof(long);
    lp2 = &l;
    lp = (uint8_t *)lp2;
    for (i = 0; i < nbytes; i += sol) {
      cp = ur2+i;
      lp2 =  (unsigned long *)cp;
      for (j = 0; j < sol; j++) {
        prod = galois_mult_tables[8][srow+ur1[i+j]];
        lp[j] = prod;
      }
      *lp2 = (*lp2) ^ l;
    }
  }
  return;
}

// a/b
uint8_t galois_single_divide(uint8_t a, uint8_t b)
{


    if (galois_div_tables[8] == NULL) {
      if (galois_create_mult_tables(8) < 0) {
        fprintf(stderr, "ERROR -- cannot make multiplication tables for w=8\n");
        exit(1);
      }
    }
    return galois_div_tables[8][(a<<8)|b];
}
