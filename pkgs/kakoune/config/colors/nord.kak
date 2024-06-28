# Nord Theme
# https://www.nordtheme.com/docs/colors-and-palettes

# Polar Night (black)
declare-option str nord0 "rgb:2e3440"
declare-option str nord1 "rgb:3b4252"
declare-option str nord2 "rgb:434c5e"
declare-option str nord3 "rgb:4c566a"
# Snow Storm (white)
declare-option str nord4 "rgb:d8dee9"
declare-option str nord5 "rgb:e5e9f0"
declare-option str nord6 "rgb:eceff4"
# Frost (blue/green)
declare-option str nord7 "rgb:8fbcbb"
declare-option str nord8 "rgb:88c0d0"
declare-option str nord9 "rgb:81a1c1"
declare-option str nord10 "rgb:5e81ac"
# Aurora 
declare-option str nord11 "rgb:bf616a" # red
declare-option str nord12 "rgb:d08770" # orange
declare-option str nord13 "rgb:ebcb8b" # yellow
declare-option str nord14 "rgb:a3be8c" # green
declare-option str nord15 "rgb:b48ead" # purple

set-face global Default   "%opt{nord6},%opt{nord0}"

# code
set-face global variable  "%opt{nord4}"
set-face global builtin   "%opt{nord5}+b"
set-face global type      "%opt{nord7}"
set-face global function  "%opt{nord8}"
set-face global keyword   "%opt{nord9}"
set-face global meta      "%opt{nord9}"
set-face global attribute "%opt{nord12}"
set-face global module    "%opt{nord13}"
set-face global string    "%opt{nord14}"
set-face global value     "%opt{nord15}"
set-face global comment   "%opt{nord3}+i"
set-face global operator  "%opt{nord9}"
set-face global documentation comment

# LSP
set-face global InlayHint comment

# kakoune
set-face global PrimaryCursor      "%opt{nord0},%opt{nord8}+Bfg"
set-face global PrimarySelection   "%opt{nord0},%opt{nord10}+g"
set-face global SecondaryCursor    "%opt{nord0},%opt{nord7}+fg"
set-face global SecondarySelection "%opt{nord0},%opt{nord9}+g"
set-face global LineNumbers        "%opt{nord10}+b"
set-face global LineNumberCursor   "%opt{nord0},%opt{nord10}+b"
set-face global LineNumbersWrapped "%opt{nord3},%opt{nord0}"
set-face global WrapMarker         "%opt{nord13}+f"
set-face global MenuForeground   "%opt{nord0},%opt{nord8}+b"
set-face global MenuBackground   "%opt{nord6},%opt{nord3}"
set-face global MenuInfo         "%opt{nord0}+iu"
set-face global StatusLine       "%opt{nord6},%opt{nord1}"
set-face global StatusLineMode   "%opt{nord0},%opt{nord7}+b"
set-face global StatusLineInfo   "%opt{nord6}+b"
set-face global StatusLineValue  "%opt{nord8}+i"
set-face global StatusCursor     "%opt{nord0},%opt{nord8}"
set-face global Prompt           "%opt{nord8}"
set-face global Whitespace       "%opt{nord10},%opt{nord1}+f"
set-face global MatchingChar     "%opt{nord0},%opt{nord12}+F"
set-face global BufferPadding      "%opt{nord10},%opt{nord0}"
set-face global Information        "%opt{nord0},%opt{nord9}"
set-face global Error              "%opt{nord4},%opt{nord11}"

# Markup
set-face global title         "%opt{nord8}+b"
set-face global header        "%opt{nord7}+b"
set-face global mono          "%opt{nord10}"
set-face global block         "%opt{nord13}"
set-face global link          "%opt{nord8}+u"
set-face global bullet        "%opt{nord12}"
set-face global list          "%opt{nord14}"
