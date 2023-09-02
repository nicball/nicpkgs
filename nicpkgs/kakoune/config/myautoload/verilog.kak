# Verilog for Kakoune

# Detection
hook global WinCreate .*\.v %{
    set-option window filetype verilog
}

# Set up comments
hook global WinSetOption filetype=verilog %{
	set-option window comment_block_begin /*
	set-option window comment_block_end */
	set-option window comment_line //
}

# Highlighting
add-highlighter shared/verilog regions
add-highlighter shared/verilog/code default-region group
add-highlighter shared/verilog/string region '"' (?<!\\)(\\\\)*" fill string
add-highlighter shared/verilog/comment_line region '//' $ fill comment
add-highlighter shared/verilog/comment region /\* \*/ fill comment

evaluate-commands %sh{
    keywords='@ assign automatic cell deassign default defparam design disable edge genvar ifnone incdir instance liblist library localparam negedge noshowcancelled parameter posedge primitive pulsestyle_ondetect pulsestyle_oneventi release scalared showcancelled specparam strength table tri tri0 tri1 triand trior use vectored wait'
    blocks='always case casex casez else endcase for forever if repeat while begin config end endconfig endfunction endgenerate endmodule endprimitive endspecify endtable endtask fork function generate initial join macromodule module specify task'
    declarations='event inout input integer output real realtime reg signed time trireg unsigned wand wor wire'
    gates='and or xor nand nor xnor buf not bufif0 notif0 bufif1 notif1 pullup pulldown pmos nmos cmos tran tranif1 tranif0'
    symbols='+ - = == != !== === ; <= ( )'
    system_tasks='display write strobe monitor monitoron monitoroff displayb writeb strobeb monitorb displayo writeo strobeo monitoro displayh writeh strobeh monitorh fopen fclose frewind fflush fseek ftell fdisplay fwrite swrite fstrobe fmonitor fread fscanf fdisplayb fwriteb swriteb fstrobeb fmonitorb fdisplayo fwriteo swriteo fstrobeo fmonitoro fdisplayh fwriteh swriteh fstrobeh fmonitorh sscanf sdf_annotate'

    join() { sep=$2; eval set -- $1; IFS="$sep"; echo "$*"; }

    # Add the language's grammar to the static completion list
    printf %s\\n "hook global WinSetOption 'filetype=verilog' %{ set-option window static_words $(join "${keywords} ${blocks} ${declarations} ${gates} ${symbols} ${system_tasks}" ' ') }"

	# Highlight keywords
    printf %s "
        add-highlighter shared/verilog/code/ regex \b($(join "${keywords}" '|'))\b 0:keyword
        add-highlighter shared/verilog/code/ regex \b($(join "${blocks}" '|'))\b 0:attribute
        add-highlighter shared/verilog/code/ regex \b($(join "${declarations}" '|'))\b 0:type
        add-highlighter shared/verilog/code/ regex \b($(join "${gates}" '|'))\b 0:builtin
        add-highlighter shared/verilog/code/ regex \b($(join "${symbols}" '|'))\b 0:operator
    "
}

add-highlighter shared/verilog/code/ regex '\$\w+' 0:function
add-highlighter shared/verilog/code/ regex '`\w+' 0:meta
add-highlighter shared/verilog/code/ regex "\d+'[bodhBODH][1234567890abcdefABCDEF]+" 0:value
add-highlighter shared/verilog/code/ regex "(?<=[^a-zA-Z_])\d+" 0:value

# Indentation

define-command -hidden verilog-indent-on-new-line %{
    evaluate-commands -no-hooks -draft -itersel %{
        # preserve previous line indent
        try %{ execute-keys -draft K <a-&> }
        # indent after start structure
        try %{ execute-keys -draft k <a-x> <a-k> ^ \h * (always|case|casex|casez|else|for|forever|if|repeat|while|begin|config|fork|function|generate|initial|join|macromodule|module|specify|task)\b|(do\h*$|(.*\h+do(\h+\|[^\n]*\|)?\h*$)) <ret> j <a-gt> }
        try %{
          # previous line is empty, next is not
          execute-keys -draft k <a-x> 2X <a-k> \A\n\n[^\n]+\n\z <ret>
          # copy indent of next line
          execute-keys -draft j <a-x> s ^\h+ <ret> y k P
        }
    }
}

# Initialization

hook global WinSetOption filetype=verilog %{
	hook window InsertChar \n -group verilog-indent verilog-indent-on-new-line
	add-highlighter window/verilog ref verilog
	hook -once -always window WinSetOption filetype=(?!verilog).* %{
    	remove-hooks window verilog-indent
    	remove-highlighter window/c
    }
}
