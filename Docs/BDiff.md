NAME

bdiff - difference of binary files


SYNOPSIS

bdiff [options] old-file new-file [>patch-file]


DESCRIPTION

bdiff computes differences between two binary files. Output can be either a
somewhat human-readable protocol, or a binary file readable by bpatch. Output is
sent to standard output unless the --output option is used to specify an output
file.

bdiff handles insertion and deletion of data as well as changed bytes.


OPTIONS

-q                   - Use QUOTED format (default);

-f                   - Use FILTERED format;

-b                   - Use BINARY format;

--format=FMT         - Select format by name: (binary, filtered, quoted)

-m N,                - Two chunks of data are recognized as being identical if
--min-equal=N          they are at least N bytes long, the default is 24.

-o FILENAME,         - Write diff to specified file instead of standard output.
--output=FILENAME      Specifying --output=- does nothing. Use as an alternative
                       to shell redirection.

-V,                  - Print status messages while processing input;
--verbose

-h,                  - Show help screen and exit;
--help

-v,                  - Show version number and exit.
--version


ALGORITHM

bdiff tries to locate maximum-length substrings of the new file in the old data.
Substrings shorter than N (argument to the -m option) are not considered
acceptable matches. Everything covered by such a substring is transmitted as a
position, length pair, everything else as literal data.

bdiff uses the block-sort technique to allow O(lgN) searches in the file, giving
an estimated O(NlgN) algorithm on average.

The program requires about five times as much memory as the old file, plus
storage for the new file. This should be real memory, bdiff accesses all of it
very often.


OUTPUT FORMATS

The quoted format (default) is similar to diff output in unified format: '+'
means added data, and a space means data kept from the old file. Lines prefixed
with '@' inform you about the position of the next 'space' line in the source
file (byte offset).

Unlike in diff, there's no implicit line feed after each line of output.
Non-printable characters (see isprint(3)[1]) and the backslash character are
represented by a \ followed by the octal three-digit character code.

The filtered format is like the quoted format, but non-printable characters are
replaced by dots (.).

The binary format is machine-readable, and omits details for common blocks. All
words are in little-endian format (low byte first). The format is:

8 bytes  - Signature "bdiff02\x1A", where 02 is kind-of a version number. An
           earlier version (with an O(n^3) algorithm) used the number 01. \x1A
           is ASCII 26 (Control-Z, an MS-DOS end-of-file marker).
4 bytes  - Length of old file in bytes.
4 bytes  - Length of new file in bytes.
n bytes  - The patch itself, a sequence of the following records:

  literally added data:
  1 byte   - ASCII 43 ('+');
  4 bytes  - number of bytes;
  n bytes  - data.

  common block:
  1 byte   - ASCII 64 ('@');
  4 bytes  - file position in old file;
  4 bytes  - number of bytes;
  4 bytes  - checksum.

  The checksum is computed using the following algorithm:
    long checksum(char* data, size_t len)
    {
        long l = 0;
        while(len--) {
            l = ((l >> 30) & 3) | (l << 2);
            l ^= *data++;
        }
        return l;
    }
    (rotate current checksum left by two and xor in the current byte)


ADMINISTRATIVIA

This manual page is for version 0.2.6 or later of bdiff.

See the file LICENSE.md for details of licensing and copyright.

THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN
NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE OF
THIS SOFTWARE.


FOOTNOTES

[1] http://www.openbsd.org/cgi-bin/man.cgi?query=isprint&sektion=3
