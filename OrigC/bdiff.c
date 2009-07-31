/*
 *  Binary `diff' Utility
 *
 *  This utility can create binary patches, much like `diff' can
 *  create patches for text files.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#define VERSION "0.2"
#define FORMAT_VERSION "02"
#define BUFFER_SIZE 4096

/* functions from `blksort.c' */
size_t* block_sort(char* data, size_t dlen);
size_t find_string(char* data, size_t* block, size_t len,
                   char* sub, size_t max,
                   size_t* index);

/* output format to use */
enum Format { FMT_BINARY, FMT_FILTERED, FMT_QUOTED };

/* structure for a matching block */
struct Match {
    size_t oofs;                /* position in `old' file */
    size_t nofs;                /* position in `new' file */
    size_t len;                 /* length, zero if no match */
};

/* for error messages */
char* progname;

/* default options */
size_t min_len = 24;
enum Format format = FMT_QUOTED;
int verbose = 0;

/* format option handling */
struct FormatSpec {
    void (*print_header)(char*, char*, size_t, size_t);
    void (*print_add)(char*, size_t);
    void (*print_copy)(char*, size_t, char*, size_t, size_t);
};

void print_binary_header(char*, char*, size_t, size_t);
void print_text_header(char*, char*, size_t, size_t);
void print_binary_add(char*, size_t);
void print_filtered_add(char*, size_t);
void print_quoted_add(char*, size_t);
void print_text_copy(char*, size_t, char*, size_t, size_t);
void print_binary_copy(char*, size_t, char*, size_t, size_t);

struct FormatSpec fmt_spec[] = {
    { print_binary_header, print_binary_add, print_binary_copy },
    { print_text_header, print_filtered_add, print_text_copy },
    { print_text_header, print_quoted_add, print_text_copy }
};

/* exit program with error message */
void error_exit(char* msg)
{
    fprintf(stderr, "%s: %s\n", progname, msg);
    exit(1);
}

/* load file, returning pointer to file data,
   exits with error message if out of memory or not found */
char* load_file(char* file_name, size_t* size_ret)
{
    FILE* fp;                 
    char* data;               
    char buffer[BUFFER_SIZE];
    size_t len;
    size_t cur_len;

    /* open file */
    fp = fopen(file_name, "rb");
    if(!fp) {
        perror(file_name);
        exit(1);
    }

    /* read file */
    cur_len = 0;
    data = 0;
    while((len = fread(buffer, 1, BUFFER_SIZE, fp))) {
        char* tmp = realloc(data, cur_len + len);
        if(!tmp) {
            fprintf(stderr, "%s: Virtual memory exhausted\n", progname);
            exit(1);
        }
        data = tmp;
        memcpy(data + cur_len, buffer, len);
        cur_len += len;
    }
    if(!feof(fp)) {
        perror(file_name);
        fclose(fp);
        exit(1);
    }

    /* exit */
    fclose(fp);
    if(size_ret)
        *size_ret = cur_len;
    return data;
}

/* pack long in little-endian format into p */
void pack_long(char* p, long l)
{
    *p++ = l & 0xFF;
    *p++ = (l >> 8) & 0xFF;
    *p++ = (l >> 16) & 0xFF;
    *p   = (l >> 24) & 0xFF;
}

/* compute simple checksum */
long checksum(char* data, size_t len)
{
    long l = 0;
    while(len--) {
        l = ((l >> 30) & 3) | (l << 2);
        l ^= *data++;
    }
    return l;
}

/* print header for `BINARY' format */
void print_binary_header(char* oldfn, char* newfn, size_t oldl, size_t newl)
{
    char head[16];
    
    strcpy(head, "bdiff" FORMAT_VERSION "\x1A"); /* 8 chars */
    pack_long(head + 8, oldl);
    pack_long(head + 12, newl);
    fwrite(head, 1, 16, stdout);
}

/* print header for text formats */
void print_text_header(char* oldfn, char* newfn, size_t olds, size_t news)
{
    printf("%% --- %s (%d bytes)\n"
           "%% +++ %s (%d bytes)\n", oldfn, olds, newfn, news);
}

/* print data as C-escaped string */
void print_quoted_data(char* data, size_t len)
{
    while(len) {
        if(isprint(*data) && *data!='\\')
            putchar(*data);
        else
            printf("\\%03o", *data & 0xFF);
        data++;
        len--;
    }
}

