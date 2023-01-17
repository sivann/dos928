An addition to the Angelos Karageorgiou's vgagreek (http://unix.gr/) DOS greek keyboard driver. 

The additions/modifications enable DOS programs to 

* support the ELOT-928 (iso-8859-7) character set. 
* includes support for accented capitals, accented with diaeresis, and the middle dot (ano telia)! 

This set includes a keyboard driver (TSR, x86 assembly) and vga fonts.

Circa 2000.


# About

This set of programs is an addition to the Angelos Karageorgiou's vgagreek 
DOS greek keyboard driver. The additions/modifications enable DOS programs to
support the ELOT-928 (iso-8859-7) character set. By using the following 
programs you'll be able to write and see greek in DOS using the the above 
character set. The ELOT-928 character set is the greek character set used by
most UNIX systems, on the internet, and is very similar to the one used by
MSWindows. Windows uses a character set called "cp1253" which does not exist in
any ISO standard. The letters are in the same place in this charset except the
"A accented capital" (alpha tonoumeno kefalaio).

The original vgagreek package, and Microsoft's command prompt display greek 
using Memotek's 437gr (737) character set which is completely different from
928. 

The only problem you will have with the 928 charset in DOS is that the greek
characters are in the place of the DOS "graphics" (lines,corners, et.c) so 
instead of those you will see greek letters. This is not a problem if you
use an editor such as vim which doesn't display those characters.

# Purpose
I had an old 486 laptop with 2MB of memory. I wanted to use my old favourite
DOS programs, but writing greek involved converting each time the text files to
the 928 charset with a filter. So I made this.

# Description/Instructions
This package contains 2 programs:

keygr928.com : this is a keyboard driver which enables you to write greek in 
               the 928 character set. You must load this from autoexec.bat or
               run it from command line. Only takes 1K of upper memory.
               Toggle key between english and greek are:
               Ctrl+"-"   and  Alt+1
               You may change them by reading scancodes.txt and changing
               the source file accordingly.

               Ex: keygr928 or loadhigh keygr928

vgablock.com: this is the original VGA function blocker for greek character 
              set slightly modified to load different fonts. You must load this
              to be able to see greek characters. It's a TSR and takes about 
              14kb of memory. Its purpose is to load the appropriate fonts each
              time you change screen resolution. It needs the fonts (*.fnt) to
              be able to load.
              *****
              928 fonts are provided ONLY for 25 and 50 lines display. The 
              other resolutions use the old 737 fonts.
              
              ex: vgablock

setfont.com:  This utility is from the fonted program by Ivan Llanas. You can
              use this instead of vgablock to load greek fonts. It doesn't 
              occupy any memory at all, but fonts are lost when you change
              screen resolutions (if you do) so you must re-run it. It is also
              capable of changing screen resolution to match the font loaded.
              ex: setfont 928-8x16.fnt

vga25.com:    display 25-lines/screen. Does not need ansi.sys
vga50.com:    display 50-lines/screen. Does not need ansi.sys


The fonts:
928-8x16.fnt :928 greek font. This size is the original 25 line-screen font size
928c8x16.fnt :a caligraphic version of the above.
928-8x8.fnt  :smaller version of the above for the 50-line resolution.

** for the other resolutions I haven't made any 928 fonts. **

gr*.fnt      :the old 737 encoded fonts of the original package.

928.cpi:     CPI file to use with original DOS utilities. Includes the above
             two fonts (928-8x16.fnt and 928-8x8.fnt)

loadcpi.bat: example on how to load the above .cpi



# Installation
1. remove all appearences of the following drivers from config.sys:
   display.sys
   country.sys
   ansi.sys is not neaded.

2. remove all appearences of the following from autoexec.bat
   mode con codepage prepare/select
   keyb


3. At the end of autoexec.bat add the following:
   lh keygr928
   lh vgablock

     OR

  lh keygr928
  setfont 928-8x16.fnt
 
Of course you must first copy the programs to your disk.


                        

Spiros Ioannou
