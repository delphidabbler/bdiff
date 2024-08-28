# BDiff

## Precis

BDiff computes the difference of two binary files.

## Synopsis 

    bdiff [options] old-file new-file [>patch-file]

## Description

BDiff computes differences between two binary files. Text files are treated as a simple sequence of bytes. Output can be either a somewhat human-readable protocol, or a binary file readable by BPatch. Output is sent to standard output unless shell redirection is used or the `--output` option is used to specify an output file.

BDiff handles insertion and deletion of data as well as changed bytes.

Files larger than 10MiB will not be processed unless the `--permit-large-files` option is specified (see _Options_ below).

## Options

| Short option | Long option | Description |
|--------------|-------------|-------------|
| `-q`         |             | Use quoted format (default). |
| `-f`         |             | Use filtered format. |
| `-b`         |             | Use binary format. |
|              | `--format=FMT`| Select format by name: `FMT` is one of `binary`, `filtered` or `quoted`. |
|`-m N`        | `--min-equal=N`| Two chunks of data are recognized as being identical if they are at least `N` bytes long. The value must be in the range `8..1024`. The default is `24`. |
| `-o FILENAME` | `--output=FILENAME`| Write diff to specified file instead of standard output. Specifying `--output=-` does nothing. Use as an alternative to shell redirection. |
| `-V`          | `--verbose`| Print status messages while processing input. |
|               | `--permit-large-files` | Ignore maximum file size limit and permit files larger than the limit to be processed. |
|`-h`           | `--help`   | Show help screen and exit. |
|`-v`           | `--version`| Show version number and exit. |

## Algorithm

BDiff tries to locate maximum-length substrings of the new file in the old data. Substrings shorter than `N` (argument to the `-m` option) are not considered acceptable matches. Everything covered by such a substring is transmitted as a position, length pair. Everything else is literal data.

BDiff uses the block-sort technique to allow O(lgN) searches in the file, giving an estimated O(NlgN) algorithm on average.

The program requires about five times as much memory as the old file, plus storage for the new file. This should be real memory, BDiff accesses all of it very often.

## Output Formats

### Quoted Format

The quoted format (default) is similar to [diff(1)] output in unified format: `+` means added data, and a space means data kept from the old file. Lines prefixed with `@` inform you about the position of the next 'space' line in the source file (byte offset).

Unlike in diff, there's no implicit line feed after each line of output. Bytes are treated as ASCII characters. Non-printable characters (see [isprint(3)]) and the backslash character are represented by a `\` followed by the octal three-digit character code.

### Filtered Format

The filtered format is like the quoted format, but non-printable characters are replaced by dots (`.`).

### Binary Format

The binary format is machine-readable, and omits details for common blocks. All words are in little-endian format (low byte first). The format is:

| Number of bytes | Description |
|-----------------|-------------|
| 8 | Signature. ASCII character sequence `bdiff02\x1A`, where `02` is kind-of a version number. (An earlier version used the number `01`). `\x1A` is ASCII 26 (Control-Z, an MS-DOS end-of-file marker). |
| 4 | Length of old file in bytes. |
| 4 | Length of new file in bytes. |
| n | The patch itself, a sequence of _literally added data_ and _common block records_ (see below). |

Literally added data records have the following format:

| Number of bytes | Description                |
|-----------------|----------------------------|
|  1              | `43` (ASCII code for `+`). |
|  4              | Number of bytes.           |
|  n              | Data.                      |

Common block records have the following format:

| Number of bytes | Description                |
|-----------------|----------------------------|
| 1               | `64` (ASCII code for `@`). |
| 4               | File position in old file. |
| 4               | Number of bytes.           |
| 4               | Checksum (details below).  |

The checksum is computed using the following algorithm:

```pascal
// rotate current checksum left by two and xor in the current byte
function CheckSum(Data: array of Int8): Int32;
var
  I: Int8;
begin
  Result := 0;
  for I in Data do
  begin
    Result := ((Result shr 30) and 3) or (Result shl 2);
    Result := Result xor I;
  end;
end;
```

## Administrativia

This document relates to BDiff version 1.0.0-beta and later.

See the file `LICENSE.md` for details of licensing and copyright.

THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE OF THIS SOFTWARE.

[diff(1)]: https://man.openbsd.org/diff.1
[isprint(3)]: https://man.openbsd.org/isprint.3
