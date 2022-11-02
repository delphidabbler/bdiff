--------------------------------------------------------------------------------

This file contains copies of emails exchanged between Peter Johnson and Stefan
Reuther that relate to licensing of Peter's Pascal translation of Stefan's
original source code.

**NOTE:** Email addresses have been partially obscured.

--------------------------------------------------------------------------------

From: xxxxx@delphidabbler.com
To:   Streu@xxxxx.de
Date: 04/12/2003 01:59

Hi Stefan

I found v0.2 of your BDiff/BPatch files on the net and the programs meet my
needs quite well. However I would like to modify the code to strip out the
core functions and place that in a DLL to be accessed by one of my Windows
programs. Since I program in mainly in Object Pascal, I've created a literal
translation of your code in Pascal (to run on Windows platforms) as a first
step.

I've published the Pascal version on my website (see
http://www.delphidabbler.com/software.php?id=bdiff) and have tried to comply
with the terms published with v0.2 of your code. The new version is made
available under the same terms as your original code and the C code is
included in the download. You've been given full credit for the additional
code and your copyright is acknowledged.

I hope you are happy for your code to be used in this way and for me to
develop it to meet my needs and to publish the result. Please let me know if
you have any problems with this.

Thanks for making your code available. Please do get in touch if you have
any comments.

Regards
Peter Johnson
xxxxx@openlink.org
http://www.delphidabbler.com/

--------------------------------------------------------------------------------

From: Streu@xxxxx.de
To:   xxxxx@delphidabbler.com
Date: 04/12/2003 12:06

Hello,

On Thu, Dec 04, 2003 at 01:59:05AM -0000, Peter David Johnson wrote:
> > I found v0.2 of your BDiff/BPatch files on the net and the programs meet my
> > needs quite well. However I would like to modify the code to strip out the
> > core functions and place that in a DLL to be accessed by one of my Windows
> > programs.

Go ahead and do what you want with it.

> > I've published the Pascal version on my website (see
> > http://www.delphidabbler.com/software.php?id=bdiff) and have tried to comply
> > with the terms published with v0.2 of your code. The new version is made
> > available under the same terms as your original code and the C code is
> > included in the download. You've been given full credit for the additional
> > code and your copyright is acknowledged.

Nice. (Don't worry about those "copyright terms" too much.
Everything's fine with me unless you claim 'I invented it and
now I patent it').

I mainly wrote that program to give out binary patches of my
other programs; I also have a nice Turbo Pascal version of a
'patch' utility; if you want it, no problem, but I doubt it
helps you too much under Windows. For fairness I should say the
'bdiff' is not the best binary-diff program there is (at least I
already had one which found smaller diffs, but I can't find it
right now), but it is simple and easy to handle.

> > I hope you are happy for your code to be used in this way and for me to
> > develop it to meet my needs and to publish the result. Please let me know if
> > you have any problems with this.

To be honest, I had almost forgotten that that file was on my
web site  :)

Oh well, this reminds me that the version on the website has a
bug. And since I forgot that it's there, I forgot to update it.
I attach the fixed version of 'blksort.c'. The bug causes it to
crash on certain data. The problem is in 'find_string'.


Stefan

--------------------------------------------------------------------------------

