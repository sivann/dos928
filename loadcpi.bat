REM This is an alternative way to load a font using DOS "mode" program
REM ANSI.SYS must be loaded to be able to use "mode"
REM

@echo off
mode con codepage prepare=((928) 928.cpi)
mode con codepage select=928
mode con cp refresh