/* print data with non-printing characters filtered */
void print_filtered_data(char* data, size_t len)
{
    while(len) {
        if(isprint(*data))
            putchar(*data);
        else
            putchar('.');
        data++;
        len--;
    }
}

/* print information for binary diff chunk */
void print_binary_add(char* data, size_t len)
{
    char buf[8];
    putchar('+');
    pack_long(buf, len);
    fwrite(buf, 1, 4, stdout);
    fwrite(data, 1, len, stdout);
}

/* print information for filtered diff chunk */
void print_filtered_add(char* data, size_t len)
{
    putchar('+');
    print_filtered_data(data, len);
    putchar('\n');
}

/* print information for quoted diff chunk */
void print_quoted_add(char* data, size_t len)
{
    putchar('+');
    print_quoted_data(data, len);
    putchar('\n');
}

/* print information for copied data in text mode */
void print_text_copy(char* nbase, size_t npos,
                     char* obase, size_t opos,
                     size_t len)
{
    printf("@ -[%d] => +[%d] %d bytes\n ", opos, npos, len);
    if(format == FMT_FILTERED)
        print_filtered_data(&nbase[npos], len);
    else
        print_quoted_data(&nbase[npos], len);
    putchar('\n');
}

/* print information for copied data in binary mode */
void print_binary_copy(char* nbase, size_t npos,
                       char* obase, size_t opos,
                       size_t len)
{
    char rec[12];
    putchar('@');

    pack_long(rec + 0, opos);
    pack_long(rec + 4, len);
    pack_long(rec + 8, checksum(&nbase[npos], len));
    fwrite(rec, 1, 12, stdout);
}

/* find maximum-length match */
void bs_find_max_match(struct Match* m_ret,                    /* return */
                       char* data, size_t* sort, size_t len,   /* old file */
                       char* text, size_t tlen)                /* rest of new file */
{
    m_ret->len = 0;             /* no match */
    m_ret->nofs = 0;
    while(tlen) {
        size_t found_pos;
        size_t found_len = find_string(data, sort, len,
                                       text, tlen, &found_pos);
        if(found_len >= min_len) {
            m_ret->oofs = found_pos;
            m_ret->len = found_len;
            return;
        }
        text++;
        m_ret->nofs++;
        tlen--;
    }
}

/* print message, if enabled */
void log_status(const char* p)
{
    if(verbose)
        fprintf(stderr, "%s: %s\n", progname, p);
}

/* main routine: generate diff */
void bs_diff(char* fn, char* newfn)
{
    char* data;
    char* data2;
    size_t len;
    size_t len2, todo, nofs;
    size_t* sort;
    
    /* initialize */
    log_status("loading old file");
    data = load_file(fn, &len);
    log_status("loading new file");
    data2 = load_file(newfn, &len2);
    log_status("block sorting old file");
    sort = block_sort(data, len);
    if(!sort) {
        fprintf(stderr, "%s: virtual memory exhausted\n", progname);
        exit(1);
    }

    log_status("generating patch");
    fmt_spec[format].print_header(fn, newfn, len, len2);

    /* main loop */
    todo = len2;
    nofs = 0;
    while(todo) {
        /* invariant: nofs + todo = len2 */
        struct Match match;
        bs_find_max_match(&match,
                          data, sort, len,
                          &data2[nofs], todo);
        if(match.len) {
            /* found a match */
            if(match.nofs != 0)
                /* preceded by a "copy" block */
                fmt_spec[format].print_add(&data2[nofs], match.nofs);
            nofs += match.nofs;
            todo -= match.nofs;
            fmt_spec[format].print_copy(data2, nofs,
                                        data, match.oofs,
                                        match.len);
            
            nofs += match.len;
            todo -= match.len;
        } else {
            fmt_spec[format].print_add(&data2[nofs], todo);
            break;
        }
    }
    log_status("done");
}

