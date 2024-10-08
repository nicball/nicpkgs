# --------------------------------------------------------------------------------------------------- #
# kak colour codes; value:red, type,operator:yellow, variable,module,attribute:green,
#                   function,string,comment:cyan, keyword:blue, meta:magenta, builtin:default
# --------------------------------------------------------------------------------------------------- #

# Detection
# ‾‾‾‾‾‾‾‾‾

hook global BufCreate .*[.](rkt|rktd|rktl|rkts) %{
  set-option buffer filetype racket
}

# Initialization
# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾

hook global WinSetOption filetype=racket %{
  require-module racket

  set-option window static_words %opt{racket_static_words}

  set-option buffer extra_word_chars '!' '$' '%' '&' '*' '+' '-' '.' '/' ':' '<' '=' '>' '?' '@' '^' '_' '~'

  set-option buffer comment_line ';'
  set-option buffer comment_block_begin '#|'
  set-option buffer comment_block_end '|#'

  hook window ModeChange pop:insert:.* -group racket-trim-indent racket-trim-indent
  hook window InsertChar \n -group racket-indent racket-indent-on-new-line

  hook -once -always window WinSetOption filetype=.* %{ remove-hooks window racket-.+ }
}

hook -group racket-highlight global WinSetOption filetype=racket %{
  add-highlighter -override window/racket ref racket
  add-highlighter -override window/quasi  ref quasi
  add-highlighter -override window/quote  ref quote
  add-highlighter -override window/splice ref splice

  hook -once -always window WinSetOption filetype=.* %{
    remove-highlighter window/racket
    remove-highlighter window/quasi
    remove-highlighter window/quote
    remove-highlighter window/splice
  }
}

# --------------------------------------------------------------------------------------------------- #
provide-module -override racket %§

# Commands
# ‾‾‾‾‾‾‾‾

define-command -hidden racket-trim-indent %{
  # remove trailing white spaces
  try %{ execute-keys -draft -itersel <a-x> s \h+$ <ret> d }
}

declare-option \
  -docstring 'regex matching the head of forms which have options *and* indented bodies' \
  regex racket_special_indent_forms \
  '(?:def.*|if(-.*|)|let.*|lambda|with-.*|when(-.*|))'

define-command -hidden racket-indent-on-new-line %{
  # registers: i = best align point so far; w = start of first word of form
  evaluate-commands -draft -save-regs '/"|^@iw' -itersel %{
    execute-keys -draft 'gk"iZ'
    try %{
      execute-keys -draft '[bl"i<a-Z><gt>"wZ'

      try %{
        # If a special form, indent another (indentwidth - 1) spaces
        execute-keys -draft '"wze<a-k>\A' %opt{racket_special_indent_forms} '\z<ret>'
        execute-keys -draft '"wze<a-L>s.{' %sh{printf $(( kak_opt_indentwidth - 1 ))} '}\K.*<ret><a-;>;"i<a-Z><gt>'
      } catch %{
        # If not "special" form and parameter appears on line 1, indent to parameter
        execute-keys -draft '"wz<a-K>[()\[\]{}]<ret>e<a-l>s\h\K[^\s].*<ret><a-;>;"i<a-Z><gt>'
      }
    }
    try %{ execute-keys -draft '[rl"i<a-Z><gt>' }
    try %{ execute-keys -draft '[Bl"i<a-Z><gt>' }
    execute-keys -draft ';"i<a-z>a&<space>'
  }
}

# Highlighters
# ‾‾‾‾‾‾‾‾‾‾‾‾

add-highlighter -override shared/quasi  regions
add-highlighter -override shared/quote  regions
add-highlighter -override shared/splice regions

add-highlighter -override shared/quasi/comment  region ';' '$' fill comment
add-highlighter -override shared/quote/comment  region ';' '$' fill comment
add-highlighter -override shared/splice/comment region ';' '$' fill comment

add-highlighter -override shared/quasi/comment-block  region "#\|" "\|#" fill comment
add-highlighter -override shared/quote/comment-block  region "#\|" "\|#" fill comment
add-highlighter -override shared/splice/comment-block region "#\|" "\|#" fill comment

