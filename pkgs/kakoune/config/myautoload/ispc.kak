hook global BufCreate .*\.ispc$ %{
  set-option buffer filetype ispc
}

hook global WinSetOption filetype=ispc %[
  require-module c-family
  require-module ispc

  add-highlighter window/ispc ref ispc

  set-option window static_words %opt{ispc_static_words} %opt{c_static_words}

  hook -group "ispc-trim-indent" window ModeChange pop:insert:.* c-family-trim-indent
  hook -group "ispc-insert" window InsertChar \n c-family-insert-on-newline
  hook -group "ispc-indent" window InsertChar \n c-family-indent-on-newline
  hook -group "ispc-indent" window InsertChar \{ c-family-indent-on-opening-curly-brace
  hook -group "ispc-indent" window InsertChar \} c-family-indent-on-closing-curly-brace
  hook -group "ispc-insert" window InsertChar \} c-family-insert-on-closing-curly-brace


  hook -once -always window WinSetOption filetype=.* %{
    remove-hooks window ispc-.+
  }
]

hook -group ispc-highlight global WinSetOption filetype=c %{
  add-highlighter window/ispc group
  hook -once -always window WinSetOption filetype=.* %{ remove-highlighter window/ispc }
}

provide-module ispc %§

add-highlighter shared/ispc regions
add-highlighter shared/ispc/code default-region group
add-highlighter shared/ispc/code/c-keywords ref c/code/keywords
add-highlighter shared/ispc/code/c-attributes ref c/code/attributes
add-highlighter shared/ispc/code/c-types ref c/code/types
add-highlighter shared/ispc/code/c-values ref c/code/values
add-highlighter shared/ispc/string region %{(?<!')(?<!'\\)"} %{(?<!\\)(?:\\\\)*"} fill string
add-highlighter shared/ispc/documentation_comment region /\*(\*[^/]|!) \*/ fill documentation
add-highlighter shared/ispc/line_documentation_comment region //[/!] $ fill documentation
add-highlighter shared/ispc/comment region /\* \*/ fill comment
add-highlighter shared/ispc/line_comment region // (?<!\\)(?=\n) fill comment
add-highlighter shared/ispc/disabled region -recurse "#\h*if(?:def)?" ^\h*?#\h*if\h+(?:0|FALSE)\b "#\h*(?:else|elif|endif)" fill comment
add-highlighter shared/ispc/ifdef region %{^\h*\K#\h*(?:define|elif|if)(?=\h)} %{(?<!\\)(?=\s)|(?=//)} fill meta
add-highlighter shared/ispc/macro region %{^\h*#} %{(?<!\\)(?=\n)|(?=//)} group
add-highlighter shared/ispc/macro/ regex ^\h*(#\h*\S*) 1:meta
add-highlighter shared/ispc/macro/ regex ^\h*#\h*include\h+(<[^>]*>|"(?:[^"\\]|\\.)*") 1:module
add-highlighter shared/ispc/macro/ regex /\*.*?\*/ 0:comment

# integer literals
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b[1-9]('?\d+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b0b[01]('?[01]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b0('?[0-7]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*(ul?l?|ll?u?)?\b(?!\.)} 0:value

# floating point literals
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b\d('?\d+)*\.(d\b|\B)(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b\d('?\d+)*\.?e[+-]?\d('?\d+)*d?\b(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)(\b(\d('?\d+)*)|\B)\.\d('?[\d]+)*(e[+-]?\d('?\d+)*)?d?\b(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*\.(d\b|\B)(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b0x[\da-f]('?[\da-f]+)*\.?p[+-]?\d('?\d+)*)?d?\b(?!\.)} 0:value
add-highlighter shared/ispc/code/ regex %{(?i)(?<!\.)\b0x([\da-f]('?[\da-f]+)*)?\.\d('?[\d]+)*(p[+-]?\d('?\d+)*)?d?\b(?!\.)} 0:value

evaluate-commands %sh{
  keywords='assert assume cbreak ccontinue creturn delete launch new print soa sync task unmasked
    cif cdo cfor cwhile foreach foreach_tiled foreach_unique foreach_active
    programCount programIndex taskCount taskCount0 taskCount1 taskCount3 taskIndex taskIndex0 taskIndex1 taskIndex2
    operator in template typename'

  attributes='noinline __vectorcall __regcall'

  types='export uniform varying int8 int16 int32 int64 uint8 uint16 uint32 uint64 float16 complex imaginary'

  macros='ISPC ISPC_POINTER_SIZE ISPC_MAJOR_VERSION ISPC_MINOR_VERSION TARGET_WIDTH PI
    TARGET_ELEMENT_WIDTH ISPC_UINT_IS_DEFINED ISPC_FP16_SUPPORTED ISPC_FP64_SUPPORTED ISPC_LLVM_INTRINSICS_ENABLED
    ISPC_TARGET_NEON ISPC_TARGET_SSE2 ISPC_TARGET_SSE4 ISPC_TARGET_AVX ISPC_TARGET_AVX2 ISPC_TARGET_AVX512KNL ISPC_TARGET_AVX512SKX
    ISPC_TARGET_AVX512SPR'

  join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

  # Add the language's grammar to the static completion list
  printf %s\\n "declare-option str-list ispc_static_words $(join "${keywords} ${attributes} ${types} ${macros}" ' ')"

  # Highlight keywords
  printf %s "
    add-highlighter shared/ispc/code/keywords regex \b($(join "${keywords}" '|'))\b 0:keyword
    add-highlighter shared/ispc/code/attributes regex \b($(join "${attributes}" '|'))\b 0:attribute
    add-highlighter shared/ispc/code/types regex \b($(join "${types}" '|'))\b 0:type
    add-highlighter shared/ispc/code/values regex \b($(join "${macros}" '|'))\b 0:value
  "
}

§