/* help & exit */
void help()
{
    printf("%s: binary `diff' - compare two binary files\n"
           "\n"
           "Usage: %s [options] old-file new-file [>patch-file]\n"
           "\n"
           "Valid options:\n"
           " -q                   Use QUOTED format\n"
           " -f                   Use FILTERED format\n"
           " -b                   Use BINARY format\n"
           "       --format=FMT   Use specified format\n"
           " -m N  --min-equal=N  Minimum equal bytes to recognize an equal chunk\n"
           " -V    --verbose      Show status messages\n"
           " -h    --help         Show this help screen\n"
           " -v    --version      Show version information\n"
           "\n"
           "(c) copyright 1999 Stefan Reuther <Streu@gmx.de>\n", progname, progname);
    exit(0);
}

/* version & exit */
void version()
{
    printf("bdiff-" VERSION " (" __DATE__ ")\n");
    exit(0);
}

/* read argument of --min-equal */
void set_min_equal(char* p)
{
    char* q;
    unsigned long x;
    if(!p || !*p)
        error_exit("Missing argument to `--min-equal' / `-m'");

    x = strtoul(p, &q, 0);
    if(*q)
        error_exit("Malformed number on command line");
    if(x == 0 || x > 0x7FFF)
        error_exit("Number out of range on command line");
    min_len = x;
}

/* read argument of --format */
void set_format(char* p)
{
    if(!p)
        error_exit("Missing argument to `--format'");
    if(strcmp(p, "quoted")==0)
        format = FMT_QUOTED;
    else if(strcmp(p, "filter")==0 || strcmp(p, "filtered")==0)
        format = FMT_FILTERED;
    else if(strcmp(p, "binary")==0)
        format = FMT_BINARY;
    else
        error_exit("Invalid format specification");        
}

/* main routine: argument parsing */
int main(int argc, char** argv)
{
    char* oldfn = 0;
    char* newfn = 0;
    char* outfn = 0;
    int i;

    progname = argv[0];

    for(i = 1; i < argc; i++)
        if(argv[i][0] == '-') {
            if(argv[i][1] == '-') {
                /* long option */
                char* p = argv[i]+2;
                if(strcmp(p, "help")==0)
                    help();
                else if(strcmp(p, "version")==0)
                    version();
                else if(strcmp(p, "verbose")==0)
                    verbose = 1;
                else if(strcmp(p, "output")==0)
                    if(!argv[++i]) {
                        fprintf(stderr, "%s: missing argument to `--output'\n", progname);
                        return 1;
                    } else
                        outfn=argv[i];
                else if(strncmp(p, "output=", 7)==0)
                    outfn=p + 7;
                else if(strcmp(p, "format")==0)
                    set_format(argv[++i]);
                else if(strncmp(p, "format=", 7)==0)
                    set_format(p + 7);
                else if(strcmp(p, "min-equal")==0)
                    set_min_equal(argv[++i]);
                else if(strncmp(p, "min-equal=", 10)==0)
                    set_min_equal(p + 10);
                else {
                    fprintf(stderr, "%s: unknown option `--%s'\n"
                            "%s: try `%s --help' for more information\n",
                            progname, p, progname, progname);
                    return 1;
                }
            } else {
                /* short option */
                char* p = argv[i] + 1;
                while(*p) {
                    switch(*p) {
                     case 'h':
                        help();
                     case 'v':
                        version();
                     case 'V':
                        verbose = 1;
                        break;
                     case 'q':
                        format = FMT_QUOTED;
                        break;
                     case 'f':
                        format = FMT_FILTERED;
                        break;
                     case 'b':
                        format = FMT_BINARY;
                        break;
                     case 'm':
                        set_min_equal(argv[++i]);
                        break;
                     case 'o':
                        if(!argv[++i]) {
                            fprintf(stderr, "%s: missing argument to `-o'\n", progname);
                            return 1;
                        } else
                            outfn=argv[i];
                        break;
                     default:
                        fprintf(stderr, "%s: unknown option `-%c'\n"
                                "%s: try `%s --help' for more information\n",
                                progname, *p, progname, progname);
                        return 1;
                    }
                    p++;
                }
            }
        } else {
            if(!oldfn)
                oldfn = argv[i];
            else if(!newfn)
                newfn = argv[i];
            else
                error_exit("Too many file names on command line");
        }

    if(!newfn)
        error_exit("Need two filenames");

    if(outfn && strcmp(outfn, "-") != 0) {
        FILE* p = freopen(outfn, "wb", stdout);
        if(!p) {
            perror(outfn);
            return 1;
        }
    }
    
    bs_diff(oldfn, newfn);
    return 0;
}