# link to regular expression <https://regex101.com/r/7T1rYq/1> as at 10/10/2020
add-highlighter -override shared/quasi/quasiquote region -recurse "\(" "`\(" "\)"  regex %{(`\()(?:.*)(\))}  1:red 2:red
add-highlighter -override shared/quote/unquote    region -recurse "\(" ",\(" "\)"  regex %{(,\()(?:.*)(\))}  1:green 2:green
add-highlighter -override shared/splice/splicing  region -recurse "\(" ",@\(" "\)" regex %{(,@\()(?:.*)(\))} 1:blue 2:blue

add-highlighter -override shared/racket regions
add-highlighter -override shared/racket/code default-region group

add-highlighter -override shared/racket/string        region '"' (?<!\\)(\\\\)*" fill string
add-highlighter -override shared/racket/comment       region ';' '$' fill comment
add-highlighter -override shared/racket/comment-form  region -recurse "\(" "#;\(" "\)" fill comment
add-highlighter -override shared/racket/comment-block region "#\|" "\|#" fill comment
add-highlighter -override shared/racket/quoted-form   region -recurse "\(" "'\(" "\)" fill variable

# FIXME: see above WIP #;1 2 should comment out 1 <https://docs.racket-lang.org/reference/reader.html#%28part._parse-comment%29>
# add-highlighter -override shared/racket/code/ regex %{#;[\w\d]+((-\w+)+)?(?=\s)} 0:comment

add-highlighter -override shared/racket/code/ regex (#t|#f|#T|#F)\b 0:value
add-highlighter -override shared/racket/code/ regex \Q#%\E(app|datum|declare|expression|module-begin|plain-app|plain-lambda|plain-module-begin|printing-module-begin|provide|require|stratified-body|top|top-interaction|variable-reference)\b 0:keyword

# racket classes and objects
add-highlighter -override shared/racket/code/ regex \b(this|writable|printable|object|externalizable|equal)(\Q%\E|<\Q%\E>) 0:keyword

# racket keyword argument examples; #:auto, #:auto-value, #:late-neq-projection
add-highlighter -override shared/racket/code/ regex %{#:\w+((-\w+)+)?} 0:meta

# racket ,unquote ,@unquote-splicing <https://docs.racket-lang.org/reference/quasiquote.html>
add-highlighter -override shared/racket/code/ regex %{,[\w\d]+((-\w+)+)?} 0:variable
add-highlighter -override shared/racket/code/ regex %{,@[\w\d]+((-\w+)+)?} 0:variable

# --------------------------------------------------------------------------------------------------- #
# link to regular expression <https://regex101.com/r/PoJ7wS/2> as at 01/04/2019
# <https://github.com/codemirror/CodeMirror/blob/master/mode/scheme/scheme.js#L46>
# --------------------------------------------------------------------------------------------------- #
# binary
add-highlighter -override shared/racket/code/ regex %{(#b|#b#(e|i)|#(e|i)#b)(?:[-+]i|[-+][01]+#*(?:/[01]+#*)?i|[-+]?[01]+#*(?:/[01]+#*)?@[-+]?[01]+#*(?:/[01]+#*)?|[-+]?[01]+#*(?:/[01]+#*)?[-+](?:[01]+#*(?:/[01]+#*)?)?i|[-+]?[01]+#*(?:/[01]+#*)?)((?=[()\s;"])|$)} 0:rgb:e8b5ce

# octal
add-highlighter -override shared/racket/code/ regex %{(#o|#o#(e|i)|#(e|i)#o)(?:[-+]i|[-+][0-7]+#*(?:/[0-7]+#*)?i|[-+]?[0-7]+#*(?:/[0-7]+#*)?@[-+]?[0-7]+#*(?:/[0-7]+#*)?|[-+]?[0-7]+#*(?:/[0-7]+#*)?[-+](?:[0-7]+#*(?:/[0-7]+#*)?)?i|[-+]?[0-7]+#*(?:/[0-7]+#*)?)((?=[()\s;"])|$)} 0:rgb:e8b5ce

# hexadecimal
add-highlighter -override shared/racket/code/ regex %{(#x|#x#(e|i)|#(e|i)#x)(?:[-+]i|[-+][\da-f]+#*(?:/[\da-f]+#*)?i|[-+]?[\da-f]+#*(?:/[\da-f]+#*)?@[-+]?[\da-f]+#*(?:/[\da-f]+#*)?|[-+]?[\da-f]+#*(?:/[\da-f]+#*)?[-+](?:[\da-f]+#*(?:/[\da-f]+#*)?)?i|[-+]?[\da-f]+#*(?:/[\da-f]+#*)?)((?=[()\s;"])|$)} 0:rgb:e8b5ce

# decimal
add-highlighter -override shared/racket/code/ regex %{(#d|#d#(e|i)|#(e|i)#d|\b)(?:[-+]i|[-+](?:(?:(?:\d+#+\.?#*|\d+\.\d*#*|\.\d+#*|\d+)(?:[esfdl][-+]?\d+)?)|\d+#*/\d+#*)i|[-+]?(?:(?:(?:\d+#+\.?#*|\d+\.\d*#*|\.\d+#*|\d+)(?:[esfdl][-+]?\d+)?)|\d+#*/\d+#*)@[-+]?(?:(?:(?:\d+#+\.?#*|\d+\.\d*#*|\.\d+#*|\d+)(?:[esfdl][-+]?\d+)?)|\d+#*/\d+#*)|[-+]?(?:(?:(?:\d+#+\.?#*|\d+\.\d*#*|\.\d+#*|\d+)(?:[esfdl][-+]?\d+)?)|\d+#*/\d+#*)[-+](?:(?:(?:\d+#+\.?#*|\d+\.\d*#*|\.\d+#*|\d+)(?:[esfdl][-+]?\d+)?)|\d+#*/\d+#*)?i|(?:(?:(?:\d+#+\.?#*|\d+\.\d*#*|\.\d+#*|\d+)(?:[esfdl][-+]?\d+)?)|\d+#*/\d+#*))((?=[\s();"])|$)} 0:rgb:e8b5ce

# extflonum
add-highlighter -override shared/racket/code/ regex %{(((#[bB](((((\+)|(-)))?((([0-1])+(#)*(\.)?(#)*)|((([0-1])+)?\.([0-1])+(#)*)|(([0-1])+(#)*/([0-1])+(#)*))(([tT](((\+)|(-)))?([0-1])+))?)|(((\+)|(-))(((inf\.)|(nan\.))[0ftT]))))|(#[oO](((((\+)|(-)))?((([0-7])+(#)*(\.)?(#)*)|((([0-7])+)?\.([0-7])+(#)*)|(([0-7])+(#)*/([0-7])+(#)*))(([tT](((\+)|(-)))?([0-7])+))?)|(((\+)|(-))(((inf\.)|(nan\.))[0ftT]))))|(#[xX](((((\+)|(-)))?((([0-9abcdefABCDEF])+(#)*(\.)?(#)*)|((([0-9abcdefABCDEF])+)?\.([0-9abcdefABCDEF])+(#)*)|(([0-9abcdefABCDEF])+(#)*/([0-9abcdefABCDEF])+(#)*))(([tT](((\+)|(-)))?([0-9abcdefABCDEF])+))?)|(((\+)|(-))(((inf\.)|(nan\.))[0ftT]))))|((#[bB])?(((((\+)|(-)))?((([0-9])+(#)*(\.)?(#)*)|((([0-9])+)?\.([0-9])+(#)*)|(([0-9])+(#)*/([0-9])+(#)*))(([tT](((\+)|(-)))?([0-9])+))?)|(((\+)|(-))(((inf\.)|(nan\.))[0ftT]))))))(?=[()\[\]{}",'`; \s])} 0:rgb:e8b5ce

