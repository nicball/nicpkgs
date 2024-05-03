# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.(res|resi)$ %{
  set-option buffer filetype rescript
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=rescript %<
  require-module rescript
  set-option window static_words %opt{rescript_static_words}
  hook -group rescript-insert window InsertChar '\*' rescript-insert-closing-comment-bracket
  hook -group rescript-insert window InsertChar '\n' rescript-insert-on-newline
  hook -group rescript-indent window InsertChar '\n' rescript-indent-on-newline
  hook -group rescript-indent window InsertChar '\}' rescript-indent-on-closing-curly-brace
  hook -group rescript-indent window InsertChar '\]' rescript-indent-on-closing-square-bracket
  hook -group rescript-indent window InsertChar '\)' rescript-indent-on-closing-paren
  hook -group rescript-trim-indent window ModeChange pop:insert:.* rescript-trim-indent
>

hook -group rescript-highlight global WinSetOption filetype=rescript %{
  add-highlighter window/rescript ref rescript
  alias window alt rescript-alternative-file
  hook -once -always window WinSetOption filetype=.* %{
    unalias window alt rescript-alternative-file
    remove-highlighter window/rescript
  }
}

provide-module rescript %∎

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/rescript regions
add-highlighter shared/rescript/code default-region group
add-highlighter shared/rescript/string region (?<!['\\])" (?<!\\)(\\\\)*" fill string
add-highlighter shared/rescript/quotedstring region -match-capture %"\{(\w*)\|" %"\|(\w*)\}" fill string
add-highlighter shared/rescript/comment region /\* \*/ fill comment
add-highlighter shared/rescript/line-comment region // $ fill comment

add-highlighter shared/rescript/code/char regex %{\B'([^'\\]|(\\[\\"'nrtb])|(\\\d{3})|(\\x[a-fA-F0-9]{2})|(\\o[0-7]{3}))'\B} 0:value

# integer literals
add-highlighter shared/rescript/code/ regex \b[0-9][0-9_]*([lLn]?)\b              0:value
add-highlighter shared/rescript/code/ regex \b0[xX][A-Fa-f0-9][A-Fa-f0-9_]*([lLn]?)\b     0:value
add-highlighter shared/rescript/code/ regex \b0[oO][0-7][0-7_]*([lLn]?)\b           0:value
add-highlighter shared/rescript/code/ regex \b0[bB][01][01_]*([lLn]?)\b             0:value
# float literals
add-highlighter shared/rescript/code/ regex \b[0-9][0-9_]*(\.[0-9_]*)?([eE][+-]?[0-9][0-9_]*)?             0:value
add-highlighter shared/rescript/code/ regex \b0[xX][A-Fa-f0-9][A-Fa-f0-9]*(\.[a-fA-F0-9_]*)?([pP][+-]?[0-9][0-9_]*)? 0:value
# constructors. must be put before any module name highlighter, as a fallback for capitalized identifiers
add-highlighter shared/rescript/code/ regex \b[A-Z][a-zA-Z0-9_]*\b              0:value
# the module name in a module path, e.g. 'M' in 'M.x'
add-highlighter shared/rescript/code/ regex (\b[A-Z][a-zA-Z0-9_]*[\h\n]*)(?=\.)         0:module
# (simple) module declarations
add-highlighter shared/rescript/code/ regex (?<=module)([\h\n]+[A-Z][a-zA-Z0-9_]*)      0:module
# (simple) signature declarations. 'type' is also highlighted, due to the lack of quantifiers in lookarounds.
# Hence we must put keyword highlighters after this to recover proper highlight for 'type'
add-highlighter shared/rescript/code/ regex (?<=module)([\h\n]+type[\h\n]+[A-Z][a-zA-Z0-9_]*) 0:module
# (simple) open statements
add-highlighter shared/rescript/code/ regex (?<=open)([\h\n]+[A-Z][a-zA-Z0-9_]*)        0:module
# operators
add-highlighter shared/rescript/code/ regex [@!$%%^&*\-+=|<>/?]+                0:operator


# Macro
# ‾‾‾‾‾

evaluate-commands %sh{
  keywords="true|false|let|rec|type|external|mutable|lazy|private|of|with|if|else|switch|when|and|as|module|constraint|import|export|open|include"
  keywords="${keywords}|for|to|downto|while|in|try|catch|exception|assert|async|await|bool|int|float|char|string|unit|promise|array|option|ref|exn|format|list"
  keywords="${keywords}|mod|land|lor|lxor|lsl|lsr|asr|or"

  printf %s\\n "declare-option str-list rescript_static_words ${keywords}" | tr '|' ' '

# must be put at last, since we have highlighted some keywords ('type' in 'module type') to other things
  printf %s "
  add-highlighter shared/rescript/code/ regex \b(${keywords})\b 0:keyword
  "
}

# Conveniences
# ‾‾‾‾‾‾‾‾‾‾‾‾

# C has header and source files and you need to often switch between them.
# Similarly Rescript has .res (implementation) and .resi (interface files) and
# one often needs to switch between them.
#
# This command provides a simple functionality that allows you to accomplish this.
define-command rescript-alternative-file -docstring 'Switch between .res and .resi file or vice versa' %{
  evaluate-commands %sh{
    if [ "${kak_buffile##*.}" = 'ml' ]; then
      printf "edit -- '%s'" "$(printf %s "${kak_buffile}i" | sed "s/'/''/g")"
    elif [ "${kak_buffile##*.}" = 'mli' ]; then
      printf "edit -- '%s'" "$(printf %s "${kak_buffile%i}" | sed "s/'/''/g")"
    fi
  }
}

# Remove trailing whitespaces
define-command -hidden rescript-trim-indent %{
  evaluate-commands -no-hooks -draft -itersel %{
    try %{ execute-keys -draft x s \h+$ <ret> d }
  }
}

define-command -hidden rescript-insert-on-newline %[ evaluate-commands -itersel -draft %[
    execute-keys <semicolon>
    try %[
        evaluate-commands -draft -save-regs '/"' %[
            # copy the commenting prefix
            execute-keys -save-regs '' k x1s^\h*(//+\h*)<ret> y
            try %[
                # if the previous comment isn't empty, create a new one
                execute-keys x<a-K>^\h*//+\h*$<ret> jxs^\h*<ret>P
            ] catch %[
                # if there is no text in the previous comment, remove it completely
                execute-keys d
            ]
        ]

        # trim trailing whitespace on the previous line
        try %[ execute-keys -draft k x s\h+$<ret> d ]
    ]
    try %[
        # if the previous line isn't within a comment scope, break
        execute-keys -draft kx <a-k>^(\h*/\*|\h+\*(?!/))<ret>

        # find comment opening, validate it was not closed, and check its using star prefixes
        execute-keys -draft <a-?>/\*<ret><a-H> <a-K>\*/<ret> <a-k>\A\h*/\*([^\n]*\n\h*\*)*[^\n]*\n\h*.\z<ret>

        try %[
            # if the previous line is opening the comment, insert star preceeded by space
            execute-keys -draft kx<a-k>^\h*/\*<ret>
            execute-keys -draft i*<space><esc>
        ] catch %[
           try %[
                # if the next line is a comment line insert a star
                execute-keys -draft jx<a-k>^\h+\*<ret>
                execute-keys -draft i*<space><esc>
            ] catch %[
                try %[
                    # if the previous line is an empty comment line, close the comment scope
                    execute-keys -draft kx<a-k>^\h+\*\h+$<ret> x1s\*(\h*)<ret>c/<esc>
                ] catch %[
                    # if the previous line is a non-empty comment line, add a star
                    execute-keys -draft i*<space><esc>
                ]
            ]
        ]

        # trim trailing whitespace on the previous line
        try %[ execute-keys -draft k x s\h+$<ret> d ]
        # align the new star with the previous one
        execute-keys Kx1s^[^*]*(\*)<ret>&
    ]
] ]

define-command -hidden rescript-indent-on-newline %< evaluate-commands -draft -itersel %<
    execute-keys <semicolon>
    try %<
        # if previous line is part of a comment, do nothing
        execute-keys -draft <a-?>/\*<ret> <a-K>^\h*[^/*\h]<ret>
    > catch %<
        # else if previous line closed a paren (possibly followed by words and a comment),
        # copy indent of the opening paren line
        execute-keys -draft kx 1s([)\]])(\h+\w+)*\h*(\;\h*)?(?://[^\n]+)?\n\z<ret> m<a-semicolon>J <a-S> 1<a-&>
    > catch %<
        # else indent new lines with the same level as the previous one
        execute-keys -draft K <a-&>
    >
    # remove previous empty lines resulting from the automatic indent
    try %< execute-keys -draft k x <a-k>^\h+$<ret> Hd >
    # indent after an opening paren at end of line
    try %< execute-keys -draft k x <a-k>[{([]\h*$<ret> j <a-gt> >
    # deindent closing paren when after cursor
    try %< execute-keys -draft x <a-k> ^\h*[})\]] <ret> gh / [})] <esc> m <a-S> 1<a-&> >
> >

define-command -hidden rescript-indent-on-closing-curly-brace %[
    evaluate-commands -draft -itersel -verbatim try %[
        # check if alone on the line and select to opening curly brace
        execute-keys <a-h><a-:><a-k>^\h*\}$<ret>hm
        # align to selection start
        execute-keys <a-S>1<a-&>
    ]
]

define-command -hidden rescript-indent-on-closing-square-bracket %<
    evaluate-commands -draft -itersel -verbatim try %<
        # check if alone on the line and select to opening curly brace
        execute-keys <a-h><a-:><a-k>^\h*\]$<ret>hm
        # align to selection start
        execute-keys <a-S>1<a-&>
    >
>

define-command -hidden rescript-indent-on-closing-paren %[
    evaluate-commands -draft -itersel -verbatim try %[
        # check if alone on the line and select to opening curly brace
        execute-keys <a-h><a-:><a-k>^\h*\)$<ret>hm
        # align to selection start
        execute-keys <a-S>1<a-&>
    ]
]

# The Rescript comment is `/* Some comment */`. Like the C-family this can be a multiline comment.
#
# Recognize when the user is trying to commence a comment when they type `/*` and
# then automatically insert `*/` on behalf of the user. A small convenience.
define-command -hidden rescript-insert-closing-comment-bracket %{
  try %{
    execute-keys -draft 'HH<a-k>/\*<ret>'
    execute-keys ' */<left><left><left>'
  }
}

∎
