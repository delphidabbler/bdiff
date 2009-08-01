{
 * UBPatchTypes.pas
 *
 * Contains type and global constant declarations for BPatch.
 *
 * Copyright (c) 2003-2009 Peter D Johnson (www.delphidabbler.com).
 *
 * $Rev$
 * $Date$
 *
 * THIS SOFTWARE IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY.
 * IN NO EVENT WILL THE AUTHORS BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE
 * USE OF THIS SOFTWARE.
 *
 * For conditions of distribution and use see the LICENSE file of visit
 * http://www.delphidabbler.com/software/bdiff/license
}


unit UBPatchTypes;


interface


type
  { size_t type is used extensively in C and in original code for this program }
  size_t = Cardinal;

const
  { end of file value returned by fgetc() }
  EOF = -1;
  { seek flag used by fseek() (other possible values not used in program) }
  SEEK_SET = 0;


implementation

end.

