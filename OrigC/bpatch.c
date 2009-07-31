/* binary patch */
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define VERSION "0.2"
#define FORMAT_VERSION "02"
#define BUFFER_SIZE 4096

char* progname;
char* tempfile = 0;
FILE* tempfd = 0;

/* exit program with error message */
void error_exit(char* msg)
{
    fprintf(stderr, "%s: %s\n", progname, msg);
    if(tempfd)
        fclose(tempfd);
    if(tempfile)
        remove(tempfile);
    exit(1);
}

/* compute simple checksum */
long checksum(char* data, size_t len, long l)
{
    while(len--) {
        l = ((l >> 30) & 3) | (l << 2);
        l ^= *data++;
    }
    return l;
}

/* get 32-bit quantity from char array */
long getlong(char* p)
{
    unsigned char* q = (unsigned char*)p;
    unsigned long l = *q++;
    l += 256UL * *q++;
    l += 65536UL * *q++;
    l += 16777216UL * *q++;
    return l;
}

/* copy data from one stream to another, computing checksums */
/* allows dest = 0 */
void copy_data(FILE* src, FILE* dest, long amount, long check, int src_is_patch)
{
    long chk = 0;
    char buffer[BUFFER_SIZE];

    while(amount) {
        size_t now = (amount > BUFFER_SIZE) ? BUFFER_SIZE : amount;
        if(fread(buffer, 1, now, src) != now) {
            if(feof(src))
                if(src_is_patch)
                    error_exit("Patch garbled - unexpected end of data");
                else
                    error_exit("Source file does not match patch");
            else
                if(src_is_patch)
                    error_exit("Error reading patch file");
                else
                    error_exit("Error reading source file");
        }
        if(dest)
            if(fwrite(buffer, 1, now, dest) != now)
                error_exit("Error writing temporary file");
        chk = checksum(buffer, now, chk);
        amount -= now;
    }
    if(!src_is_patch && chk != check)
        error_exit("Source file does not match patch");
}

/* apply patch */
void bpatch(const char* src, const char* dest)
{
    FILE* sf;                   /* source file */
    FILE* df;                   /* destination file */
    char header[16];
    char* p;
    long srclen, destlen;
    long size;
    long ofs;

    /* read header */
    if(fread(header, 1, 16, stdin) != 16)
        error_exit("Patch not in BINARY format");
    if(strncmp(header, "bdiff" FORMAT_VERSION "\x1A", 8) != 0)
        error_exit("Patch not in BINARY format");
    srclen = getlong(&header[8]);
    destlen = getlong(&header[12]);

    /* open source file */
    sf = fopen(src, "rb");
    if(!sf) {
        perror(src);
        exit(1);
    }

    /* create temporary file */
    if(strlen(dest) == 0)
        error_exit("Empty destination file name");
    tempfile = malloc(strlen(dest) + 1);
    if(!tempfile)
        error_exit("Virtual memory exhausted");

    /* hack source file name to get a suitable temp file name */
    strcpy(tempfile, dest);
    p = strrchr(tempfile, '/');
    if(!p)
        p = tempfile;
    else
        p++;
#ifdef __MSDOS__
    {
        char *q = strrchr(p, '\\');
        if(q)
            p = q + 1;
        q = strrchr(p, ':');
        if(q)
            p = q + 1;
    }
#endif   
    *p = '$';
    df = fopen(tempfile, "wb");
    if(!df)
        error_exit("Can't create temporary file");
    tempfd = df;

    /* apply patch */
    while(1) {
        static char error_msg[] = "Patch garbled - invalid section `%'";
        int c = fgetc(stdin);
        if(c == EOF)
            break;
        switch(c) {
         case '@':
            /* copy from source */
            if(fread(header, 1, 12, stdin) != 12)
                error_exit("Patch garbled - unexpected end of data");
            size = getlong(&header[4]);
            ofs = getlong(&header[0]);
            if(ofs < 0 || size <= 0 || ofs > srclen || size > srclen
               || size+ofs > srclen)
                error_exit("Patch garbled - invalid change request");
            if(fseek(sf, ofs, SEEK_SET) != 0)
                error_exit("`fseek' on source file failed");
            copy_data(sf, df, size, getlong(&header[8]), 0);
            destlen -= size;
            break;
         case '+':
            /* copy N bytes from patch */
            if(fread(header, 1, 4, stdin) != 4)
                error_exit("Patch garbled - unexpected end of data");
            size = getlong(&header[0]);
            copy_data(stdin, df, size, 0, 1);
            destlen -= size;
            break;
         default:
            fclose(sf);
            fclose(df);
            *strchr(error_msg, '%') = c;
            error_exit(error_msg);
        }
        if(destlen < 0)
            error_exit("Patch garbled - patch file longer than announced in header");
    }
    if(destlen)
        error_exit("Patch garbled - destination file shorter than announced in header");

    fclose(sf);
    fclose(df);
    tempfd = 0;
    if(rename(tempfile, dest) != 0) {
        error_exit("Can't rename temporary file");
    }
    tempfile = 0;
}

/* help & exit */
void help()
{
    printf("%s: binary `patch' - apply binary patch\n"
           "\n"
           "Usage: %s [options] old-file new-file [<patch-file]\n"
           "\n"
           "Valid options:\n"
           " -i FN --input=FN     Set input file name (instead of stdin)\n"
           " -h    --help         Show this help screen\n"
           " -v    --version      Show version information\n"
           "\n"
           "(c) copyright 1999 Stefan Reuther <Streu@gmx.de>\n", progname, progname);
    exit(0);
}

/* version & exit */
void version()
{
    printf("bpatch-" VERSION " (" __DATE__ ")\n");
    exit(0);
}

/* control */
int main(int argc, char** argv)
{
    char* oldfn = 0;
    char* newfn = 0;
    char* infn = 0;
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
                else if(strcmp(p, "input")==0)
                    if(!argv[++i]) {
                        fprintf(stderr, "%s: missing argument to `--input'\n", progname);
                        return 1;
                    } else
                        infn=argv[i];
                else if(strncmp(p, "input=", 6)==0)
                    infn=p + 6;
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
                     case 'i':
                        if(!argv[++i]) {
                            fprintf(stderr, "%s: missing argument to `-i'\n", progname);
                            return 1;
                        } else
                            infn=argv[i];
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

    if(!oldfn) {
        fprintf(stderr, "%s: File name argument missing\n"
                "%s: try `%s --help' for more information\n",
                progname, progname, progname);
        return 1;
    }

    if(!newfn)
        newfn = oldfn;

    if(infn && strcmp(infn, "-") != 0) {
        if(!freopen(infn, "rb", stdin)) {
            perror(infn);
            return 1;
        }
    }

    bpatch(oldfn, newfn);
    
    return 0;
}