# --------------------------------------------------------------------------------------------------- #
# characters
add-highlighter -override shared/racket/code/ regex %{((?i)((#\\null)|(#\\nul)|(#\\backspace)|(#\\tab)|(#\\newline)|(#\\linefeed)|(#\\vtab)|(#\\page)|(#\\return)|(#\\space)|(#\\rubout))(?I)|(#\\(([0-7]){1,3}))|(#\\u(([0-9abcdefABCDEF]){1,4}))|(#\\U(([0-9abcdefABCDEF]){1,8}))|(#\\[^a-zA-Z]|#\\[a-zA-Z](?=\s)))} 0:rgb:98971a

# --------------------------------------------------------------------------------------------------- #
# discolour a shabang file header
add-highlighter -override shared/racket/code/ regex "^(#!)(?S)(.+)" 1:default+af 2:default+af

# --------------------------------------------------------------------------------------------------- #
# If your neatness borders on obsessive at times head over to:
# <https://github.com/wlangstroth/vim-racket/blob/master/syntax/racket.vim>
# for some inspiration or a breath of fresh air....hold on tight and scroll.
evaluate-commands %sh{
  exec awk -f - <<'EOF'
    BEGIN{
      split("* + - /", operators);

      split("-> ->* ->*m ->d ->dm ->i ->m ... :do-in == => _ absent abstract all-defined-out all-from-out and any augment augment* augment-final augment-final* augride augride* begin begin-for-syntax begin0 case case-> case->m case-lambda class class* class-field-accessor class-field-mutator class/c class/derived combine-in combine-out command-line compound-unit compound-unit/infer cond cons/dc contract contract-out contract-pos/neg-doubling contract-struct contracted define define-compound-unit define-compound-unit/infer define-contract-struct define-custom-hash-types define-custom-set-types define-for-syntax define-local-member-name define-logger define-match-expander define-member-name define-module-boundary-contract define-namespace-anchor define-opt/c define-sequence-syntax define-serializable-class define-serializable-class* define-signature define-signature-form define-struct define-struct/contract define-struct/derived define-syntax define-syntax-rule define-syntaxes define-unit define-unit-binding define-unit-from-context define-unit/contract define-unit/new-import-export define-unit/s define-values define-values-for-export define-values-for-syntax define-values/invoke-unit define-values/invoke-unit/infer define/augment define/augment-final define/augride define/contract define/final-prop define/match define/overment define/override define/override-final define/private define/public define/public-final define/pubment define/subexpression-pos-prop define/subexpression-pos-prop/name delay delay/idle delay/name delay/strict delay/sync delay/thread do else except except-in except-out export extends failure-cont false false/c field field-bound? file flat-murec-contract flat-rec-contract for for* for*/and for*/async for*/first for*/fold for*/fold/derived for*/foldr for*/foldr/derived for*/hash for*/hasheq for*/hasheqv for*/last for*/list for*/lists for*/mutable-set for*/mutable-seteq for*/mutable-seteqv for*/or for*/product for*/set for*/seteq for*/seteqv for*/stream for*/sum for*/vector for*/weak-set for*/weak-seteq for*/weak-seteqv for-label for-meta for-syntax for-template for/and for/async for/first for/fold for/fold/derived for/foldr for/foldr/derived for/hash for/hasheq for/hasheqv for/last for/list for/lists for/mutable-set for/mutable-seteq for/mutable-seteqv for/or for/product for/set for/seteq for/seteqv for/stream for/sum for/vector for/weak-set for/weak-seteq for/weak-seteqv gen:custom-write gen:dict gen:equal+hash gen:set gen:stream generic get-field hash/dc if implies import include include-at/relative-to include-at/relative-to/reader include/reader inherit inherit-field inherit/inner inherit/super init init-depend init-field init-rest inner inspect instantiate interface interface* invariant-assertion invoke-unit invoke-unit/infer lambda lazy let let* let*-values let-syntax let-syntaxes let-values let/cc let/ec letrec letrec-syntax letrec-syntaxes letrec-syntaxes+values letrec-values lib link local local-require log-debug log-error log-fatal log-info log-warning match match* match*/derived match-define match-define-values match-lambda match-lambda* match-lambda** match-let match-let* match-let*-values match-let-values match-letrec match-letrec-values match/derived match/values member-name-key mixin module module* module+ nand new nor object-contract object/c only only-in only-meta-in open opt/c or overment overment* override override* override-final override-final* parameterize parameterize* parameterize-break parametric->/c place place* place/context planet prefix prefix-in prefix-out private private* prompt-tag/c protect-out provide provide-signature-elements provide/contract public public* public-final public-final* pubment pubment* quasiquote quasisyntax quasisyntax/loc quote quote-syntax quote-syntax/prune recontract-out recursive-contract relative-in rename rename-in rename-inner rename-out rename-super require send send* send+ send-generic send/apply send/keyword-apply set! set!-values set-field! shared stream stream* stream-cons struct struct* struct-copy struct-field-index struct-guard/c struct-out struct/c struct/contract struct/ctc struct/dc struct/derived submod super super-instantiate super-make-object super-new syntax syntax-case syntax-case* syntax-id-rules syntax-rules syntax/loc tag this thunk thunk* time unconstrained-domain-> unit unit-from-context unit/c unit/new-import-export unit/s unless unquote unquote-splicing unsyntax unsyntax-splicing values/drop when with-continuation-mark with-contract with-contract-continuation-mark with-handlers with-handlers* with-method with-syntax ~? ~@ λ", keywords);

      split("< <= = > >=", predicates);

      split("absolute-path? arity-at-least? arity-includes? arity=? arrow-contract-info?", predicatesA);

      split("base->? bitwise-bit-set? blame-missing-party? blame-original? blame-swapped? blame? boolean=? boolean? bound-identifier=? box? break-parameterization? byte-pregexp? byte-ready? byte-regexp? byte? bytes-converter? bytes-environment-variable-name? bytes-no-nuls? bytes<? bytes=? bytes>? bytes?", predicatesB);

      split("channel-put-evt? channel? chaperone-contract-property? chaperone-contract? chaperone-of? chaperone? char-alphabetic? char-blank? char-ci<=? char-ci<? char-ci=? char-ci>=? char-ci>? char-graphic? char-iso-control? char-lower-case? char-numeric? char-punctuation? char-ready? char-symbolic? char-title-case? char-upper-case? char-whitespace? char<=? char<? char=? char>=? char>? char? class? compile-target-machine? compiled-expression? compiled-module-expression? complete-path? complex? cons? continuation-mark-key? continuation-mark-set? continuation-prompt-available? continuation-prompt-tag? continuation? contract-equivalent? contract-first-order-passes? contract-property? contract-random-generate-env? contract-random-generate-fail? contract-stronger? contract-struct-list-contract? contract? custodian-box? custodian-memory-accounting-available? custodian-shut-down? custodian? custom-print-quotable? custom-write?", predicatesC);

      split("date*? date-dst? date? dict-can-functional-set? dict-can-remove-keys? dict-empty? dict-has-key? dict-implements? dict-mutable? dict? directory-exists? double-flonum?", predicatesD);

      split("empty? environment-variables? eof-object? ephemeron? eq-contract? eq? equal-contract? equal? equal?/recur eqv? even? evt? exact-integer? exact-nonnegative-integer? exact-positive-integer? exact? exn:break:hang-up? exn:break:terminate? exn:break? exn:fail:contract:arity? exn:fail:contract:blame? exn:fail:contract:continuation? exn:fail:contract:divide-by-zero? exn:fail:contract:non-fixnum-result? exn:fail:contract:variable? exn:fail:contract? exn:fail:filesystem:errno? exn:fail:filesystem:exists? exn:fail:filesystem:missing-module? exn:fail:filesystem:version? exn:fail:filesystem? exn:fail:network:errno? exn:fail:network? exn:fail:object? exn:fail:out-of-memory? exn:fail:read:eof? exn:fail:read:non-char? exn:fail:read? exn:fail:syntax:missing-module? exn:fail:syntax:unbound? exn:fail:syntax?  exn:fail:unsupported? exn:fail:user? exn:fail? exn:misc:match? exn:missing-module? exn:srclocs? exn?", predicatesE);

      split("false? file-exists? file-stream-port? filesystem-change-evt? fixnum? flat-contract-property? flat-contract? flonum? free-identifier=? free-label-identifier=? free-template-identifier=? free-transformer-identifier=? fsemaphore-try-wait? fsemaphore? future? futures-enabled?", predicatesF);

      split("generic-set? generic?", predicatesG);

      split("handle-evt? has-blame? has-contract? hash-empty? hash-eq? hash-equal? hash-eqv? hash-has-key? hash-keys-subset? hash-placeholder? hash-weak? hash?", predicatesH);

      split("identifier? immutable? impersonator-contract? impersonator-of? impersonator-property-accessor-procedure? impersonator-property? impersonator? implementation? implementation?/c inexact-real? inexact? infinite? input-port? inspector-superior? inspector? integer? interface-extension? interface? internal-definition-context? is-a? is-a?/c", predicatesI);

      split("keyword<? keyword?", predicatesK);

      split("liberal-define-context? link-exists? list-contract? list-prefix? list? listen-port-number? log-level? log-receiver? logger?", predicatesL);

      split("matches-arity-exactly? member-name-key=? member-name-key? method-in-interface? module-compiled-cross-phase-persistent? module-declared? module-path-index? module-path? module-predefined? module-provide-protected? mpair?", predicatesM);

      split("namespace-anchor? namespace? nan? natural? negative-integer? negative? non-empty-string? nonnegative-integer? nonpositive-integer? normalized-arity? null? number?", predicatesN);

      split("object-method-arity-includes? object-or-false=? object=? object? odd? output-port?", predicatesO);

      split("pair? parameter-procedure=? parameter? parameterization? path-element? path-for-some-system? path-has-extension? path-string? path<? path? phantom-bytes? place-channel? place-enabled? place-location? place-message-allowed? place? placeholder? plumber-flush-handle? plumber? port-closed? port-counts-lines? port-number? port-provides-progress-evts? port-try-file-lock? port-waiting-peer? port-writes-atomic? port-writes-special? port? positive-integer? positive? prefab-key? pregexp? pretty-print-style-table? primitive-closure? primitive? procedure-arity-includes? procedure-arity? procedure-closure-contents-eq? procedure-impersonator*? procedure-struct-type? procedure? progress-evt? promise-forced? promise-running? promise/name? promise? prop:arrow-contract? prop:orc-contract? prop:recursive-contract? proper-subset? pseudo-random-generator-vector? pseudo-random-generator?", predicatesP);

      split("rational? readtable? real? regexp-match-exact? regexp-match? regexp? relative-path? rename-transformer? resolved-module-path?", predicatesR);

      split("security-guard? semaphore-peek-evt? semaphore-try-wait? semaphore? sequence? set!-transformer? set-empty? set-eq? set-equal? set-eqv? set-implements? set-member? set-mutable? set-weak? set=? set? single-flonum-available? single-flonum? skip-projection-wrapper? special-comment? srcloc? stream-empty? stream? string-ci<=? string-ci<? string-ci=? string-ci>=? string-ci>? string-contains? string-environment-variable-name? string-locale-ci<? string-locale-ci=? string-locale-ci>? string-locale<? string-locale=? string-locale>? string-no-nuls? string-port? string-prefix? string-suffix? string<=? string<? string=? string>=? string>? string? struct-accessor-procedure? struct-constructor-procedure? struct-mutator-procedure? struct-predicate-procedure? struct-type-property-accessor-procedure? struct-type-property-predicate-procedure? struct-type-property? struct-type? struct? subclass? subclass?/c subprocess? subset? symbol-interned? symbol-unreadable? symbol<? symbol=? symbol? syntax-binding-set? syntax-local-transforming-module-provides? syntax-original? syntax-property-preserved? syntax-tainted? syntax-transforming-module-expression? syntax-transforming-with-lifts? syntax-transforming? syntax? system-big-endian?", predicatesS);

      split("tail-marks-match? tcp-accept-ready? tcp-listener? tcp-port? terminal-port? thread-cell-values? thread-cell? thread-dead? thread-group? thread-running? thread?", predicatesT);

      split("udp-bound? udp-connected? udp-multicast-loopback? udp? unit? unquoted-printing-string? unsupplied-arg?", predicatesU);

      split("variable-reference-constant? variable-reference-from-unsafe? variable-reference? vector-empty? vector? void void?", predicatesV);

      split("weak-box? will-executor?", predicatesW);

      split("zero?", predicatesXYZ);

      split("*list/c </c <=/c =/c >/c >=/c ~.a ~.s ~.v ~a ~e ~r ~s ~v", builtins);

      split("abort-current-continuation abs acos add-between add1 alarm-evt always-evt and/c andmap angle any/c append append* append-map apply argmax argmin arithmetic-shift arity-at-least arity-at-least-value arity-checking-wrapper arrow-contract-info arrow-contract-info-accepts-arglist arrow-contract-info-chaperone-procedure arrow-contract-info-check-first-order asin assf assoc assq assv atan", builtinsA);

      split("bad-number-of-results banner base->-doms/c base->-rngs/c between/c bitwise-and bitwise-bit-field bitwise-ior bitwise-not bitwise-xor blame-add-car-context blame-add-cdr-context blame-add-context blame-add-missing-party blame-add-nth-arg-context blame-add-range-context blame-add-unknown-context blame-context blame-contract blame-fmt->-string blame-negative blame-positive blame-replace-negative blame-source blame-swap blame-update blame-value box box-cas! box-immutable box-immutable/c box/c break-enabled break-thread build-chaperone-contract-property build-compound-type-name build-contract-property build-flat-contract-property build-list build-path build-path/convention-type build-string build-vector byte-pregexp byte-regexp bytes bytes->immutable-bytes bytes->list bytes->path bytes->path-element bytes->string/latin-1 bytes->string/locale bytes->string/utf-8 bytes-append bytes-append* bytes-close-converter bytes-convert bytes-convert-end bytes-copy bytes-copy! bytes-fill! bytes-join bytes-length bytes-open-converter bytes-ref bytes-set! bytes-utf-8-index bytes-utf-8-length bytes-utf-8-ref" , builtinsB);

      split("caaaar caaadr caaar caadar caaddr caadr caar cadaar cadadr cadar caddar cadddr caddr cadr call-in-continuation call-in-nested-thread call-with-atomic-output-file call-with-break-parameterization call-with-composable-continuation call-with-continuation-barrier call-with-continuation-prompt call-with-current-continuation call-with-default-reading-parameterization call-with-escape-continuation call-with-exception-handler call-with-file-lock/timeout call-with-immediate-continuation-mark call-with-input-bytes call-with-input-file call-with-input-file* call-with-input-string call-with-output-bytes call-with-output-file call-with-output-file* call-with-output-string call-with-parameterization call-with-semaphore call-with-semaphore/enable-break call-with-values call/cc call/ec car cartesian-product cdaaar cdaadr cdaar cdadar cdaddr cdadr cdar cddaar cddadr cddar cdddar cddddr cdddr cddr cdr ceiling channel-get channel-put channel-put-evt channel-try-get channel/c chaperone-box chaperone-channel chaperone-continuation-mark-key chaperone-evt chaperone-hash chaperone-hash-set chaperone-procedure chaperone-procedure* chaperone-prompt-tag chaperone-struct chaperone-struct-type chaperone-vector chaperone-vector* char->integer char-downcase char-foldcase char-general-category char-in char-in/c char-titlecase char-upcase char-utf-8-length check-duplicate-identifier check-duplicates checked-procedure-check-and-extract choice-evt class->interface class-info class-seal class-unseal cleanse-path close-input-port close-output-port coerce-chaperone-contract coerce-chaperone-contracts coerce-contract coerce-contract/f coerce-contracts coerce-flat-contract coerce-flat-contracts collect-garbage collection-file-path collection-path combinations combine-output compile compile-allow-set!-undefined compile-context-preservation-enabled compile-enforce-module-constants compile-syntax compiled-expression-recompile compose compose1 conjoin conjugate cons cons/c const continuation-mark-key/c continuation-mark-set->context continuation-mark-set->iterator continuation-mark-set->list continuation-mark-set->list* continuation-mark-set-first continuation-marks contract-continuation-mark-key contract-custom-write-property-proc contract-exercise contract-first-order contract-late-neg-projection contract-name contract-proc contract-projection contract-random-generate contract-random-generate-fail contract-random-generate-get-current-environment contract-random-generate-stash contract-random-generate/choose contract-struct-exercise contract-struct-generate contract-struct-late-neg-projection contract-val-first-projection convert-stream copy-directory/files copy-file copy-port cos cosh count current-blame-format current-break-parameterization current-code-inspector current-command-line-arguments current-compile current-compile-target-machine current-compiled-file-roots current-continuation-marks current-contract-region current-custodian current-directory current-directory-for-user current-drive current-environment-variables current-error-port current-eval current-evt-pseudo-random-generator current-force-delete-permissions current-future current-gc-milliseconds current-get-interaction-input-port current-inexact-milliseconds current-input-port current-inspector current-library-collection-links current-library-collection-paths current-load current-load-extension current-load-relative-directory current-load/use-compiled current-locale current-logger current-memory-use current-milliseconds current-module-declare-name current-module-declare-source current-module-name-resolver current-module-path-for-load current-namespace current-output-port current-parameterization current-plumber current-preserved-thread-cell-values current-print current-process-milliseconds current-prompt-read current-pseudo-random-generator current-read-interaction current-reader-guard current-readtable current-seconds current-security-guard current-subprocess-custodian-mode current-thread current-thread-group current-thread-initial-stack-size current-write-relative-directory curry curryr custodian-box-value custodian-limit-memory custodian-managed-list custodian-require-memory custodian-shutdown-all custom-print-quotable-accessor custom-write-accessor custom-write-property-proc", builtinsC);

      split("date date* date*-nanosecond date*-time-zone-name date-day date-hour date-minute date-month date-second date-time-zone-offset date-week-day date-year date-year-day datum->syntax datum-intern-literal default-continuation-prompt-tag degrees->radians delete-directory delete-directory/files delete-file denominator dict->list dict-clear dict-clear! dict-copy dict-count dict-for-each dict-implements/c dict-iter-contract dict-iterate-first dict-iterate-key dict-iterate-next dict-iterate-value dict-key-contract dict-keys dict-map dict-ref dict-ref! dict-remove dict-remove! dict-set dict-set! dict-set* dict-set*! dict-update dict-update! dict-value-contract dict-values directory-list disjoin display display-lines display-lines-to-file display-to-file displayln drop drop-common-prefix drop-right dropf dropf-right dump-memory-stats dup-input-port dup-output-port dynamic->* dynamic-get-field dynamic-object/c dynamic-place dynamic-place* dynamic-require dynamic-require-for-syntax dynamic-send dynamic-set-field! dynamic-wind", builtinsD);

      split("eighth empty empty-sequence empty-stream environment-variables-copy environment-variables-names environment-variables-ref environment-variables-set! eof eof-evt ephemeron-value eprintf eq-contract-val eq-hash-code equal-contract-val equal-hash-code equal-secondary-hash-code eqv-hash-code error error-display-handler error-escape-handler error-print-context-length error-print-source-location error-print-width error-value->string-handler eval eval-jit-enabled eval-syntax evt/c exact->inexact exact-ceiling exact-floor exact-round exact-truncate executable-yield-handler exit exit-handler exn exn-continuation-marks exn-message exn:break exn:break-continuation exn:break:hang-up exn:break:terminate exn:fail exn:fail:contract exn:fail:contract:arity exn:fail:contract:blame exn:fail:contract:blame-object exn:fail:contract:continuation exn:fail:contract:divide-by-zero exn:fail:contract:non-fixnum-result exn:fail:contract:variable exn:fail:contract:variable-id exn:fail:filesystem exn:fail:filesystem:errno exn:fail:filesystem:errno-errno exn:fail:filesystem:exists exn:fail:filesystem:missing-module exn:fail:filesystem:missing-module-path exn:fail:filesystem:version exn:fail:network exn:fail:network:errno exn:fail:network:errno-errno exn:fail:object exn:fail:out-of-memory exn:fail:read exn:fail:read-srclocs exn:fail:read:eof exn:fail:read:non-char exn:fail:syntax exn:fail:syntax-exprs exn:fail:syntax:missing-module exn:fail:syntax:missing-module-path exn:fail:syntax:unbound exn:fail:unsupported exn:fail:user exn:missing-module-accessor exn:srclocs-accessor exp expand expand-once expand-syntax expand-syntax-once expand-syntax-to-top-form expand-to-top-form expand-user-path explode-path expt", builtinsE);

      split("failure-result/c field-names fifth file->bytes file->bytes-lines file->lines file->list file->string file->value file-name-from-path file-or-directory-identity file-or-directory-modify-seconds file-or-directory-permissions file-position file-position* file-size file-stream-buffer-mode file-truncate filename-extension filesystem-change-evt filesystem-change-evt-cancel filesystem-root-list filter filter-map filter-not filter-read-input-port find-executable-path find-files find-library-collection-links find-library-collection-paths find-relative-path find-system-path findf first first-or/c flat-contract flat-contract-predicate flat-contract-with-explanation flat-named-contract flatten floating-point-bytes->real floor flush-output fold-files foldl foldr for-each force format fourth fprintf fsemaphore-count fsemaphore-post fsemaphore-wait future", builtinsF);

      split("gcd generate-member-key generate-temporaries gensym get-output-bytes get-output-string get-preference get/build-late-neg-projection get/build-val-first-projection getenv global-port-print-handler group-by group-execute-bit group-read-bit group-write-bit guard-evt", builtinsG);

      split("handle-evt hash hash->list hash-clear hash-clear! hash-copy hash-copy-clear hash-count hash-for-each hash-iterate-first hash-iterate-key hash-iterate-key+value hash-iterate-next hash-iterate-pair hash-iterate-value hash-keys hash-map hash-ref hash-ref! hash-ref-key hash-remove hash-remove! hash-set hash-set! hash-set* hash-set*! hash-update hash-update! hash-values hash/c hasheq hasheqv", builtinsE);

      split("identifier-binding identifier-binding-symbol identifier-label-binding identifier-prune-lexical-context identifier-prune-to-source-module identifier-remove-from-definition-context identifier-template-binding identifier-transformer-binding identity if/c imag-part impersonate-box impersonate-channel impersonate-continuation-mark-key impersonate-hash impersonate-hash-set impersonate-procedure impersonate-procedure* impersonate-prompt-tag impersonate-struct impersonate-vector impersonate-vector* impersonator-ephemeron impersonator-prop:application-mark impersonator-prop:blame impersonator-prop:contracted in-bytes in-bytes-lines in-combinations in-cycle in-dict in-dict-keys in-dict-pairs in-dict-values in-directory in-hash in-hash-keys in-hash-pairs in-hash-values in-immutable-hash in-immutable-hash-keys in-immutable-hash-pairs in-immutable-hash-values in-immutable-set in-indexed in-input-port-bytes in-input-port-chars in-lines in-list in-mlist in-mutable-hash in-mutable-hash-keys in-mutable-hash-pairs in-mutable-hash-values in-mutable-set in-naturals in-parallel in-permutations in-port in-producer in-range in-sequences in-set in-slice in-stream in-string in-syntax in-value in-values*-sequence in-values-sequence in-vector in-weak-hash in-weak-hash-keys in-weak-hash-pairs in-weak-hash-values in-weak-set index-of index-where indexes-of indexes-where inexact->exact input-port-append instanceof/c integer->char integer->integer-bytes integer-bytes->integer integer-in integer-length integer-sqrt integer-sqrt/remainder interface->method-names internal-definition-context-binding-identifiers internal-definition-context-introduce internal-definition-context-seal", builtinsI);

      split("keyword->string keyword-apply keywords-match kill-thread", builtinsK);

      split("last last-pair lcm length list list* list*of list->bytes list->mutable-set list->mutable-seteq list->mutable-seteqv list->set list->seteq list->seteqv list->string list->vector list->weak-set list->weak-seteq list->weak-seteqv list-ref list-set list-tail list-update list/c listof load load-extension load-on-demand-enabled load-relative load-relative-extension load/cd load/use-compiled local-expand local-expand/capture-lifts local-transformer-expand local-transformer-expand/capture-lifts locale-string-encoding log log-all-levels log-level-evt log-max-level log-message logger-name", builtinsL);

      split("magnitude make-arity-at-least make-base-empty-namespace make-base-namespace make-bytes make-channel make-chaperone-contract make-continuation-mark-key make-continuation-prompt-tag make-contract make-custodian make-custodian-box make-custom-hash make-custom-hash-types make-custom-set make-custom-set-types make-date make-date* make-derived-parameter make-directory make-directory* make-do-sequence make-empty-namespace make-environment-variables make-ephemeron make-exn make-exn:break make-exn:break:hang-up make-exn:break:terminate make-exn:fail make-exn:fail:contract make-exn:fail:contract:arity make-exn:fail:contract:blame make-exn:fail:contract:continuation make-exn:fail:contract:divide-by-zero make-exn:fail:contract:non-fixnum-result make-exn:fail:contract:variable make-exn:fail:filesystem make-exn:fail:filesystem:errno make-exn:fail:filesystem:exists make-exn:fail:filesystem:missing-module make-exn:fail:filesystem:version make-exn:fail:network make-exn:fail:network:errno make-exn:fail:object make-exn:fail:out-of-memory make-exn:fail:read make-exn:fail:read:eof make-exn:fail:read:non-char make-exn:fail:syntax make-exn:fail:syntax:missing-module make-exn:fail:syntax:unbound make-exn:fail:unsupported make-exn:fail:user make-file-or-directory-link make-flat-contract make-fsemaphore make-generic make-handle-get-preference-locked make-hash make-hash-placeholder make-hasheq make-hasheq-placeholder make-hasheqv make-hasheqv-placeholder make-immutable-custom-hash make-immutable-hash make-immutable-hasheq make-immutable-hasheqv make-impersonator-property make-input-port make-input-port/read-to-peek make-inspector make-interned-syntax-introducer make-keyword-procedure make-known-char-range-list make-limited-input-port make-list make-lock-file-name make-log-receiver make-logger make-mixin-contract make-mutable-custom-set make-none/c make-object make-output-port make-parameter make-parent-directory* make-phantom-bytes make-pipe make-pipe-with-specials make-placeholder make-plumber make-polar make-prefab-struct make-primitive-class make-proj-contract make-pseudo-random-generator make-reader-graph make-readtable make-rectangular make-rename-transformer make-resolved-module-path make-security-guard make-semaphore make-set!-transformer make-shared-bytes make-sibling-inspector make-special-comment make-srcloc make-string make-struct-field-accessor make-struct-field-mutator make-struct-type make-struct-type-property make-syntax-delta-introducer make-syntax-introducer make-temporary-file make-tentative-pretty-print-output-port make-thread-cell make-thread-group make-vector make-weak-box make-weak-custom-hash make-weak-custom-set make-weak-hash make-weak-hasheq make-weak-hasheqv make-will-executor map match-equality-test max mcar mcdr mcons member member-name-key-hash-code memf memory-order-acquire memory-order-release memq memv merge-input min mixin-contract module->exports module->imports module->indirect-exports module->language-info module->namespace module-compiled-exports module-compiled-imports module-compiled-indirect-exports module-compiled-language-info module-compiled-name module-compiled-submodules module-path-index-join module-path-index-resolve module-path-index-split module-path-index-submodule modulo mutable-set mutable-seteq mutable-seteqv n->th", builtinsM);

      split("nack-guard-evt namespace-anchor->empty-namespace namespace-anchor->namespace namespace-attach-module namespace-attach-module-declaration namespace-base-phase namespace-mapped-symbols namespace-module-identifier namespace-module-registry namespace-require namespace-require/constant namespace-require/copy namespace-require/expansion-time namespace-set-variable-value! namespace-symbol->identifier namespace-syntax-introduce namespace-undefine-variable! namespace-unprotect-module namespace-variable-value natural-number/c negate never-evt new-∀/c new-∃/c newline ninth non-empty-listof none/c normal-case-path normalize-arity normalize-path not not/c null number->string numerator", builtinsN);

      split("object->vector object-info object-interface object-name object=-hash-code one-of/c open-input-bytes open-input-file open-input-output-file open-input-string open-output-bytes open-output-file open-output-nowhere open-output-string or/c order-of-magnitude ormap other-execute-bit other-read-bit other-write-bit", builtinsO);

      split("parameter/c parse-command-line partition path->bytes path->complete-path path->directory-path path->string path-add-extension path-add-suffix path-convention-type path-element->bytes path-element->string path-get-extension path-list-string->path-list path-only path-replace-extension path-replace-suffix pathlist-closure peek-byte peek-byte-or-special peek-bytes peek-bytes! peek-bytes!-evt peek-bytes-avail! peek-bytes-avail!* peek-bytes-avail!-evt peek-bytes-avail!/enable-break peek-bytes-evt peek-char peek-char-or-special peek-string peek-string! peek-string!-evt peek-string-evt peeking-input-port permutations pi pi.f pipe-content-length place-break place-channel place-channel-get place-channel-put place-channel-put/get place-dead-evt place-kill place-wait placeholder-get placeholder-set! plumber-add-flush! plumber-flush-all plumber-flush-handle-remove! poll-guard-evt port->bytes port->bytes-lines port->lines port->list port->string port-closed-evt port-commit-peeked port-count-lines! port-count-lines-enabled port-display-handler port-file-identity port-file-unlock port-next-location port-print-handler port-progress-evt port-read-handler port-write-handler predicate/c prefab-key->struct-type prefab-struct-key preferences-lock-file-mode pregexp pretty-display pretty-format pretty-print pretty-print-.-symbol-without-bars pretty-print-abbreviate-read-macros pretty-print-columns pretty-print-current-style-table pretty-print-depth pretty-print-exact-as-decimal pretty-print-extend-style-table pretty-print-handler pretty-print-newline pretty-print-post-print-hook pretty-print-pre-print-hook pretty-print-print-hook pretty-print-print-line pretty-print-remap-stylable pretty-print-show-inexactness pretty-print-size-hook pretty-printing pretty-write primitive-result-arity print print-as-expression print-boolean-long-form print-box print-graph print-hash-table print-mpair-curly-braces print-pair-curly-braces print-reader-abbreviations print-struct print-syntax-width print-unreadable print-vector-length printable/c printf println procedure->method procedure-arity procedure-arity-includes/c procedure-arity-mask procedure-extract-target procedure-keywords procedure-reduce-arity procedure-reduce-arity-mask procedure-reduce-keyword-arity procedure-reduce-keyword-arity-mask procedure-rename procedure-result-arity procedure-specialize process process* process*/ports process/ports processor-count promise/c prop:arity-string prop:arrow-contract prop:arrow-contract-get-info prop:authentic prop:blame prop:chaperone-contract prop:checked-procedure prop:contract prop:contracted prop:custom-print-quotable prop:custom-write prop:dict prop:dict/contract prop:equal+hash prop:evt prop:exn:missing-module prop:exn:srclocs prop:expansion-contexts prop:flat-contract prop:impersonator-of prop:input-port prop:liberal-define-context prop:object-name prop:orc-contract prop:orc-contract-get-subcontracts prop:output-port prop:place-location prop:procedure prop:recursive-contract prop:recursive-contract-unroll prop:rename-transformer prop:sequence prop:set!-transformer prop:stream property/c pseudo-random-generator->vector put-preferences putenv", builtinsP);

      split("quotient quotient/remainder", builtinsQ);

      split("radians->degrees raise raise-argument-error raise-arguments-error raise-arity-error raise-arity-mask-error raise-blame-error raise-contract-error raise-mismatch-error raise-not-cons-blame-error raise-range-error raise-result-arity-error raise-result-error raise-syntax-error raise-type-error raise-user-error random random-seed range rationalize read read-accept-bar-quote read-accept-box read-accept-compiled read-accept-dot read-accept-graph read-accept-infix-dot read-accept-lang read-accept-quasiquote read-accept-reader read-byte read-byte-or-special read-bytes read-bytes! read-bytes!-evt read-bytes-avail! read-bytes-avail!* read-bytes-avail!-evt read-bytes-avail!/enable-break read-bytes-evt read-bytes-line read-bytes-line-evt read-case-sensitive read-cdot read-char read-char-or-special read-curly-brace-as-paren read-curly-brace-with-tag read-decimal-as-inexact read-eval-print-loop read-language read-line read-line-evt read-on-demand-source read-single-flonum read-square-bracket-as-paren read-square-bracket-with-tag read-string read-string! read-string!-evt read-string-evt read-syntax read-syntax/recursive read/recursive readtable-mapping real->decimal-string real->double-flonum real->floating-point-bytes real->single-flonum real-in real-part reencode-input-port reencode-output-port regexp regexp-match regexp-match* regexp-match-evt regexp-match-peek regexp-match-peek-immediate regexp-match-peek-positions regexp-match-peek-positions* regexp-match-peek-positions-immediate regexp-match-peek-positions-immediate/end regexp-match-peek-positions/end regexp-match-positions regexp-match-positions* regexp-match-positions/end regexp-match/end regexp-max-lookbehind regexp-quote regexp-replace regexp-replace* regexp-replace-quote regexp-replaces regexp-split regexp-try-match relocate-input-port relocate-output-port remainder remf remf* remove remove* remove-duplicates remq remq* remv remv* rename-contract rename-file-or-directory rename-transformer-target replace-evt reroot-path resolve-path resolved-module-path-name rest reverse round", builtinsR);

      split("second seconds->date semaphore-peek-evt semaphore-post semaphore-wait semaphore-wait/enable-break sequence->list sequence->stream sequence-add-between sequence-andmap sequence-append sequence-count sequence-filter sequence-fold sequence-for-each sequence-generate sequence-generate* sequence-length sequence-map sequence-ormap sequence-ref sequence-tail sequence/c set set!-transformer-procedure set->list set->stream set-add set-add! set-box! set-box*! set-clear set-clear! set-copy set-copy-clear set-count set-first set-for-each set-implements/c set-intersect set-intersect! set-map set-mcar! set-mcdr! set-phantom-bytes! set-port-next-location! set-remove set-remove! set-rest set-subtract set-subtract! set-symmetric-difference set-symmetric-difference! set-union set-union! set/c seteq seteqv seventh sgn sha1-bytes sha224-bytes sha256-bytes shared-bytes shell-execute shrink-path-wrt shuffle simple-form-path simplify-path sin sinh sixth sleep some-system-path->string sort special-comment-value special-filter-input-port split-at split-at-right split-common-prefix split-path splitf-at splitf-at-right sqr sqrt srcloc srcloc->string srcloc-column srcloc-line srcloc-position srcloc-source srcloc-span stop-after stop-before stream->list stream-add-between stream-andmap stream-append stream-count stream-filter stream-first stream-fold stream-for-each stream-length stream-map stream-ormap stream-ref stream-rest stream-tail stream-take stream/c string string->bytes/latin-1 string->bytes/locale string->bytes/utf-8 string->immutable-string string->keyword string->list string->number string->path string->path-element string->some-system-path string->symbol string->uninterned-symbol string->unreadable-symbol string-append string-append* string-append-immutable string-copy string-copy! string-downcase string-fill! string-foldcase string-join string-len/c string-length string-locale-downcase string-locale-upcase string-normalize-nfc string-normalize-nfd string-normalize-nfkc string-normalize-nfkd string-normalize-spaces string-ref string-replace string-set! string-split string-titlecase string-trim string-upcase string-utf-8-length struct->vector struct-info struct-type-info struct-type-make-constructor struct-type-make-predicate struct-type-property/c struct:arity-at-least struct:arrow-contract-info struct:date struct:date* struct:exn struct:exn:break struct:exn:break:hang-up struct:exn:break:terminate struct:exn:fail struct:exn:fail:contract struct:exn:fail:contract:arity struct:exn:fail:contract:blame struct:exn:fail:contract:continuation struct:exn:fail:contract:divide-by-zero struct:exn:fail:contract:non-fixnum-result struct:exn:fail:contract:variable struct:exn:fail:filesystem struct:exn:fail:filesystem:errno struct:exn:fail:filesystem:exists struct:exn:fail:filesystem:missing-module struct:exn:fail:filesystem:version struct:exn:fail:network struct:exn:fail:network:errno struct:exn:fail:object struct:exn:fail:out-of-memory struct:exn:fail:read struct:exn:fail:read:eof struct:exn:fail:read:non-char struct:exn:fail:syntax struct:exn:fail:syntax:missing-module struct:exn:fail:syntax:unbound struct:exn:fail:unsupported struct:exn:fail:user struct:srcloc sub1 subbytes subprocess subprocess-group-enabled subprocess-kill subprocess-pid subprocess-status subprocess-wait substring suggest/c symbol->string symbols sync sync/enable-break sync/timeout sync/timeout/enable-break syntax->datum syntax->list syntax-arm syntax-binding-set syntax-binding-set->syntax syntax-binding-set-extend syntax-column syntax-debug-info syntax-disarm syntax-e syntax-line syntax-local-bind-syntaxes syntax-local-certifier syntax-local-context syntax-local-expand-expression syntax-local-get-shadower syntax-local-identifier-as-binding syntax-local-introduce syntax-local-lift-context syntax-local-lift-expression syntax-local-lift-module syntax-local-lift-module-end-declaration syntax-local-lift-provide syntax-local-lift-require syntax-local-lift-values-expression syntax-local-make-definition-context syntax-local-make-delta-introducer syntax-local-module-defined-identifiers syntax-local-module-exports syntax-local-module-required-identifiers syntax-local-name syntax-local-phase-level syntax-local-submodules syntax-local-value syntax-local-value/immediate syntax-position syntax-property syntax-property-remove syntax-property-symbol-keys syntax-protect syntax-rearm syntax-recertify syntax-shift-phase-level syntax-source syntax-source-module syntax-span syntax-taint syntax-track-origin syntax/c system system* system*/exit-code system-idle-evt system-language+country system-library-subpath system-path-convention-type system-type system/exit-code", builtinsS);

      split("take take-common-prefix take-right takef takef-right tan tanh tcp-abandon-port tcp-accept tcp-accept-evt tcp-accept/enable-break tcp-addresses tcp-close tcp-connect tcp-connect/enable-break tcp-listen tentative-pretty-print-port-cancel tentative-pretty-print-port-transfer tenth the-unsupplied-arg third thread thread-cell-ref thread-cell-set! thread-dead-evt thread-receive thread-receive-evt thread-resume thread-resume-evt thread-rewind-receive thread-send thread-suspend thread-suspend-evt thread-try-receive thread-wait thread/suspend-to-kill time-apply touch transplant-input-port transplant-output-port true truncate", builtinsT);

      split("udp-addresses udp-bind! udp-close udp-connect! udp-multicast-interface udp-multicast-join-group! udp-multicast-leave-group! udp-multicast-set-interface! udp-multicast-set-loopback! udp-multicast-set-ttl! udp-multicast-ttl udp-open-socket udp-receive! udp-receive!* udp-receive!-evt udp-receive!/enable-break udp-receive-ready-evt udp-send udp-send* udp-send-evt udp-send-ready-evt udp-send-to udp-send-to* udp-send-to-evt udp-send-to/enable-break udp-send/enable-break udp-set-receive-buffer-size! udp-set-ttl! udp-ttl unbox unbox* uncaught-exception-handler unquoted-printing-string unquoted-printing-string-value unspecified-dom use-collection-link-paths use-compiled-file-check use-compiled-file-paths use-user-specific-search-paths user-execute-bit user-read-bit user-write-bit", builtinsU);

      split("value-blame value-contract values variable-reference->empty-namespace variable-reference->module-base-phase variable-reference->module-declaration-inspector variable-reference->module-path-index variable-reference->module-source variable-reference->namespace variable-reference->phase variable-reference->resolved-module-path vector vector*-length vector*-ref vector*-set! vector->immutable-vector vector->list vector->pseudo-random-generator vector->pseudo-random-generator! vector->values vector-append vector-argmax vector-argmin vector-cas! vector-copy vector-copy! vector-count vector-drop vector-drop-right vector-fill! vector-filter vector-filter-not vector-immutable vector-immutable/c vector-immutableof vector-length vector-map vector-map! vector-member vector-memq vector-memv vector-ref vector-set! vector-set*! vector-set-performance-stats! vector-sort vector-sort! vector-split-at vector-split-at-right vector-take vector-take-right vector/c vectorof version", builtinsV);

      split("weak-box-value weak-set weak-seteq weak-seteqv will-execute will-register will-try-execute with-input-from-bytes with-input-from-file with-input-from-string with-output-to-bytes with-output-to-file with-output-to-string would-be-future wrap-evt write write-byte write-bytes write-bytes-avail write-bytes-avail* write-bytes-avail-evt write-bytes-avail/enable-break write-char write-special write-special-avail* write-special-evt write-string write-to-file writeln", builtinsW);

      split("xor", builtinsXYZ);

      non_word_chars="['\"\\s\\(\\)\\[\\]\\{\\};\\|]";

      normal_identifiers="-!$%&\\*\\+\\./:<=>\\?@\\^_~a-zA-Z0-9";
      identifier_chars="[" normal_identifiers "][" normal_identifiers ",#]*";
    }

    function kak_escape(s) { gsub(/'/, "''", s); return "'" s "'"; }

    function add_highlighter(regex, highlight) { printf("add-highlighter -override shared/racket/code/ regex %s %s\n", kak_escape(regex), highlight); }

    function quoted_join(words, quoted, first) {
      first=1
      for (i in words) {
        if (!first) { quoted=quoted "|"; }
        quoted=quoted "\\Q" words[i] "\\E";
        first=0;
      }
      return quoted;
    }

    # As at 24/09/2020
    # scheme.kak uses regex = negative-lookbehind https://regex101.com/r/JWkqQg/1
    # current cheaper regex = https://regex101.com/r/ZChyAt/1
    function add_word_highlighter(words, face, regex) {
      regex = non_word_chars "(" quoted_join(words) ")" non_word_chars;
      add_highlighter(regex, "1:" face);
    }

    function print_words(words) { for (i in words) { printf(" %s", words[i]); } }

    BEGIN {
      printf("declare-option str-list racket_static_words ");
      print_words(keywords);

      print_words(builtinsA);
      print_words(builtinsB);
      print_words(builtinsC);
      print_words(builtinsD);
      print_words(builtinsE);
      print_words(builtinsF);
      print_words(builtinsG);
      print_words(builtinsH);
      print_words(builtinsI);
      print_words(builtinsK);
      print_words(builtinsL);
      print_words(builtinsM);
      print_words(builtinsN);
      print_words(builtinsO);
      print_words(builtinsP);
      print_words(builtinsQ);
      print_words(builtinsR);
      print_words(builtinsS);
      print_words(builtinsT);
      print_words(builtinsW);
      print_words(builtinsXYZ);

      print_words(predicatesA);
      print_words(predicatesB);
      print_words(predicatesC);
      print_words(predicatesD);
      print_words(predicatesE);
      print_words(predicatesF);
      print_words(predicatesG);
      print_words(predicatesH);
      print_words(predicatesI);
      print_words(predicatesK);
      print_words(predicatesL);
      print_words(predicatesM);
      print_words(predicatesN);
      print_words(predicatesO);
      print_words(predicatesP);
      print_words(predicatesQ);
      print_words(predicatesR);
      print_words(predicatesS);
      print_words(predicatesT);
      print_words(predicatesW);
      print_words(predicatesXYZ);

      printf("\n");

      add_word_highlighter(operators, "operator");
      add_word_highlighter(keywords, "keyword");

      add_word_highlighter(builtins, "function");
      add_word_highlighter(builtinsA, "function");
      add_word_highlighter(builtinsB, "function");
      add_word_highlighter(builtinsC, "function");
      add_word_highlighter(builtinsD, "function");
      add_word_highlighter(builtinsE, "function");
      add_word_highlighter(builtinsF, "function");
      add_word_highlighter(builtinsG, "function");
      add_word_highlighter(builtinsH, "function");
      add_word_highlighter(builtinsI, "function");
      add_word_highlighter(builtinsK, "function");
      add_word_highlighter(builtinsL, "function");
      add_word_highlighter(builtinsM, "function");
      add_word_highlighter(builtinsN, "function");
      add_word_highlighter(builtinsO, "function");
      add_word_highlighter(builtinsP, "function");
      add_word_highlighter(builtinsQ, "function");
      add_word_highlighter(builtinsR, "function");
      add_word_highlighter(builtinsS, "function");
      add_word_highlighter(builtinsT, "function");
      add_word_highlighter(builtinsW, "function");
      add_word_highlighter(builtinsXYZ, "function");

      add_word_highlighter(predicates, "value");
      add_word_highlighter(predicatesA, "value");
      add_word_highlighter(predicatesB, "value");
      add_word_highlighter(predicatesC, "value");
      add_word_highlighter(predicatesD, "value");
      add_word_highlighter(predicatesE, "value");
      add_word_highlighter(predicatesF, "value");
      add_word_highlighter(predicatesG, "value");
      add_word_highlighter(predicatesH, "value");
      add_word_highlighter(predicatesI, "value");
      add_word_highlighter(predicatesK, "value");
      add_word_highlighter(predicatesL, "value");
      add_word_highlighter(predicatesM, "value");
      add_word_highlighter(predicatesN, "value");
      add_word_highlighter(predicatesO, "value");
      add_word_highlighter(predicatesP, "value");
      add_word_highlighter(predicatesQ, "value");
      add_word_highlighter(predicatesR, "value");
      add_word_highlighter(predicatesS, "value");
      add_word_highlighter(predicatesT, "value");
      add_word_highlighter(predicatesW, "value");
      add_word_highlighter(predicatesXYZ, "value");

      add_highlighter(non_word_chars "+('" identifier_chars ")", "1:attribute");
      add_highlighter("\\(define\\W+\\((" identifier_chars ")", "1:attribute");
      add_highlighter("\\(define\\W+(" identifier_chars ")\\W+\\(lambda", "1:attribute");
    }
EOF
}
# --------------------------------------------------------------------------------------------------- #
§

# References
# ‾‾‾‾‾‾‾‾‾‾
# Racket 2020, The Racket Reference, v.7.8, viewed 17 September 2020, https://docs.racket-lang.org/reference/index.html
# soegaard/racket-highlight-for-github 2014, generate-keywords.rkt & generate-regular-expressions.rkt, viewed 17 September 2020, https://github.com/soegaard/racket-highlight-for-github
# mawww/kakoune 2020, scheme.kak, viewed 17 September 2020, https://github.com/mawww/kakoune/blob/master/rc/filetype/scheme.kak
# mawww/kakoune 2020, lisp.kak, viewed 28 September 2020, https://github.com/mawww/kakoune/blob/master/rc/filetype/lisp.kak
