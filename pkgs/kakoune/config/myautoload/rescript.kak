# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*\.(res|resi)$ %{
  set-option buffer filetype rescript
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=rescript %{
  require-module rescript
  set-option window static_words %opt{rescript_static_words}
  hook window InsertChar -group rescript-insert '\*' rescript-insert-closing-comment-bracket
  hook window InsertChar \n -group rescript-insert rescript-insert-on-new-line
  hook window ModeChange pop:insert:.* -group rescript-trim-indent rescript-trim-indent
}

hook -group rescript-highlight global WinSetOption filetype=rescript %{
  add-highlighter window/rescript ref rescript
  alias window alt rescript-alternative-file
  hook -once -always window WinSetOption filetype=.* %{
    unalias window alt rescript-alternative-file
    remove-highlighter window/rescript
  }
}

provide-module rescript %{

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter shared/rescript regions
add-highlighter shared/rescript/code default-region group
add-highlighter shared/rescript/string region (?<!['\\])" (?<!\\)(\\\\)*" fill string
add-highlighter shared/rescript/quotedstring region -match-capture %"\{(\w*)\|" %"\|(\w*)\}" fill string
add-highlighter shared/rescript/comment region -recurse \Q(* \Q(* \Q*) fill comment

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

}

# Remove trailing whitespaces
define-command -hidden rescript-trim-indent %{
  evaluate-commands -no-hooks -draft -itersel %{
    try %{ execute-keys -draft x s \h+$ <ret> d }
  }
}

# Preserve indentation when creating new line
define-command -hidden rescript-insert-on-new-line %{
  evaluate-commands -draft -itersel %{
    # copy white spaces at the beginnig of the previous line
    try %{ execute-keys -draft K <a-&> }
    # increase indentation if the previous line ended with some charactors
    try ' execute-keys -draft k x s (=|\(|\{|\[|=>)$ <ret> j <a-gt> ' # }
  }
}

# The OCaml comment is `(* Some comment *)`. Like the C-family this can be a multiline comment.
#
# Recognize when the user is trying to commence a comment when they type `(*` and
# then automatically insert `*)` on behalf of the user. A small convenience.
define-command -hidden rescript-insert-closing-comment-bracket %{
  try %{
    execute-keys -draft 'HH<a-k>/\*<ret>'
    execute-keys ' */<left><left><left>'
  }
}
