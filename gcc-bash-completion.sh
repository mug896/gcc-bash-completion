_init_comp_wordbreaks()
{
    if [[ $PROMPT_COMMAND =~ ^:[^\;]+\;COMP_WORDBREAKS ]]; then
        [[ $PROMPT_COMMAND =~ ^:\ ([^;]+)\; ]]
        [[ ${BASH_REMATCH[1]} != "${COMP_WORDS[0]}" ]] && eval "${PROMPT_COMMAND%%$'\n'*}"
    fi
    if ! [[ $PROMPT_COMMAND =~ ^:[^\;]+\;COMP_WORDBREAKS ]]; then
        PROMPT_COMMAND=": ${COMP_WORDS[0]};COMP_WORDBREAKS=${COMP_WORDBREAKS@Q};\
        "$'PROMPT_COMMAND=${PROMPT_COMMAND#*$\'\\n\'}\n'$PROMPT_COMMAND
    fi
}
_gcc_bind() { bind '"\011": complete' ;}
_gcc_search()
{
    local res count opt
    words=$( <<< $words sed -E 's/^[ \t]+|[ \t]+$//g' | sort -u )
    local IFS=$'\n'; echo
    for v in $words; do
        if [[ $v == $cur ]]; then
            res+=$'\e[36m'"$v"$'\e[0m\n'
            let count++
        fi
    done 
    (( count >= LINES )) && opt="+Gg"
    less -FRSXiN $opt <<< ${res%$'\n'}
    bind -x '"\011": _gcc_bind'
} 
_gcc()
{
    # It is recommended that all completion functions start with _init_comp_wordbreaks,
    # regardless of whether you change the COMP_WORDBREAKS variable afterward.
    _init_comp_wordbreaks
    [[ $COMP_WORDBREAKS != *","* ]] && COMP_WORDBREAKS+=","

    local IFS=$' \t\n' cur cur_o prev prev_o prev2 preo preo2
    local cmd=$1 cmd2 words help args arr i v
    local comp_line2=${COMP_LINE:0:$COMP_POINT}

    cur=${COMP_WORDS[COMP_CWORD]} cur_o=$cur
    [[ ${comp_line2: -1} = " " || $COMP_WORDBREAKS == *$cur* ]] && cur=""
    prev=${COMP_WORDS[COMP_CWORD-1]} prev_o=$prev
    [[ $prev == [,=] ]] && prev=${COMP_WORDS[COMP_CWORD-2]}
    if (( COMP_CWORD > 4 )); then
        [[ $cur_o == [,=] ]] && prev2=${COMP_WORDS[COMP_CWORD-3]} || prev2=${COMP_WORDS[COMP_CWORD-4]}
    fi
    eval arr=( $comp_line2 ) 2> /dev/null
    if [[ ${arr[ ${#arr[@]} - 1 ]} == -* && -n $cur_o ]]; then
        preo=${arr[ ${#arr[@]} - 1 ]%%[^[:alnum:]_-]*}
        [[ ($preo == ${comp_line2##*[ ]}) && ($preo == $cur_o) ]] && preo=""
    fi
    for ((i = COMP_CWORD - 1; i > 0; i--)); do
        [[ ${COMP_WORDS[i]} == -* ]] && { preo2=${COMP_WORDS[i]}; break ;}
    done

    if [[ $preo == @(-Wl|-Wa) || $prev == @(-Xlinker|-Xassembler) ]]; then
        help=$( $cmd -v --help 2> /dev/null )
        [[ $preo == -Wl || $prev == -Xlinker ]] && args="ld" || args="as"
        local filter_str='/^Usage: .*'"$args"' /,/^Report bugs to/' 

        if [[ $cur == -* || $prev == @(-Xlinker|-Xassembler) ]]; then
            words=$(<<< $help sed -En "$filter_str"'{
            s/^\s{,10}((-[^ ,=]+([ =][^ ,]+)?)(, *-[^ ,=]+([ =][^ ,]+)?)*)(.*)/\1/g; T;
            s/((^|[^[:alnum:]])-[][[:alnum:]_+-]+=?)|./\1 /g; 
            s/[,/ ]+/\n/g; s/\[=$/=/Mg; s/\[[[:alnum:]-]+$//Mg;  
            :X h; tR1; :R1 s/([^=]+)\[(\|?(\w+-?))+](.*)/\1\3\4/; p; T; 
            g; s/\|?\w+-?]/]/; tR2 :R2 s/-\[]([[:alnum:]])/-\1/p; t; /\[]/!bX }')

            [[ $cur == *[[*?]* ]] && _gcc_search

        elif [[ $preo == -Wl && $prev == -z ]]; then
            words=$(<<< $help sed -En "$filter_str"'{ s/^\s*-z ([[:alnum:]-]+=?).*/\1/p }')
        
        elif [[ ($prev == -* && $prev != $preo) || $prev2 == -z ]]; then
            words=$(<<< $help sed -En 's/.* '"$prev"'[ =]\[([^]]+)].*/\1/; T; s/[,|]/\n/g; p; Q')
        fi

    elif [[ $preo == --help ]]; then
        help=$( $cmd -v --help 2> /dev/null )
        [[ $COMP_WORDBREAKS != *"^"* ]] && COMP_WORDBREAKS+="^"
        words=$( <<< $help sed -En '/^\s{,10}--help=/{s/--help=|[^[:alpha:]]/\n/g; p; Q}' )

    elif [[ $cur == -* || $preo == --completion ]]; then
        words=$( $cmd --completion="-" | sed -E 's/([ \t=]).*$/\1/' )
        if [[ $cur == *[[*?]* ]]; then
            _gcc_search
        elif [[ $preo == --completion && $prev != $preo ]]; then
            [[ $preo2 == $prev ]] && args="$prev=" || args="$preo2=$prev="
            words=$( $cmd --completion="$args" | sed -E 's/^'"$args"'//; s/=.*$/=/' )
        fi

    elif [[ -n $preo ]]; then
        [[ $prev == $preo ]] && args="$prev=" || args="$preo=$prev="
        words=$( $cmd --completion="$args" | sed -E 's/^'"$args"'//; s/=.*$/=/' )
    fi

    if ! declare -p COMPREPLY &> /dev/null; then
        words=$( <<< $words sed -E 's/^[ \t]+|[ \t]+$//g' )
        IFS=$'\n' COMPREPLY=($(compgen -W "$words" -- "$cur"))
    fi
    [[ ${COMPREPLY: -1} == "=" ]] && compopt -o nospace
}

words="cc gcc c++ g++ gfortran f77 f95 "
words+=$( compgen -c | grep -E '^[[:alpha:]].*-(gcc|g\+\+)(-[[:digit:].]+)?$' )
complete -o default -o bashdefault -F _gcc $words
unset -v words


