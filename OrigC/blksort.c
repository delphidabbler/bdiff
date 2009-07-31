/*
 *  Block-sort part of bdiff:
 *
 *  Taking the data area of length N, we generate N substrings:
 *  - first substring is data area, length N
 *  - 2nd is data area sans first character, length N-1
 *  - ith is data area sans first i-1 characters, length N-i+1
 *  - Nth is last character of data area, length 1
 *  These strings are sorted to allow fast (i.e., binary) searching
 *  in data area. Of course, we don't really generate these N*N/2
 *  bytes of strings: we use an array of N size_t's indexing the data.
 */

#include <stdlib.h>

/* compare positions a and b in data area, consider maximum length dlen */
int block_sort_compare(size_t a, size_t b, char* data, size_t dlen)
{
    char* pa = data + a;
    char* pb = data + b;
    size_t len = dlen - a;
    if(dlen - b < len)
        len = dlen - b;

    while(len && *pa == *pb)
        pa++, pb++, len--;

    if(len == 0)
        return a - b;
    
    return *pa - *pb;
}

/* the `sink element' part of heapsort */
void block_sort_sink(size_t le, size_t ri, size_t* block, char* data, size_t dlen)
{
    size_t i, j, x;
    i = le;
    x = block[i];
    while(1) {
        j = 2*i+1;
        if(j >= ri)
            break;
        if(j < ri-1)
            if(block_sort_compare(block[j], block[j+1], data, dlen) < 0)
                j++;
        if(block_sort_compare(x, block[j], data, dlen) > 0)
            break;
        block[i] = block[j];
        i = j;
    }
    block[i] = x;
}

/* returns array of offsets into data, sorted by position */
/* returns 0 on error (out of memory) */
size_t* block_sort(char* data, size_t dlen)
{
    size_t* block = malloc(sizeof(size_t) * dlen);
    size_t i, le, ri;
    if(!block || !dlen)
        return 0;

    /* initialize unsorted data */
    for(i = 0; i < dlen; i++)
        block[i] = i;

    /* heapsort */
    le = dlen/2;
    ri = dlen;
    while(le > 0) {
        le--;
        block_sort_sink(le, ri, block, data, dlen);
    }
    while(ri > 0) {
        size_t x = block[le];
        block[le] = block[ri-1];
        block[ri-1] = x;
        ri--;
        block_sort_sink(le, ri, block, data, dlen);
    }
    return block;
}

/* compute common stem of the data blocks:
   return[i]==N  <=>  the first N bytes of data[block[i]] and
   data[block[i-1]] are equal */
size_t* compute_common_stem(char* data, size_t* block, size_t len)
{
    size_t* p = malloc(sizeof(size_t) * len);
    size_t i;
    char* a, *b;        
    if(!p || !len)
        return 0;
    
    p[0] = 0;
    for(i = 1; i < len; i++) {
        /* max nr of data bytes */
        size_t n = len - block[i-1];
        size_t n1 = len - block[i];
        if(n1 < n)
            n = n1;
        n1 = n;
        a = &data[block[i-1]];
        b = &data[block[i]];
        while(n && *a==*b)
            n--, a++, b++;
        p[i] = n1-n;
    }
    return p;
}

/* find maximum length substring starting at sub, at most max bytes
   data, block, len characterize source file
   *index returns found location
   return value is found length */
size_t find_string(char* data, size_t* block, size_t len,
                   char* sub, size_t max,
                   size_t* index)
{
    size_t first = 0, last = len-1;
    size_t mid = 0;
    size_t l0 = 0, l = 0;
    char* pm;
    char* sm;

    size_t retval = 0;
    *index = 0;
    
    while(first <= last) {
        mid = (first+last)/2;
        pm = &data[block[mid]];
        sm = sub;
        l = len - block[mid];
        if(l > max)
            l = max;
        l0 = l;
        while(l && *pm == *sm)
            l--, pm++, sm++;

        /* we found a `match' of length l0-l, position block[mid] */
        if(l0 - l > retval) {
            retval = l0 - l;
            *index = block[mid];
        }

        if(l == 0 || *pm < *sm)
            first = mid + 1;
        else {
            last = mid;
            if(last)
                last--;
            else
                break;
        }
    }
    return retval;
}
