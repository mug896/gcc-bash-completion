_init_comp_wordbreaks()
{
    if [[ $PROMPT_COMMAND == *";COMP_WORDBREAKS="* ]]; then
        [[ $PROMPT_COMMAND =~ ^:\ ([^;]+)\; ]]
        [[ ${BASH_REMATCH[1]} != "${COMP_WORDS[0]}" ]] && eval "${PROMPT_COMMAND%%$'\n'*}"
    fi
    if [[ $PROMPT_COMMAND != *";COMP_WORDBREAKS="* ]]; then
        PROMPT_COMMAND=": ${COMP_WORDS[0]};COMP_WORDBREAKS=${COMP_WORDBREAKS@Q};\
        "$'PROMPT_COMMAND=${PROMPT_COMMAND#*$\'\\n\'}\n'$PROMPT_COMMAND
    fi
}
_gcc()
{
    # It is recommended that every completion function starts with _init_comp_wordbreaks,
    # whether or not they change the COMP_WORDBREAKS variable afterward.
    _init_comp_wordbreaks
    [[ $COMP_WORDBREAKS != *","* ]] && COMP_WORDBREAKS+=","

    local IFS=$' \t\n' CUR CUR_O PREV PREV_O PREV2 PREO PREO2
    local CMD=$1 CMD2 WORDS COMP_LINE2 HELP args i v

    CUR=${COMP_WORDS[COMP_CWORD]} CUR_O=$CUR
    [[ ${COMP_LINE:COMP_POINT-1:1} = " " || $COMP_WORDBREAKS == *$CUR* ]] && CUR=""
    PREV=${COMP_WORDS[COMP_CWORD-1]} PREV_O=$PREV
    [[ $PREV == [,=] ]] && PREV=${COMP_WORDS[COMP_CWORD-2]}
    if (( COMP_CWORD > 4 )); then
        [[ $CUR_O == [,=] ]] && PREV2=${COMP_WORDS[COMP_CWORD-3]} || PREV2=${COMP_WORDS[COMP_CWORD-4]}
    fi
    COMP_LINE2=${COMP_LINE:0:$COMP_POINT}
    local i arr
    eval arr=( $COMP_LINE2 )
    for (( i = ${#arr[@]} - 1; i > 0; i-- )); do
        if [[ ${arr[i]} == -* ]]; then
            PREO=${arr[i]%%[^[:alnum:]_-]*}
            [[ ($PREO == ${COMP_LINE2##*[ ]}) && ($PREO == $CUR_O) ]] && PREO=""
            break
        fi
    done
    for ((i = COMP_CWORD - 1; i > 0; i--)); do
        [[ ${COMP_WORDS[i]} == -* ]] && { PREO2=${COMP_WORDS[i]}; break ;}
    done

    if [[ $PREO == @(-Wl|-Wa) ]]; then
        HELP=$( $CMD -v --help 2> /dev/null )
        [[ $PREO == -Wl ]] && args="ld" || args="as"
        local filter_str='/^Usage: .*'"$args"' /,/^Report bugs to/' 

        if [[ $CUR == -* ]]; then
            WORDS=$(<<< $HELP sed -En "$filter_str"'{
            s/^\s{,3}((-[^ ,=]+([ =][^ ,]+)?)(, *-[^ ,=]+([ =][^ ,]+)?)*)(.*)/\1/g; tX;
            b; :X s/((^|[^[:alnum:]])-[][[:alnum:]_+-]+=?)|./\1 /g; 
            s/[,/ ]+/\n/g; s/\[=$/=/Mg; s/\[[[:alnum:]-]+$//Mg;  
            :Y h; tR1; :R1 s/([^=]+)\[(\|?(\w+-?))+](.*)/\1\3\4/; p; tZ; b; 
            :Z g; s/\|?\w+-?]/]/; tR2 :R2 s/-\[]([[:alnum:]])/-\1/p; tE; /\[]/! bY :E }')

        elif [[ $PREO == -Wl && $PREV == -z ]]; then
            WORDS=$(<<< $HELP sed -En "$filter_str"'{ s/^\s*-z ([[:alnum:]-]+=?).*/\1/p }')
        
        elif [[ ($PREV == -* && $PREV != $PREO) || $PREV2 == -z ]]; then
            WORDS=$(<<< $HELP sed -En 's/.*'"$PREV"'[ =]\[([^]]+)].*/\1/; tX; b; :X s/\|/\n/g; p')
        fi

    elif [[ $PREO == --help ]]; then
        HELP=$( $CMD -v --help 2> /dev/null )
        [[ $COMP_WORDBREAKS != *"^"* ]] && COMP_WORDBREAKS+="^"
        WORDS=$( <<< $HELP sed -En '/^\s{,5}--help=/{s/--help=|[^[:alpha:]]/\n/g; p; Q}' )

    elif [[ $CUR == -* || $PREO == --completion ]]; then
        WORDS=$( $CMD --completion="-" | sed -E 's/([ =]).*$/\1/' )
        if [[ $CUR == *[*?[]* ]]; then
            declare -A aar; IFS=$'\n'; args=; echo
            for v in $WORDS; do 
                let aar[$v]++
                if [[ $v == $CUR && ${aar[$v]} -eq 1 ]]; then
                    args+=$'\n'$v
                    echo -e "\\e[36m$v\\e[0m"
                fi
            done >&2
            echo "[${CUR%%[[*?]*}] ~~~~~~~~~~~~~~~~~~~~~~~~~" >&2
            args+=" "
            IFS=$'\n' COMPREPLY=($(compgen -W "$args" ))

        elif [[ $PREO == --completion && $PREV != $PREO ]]; then
            [[ $PREO2 == $PREV ]] && args="$PREV=" || args="$PREO2=$PREV="
            WORDS=$( $CMD --completion="$args" | sed -E 's/^'"$args"'//; s/(=).*$/\1/' )
        fi

    elif [[ -n $PREO ]]; then
        [[ $PREV == $PREO ]] && args="$PREV=" || args="$PREO=$PREV="
        WORDS=$( $CMD --completion="$args" | sed -E 's/^'"$args"'//; s/(=).*$/\1/' )
    fi

    if [[ -z $COMPREPLY ]]; then
        WORDS=$( <<< $WORDS sed -E 's/^[[:blank:]]+|[[:blank:]]+$//g' )
        if [[ $WORDS == *" "* ]]; then
            IFS=$'\n' COMPREPLY=($(compgen -P \' -S \' -W "$WORDS" -- "$CUR"))
        else
            IFS=$'\n' COMPREPLY=($(compgen -W "$WORDS" -- "$CUR"))
        fi
    fi
    [[ ${COMPREPLY: -1} == [=,] ]] && compopt -o nospace
}

extglob_reset=$(shopt -p extglob)
shopt -s extglob
WORDS="cc gcc c++ g++ gfortran f77 f95 "
WORDS+=$( shopt -s nullglob; IFS=:
for dir in $PATH; do
    cd "$dir" && echo gcc-+([0-9]) g++-+([0-9]) *-gcc *-g++ *-gcc-+([0-9]) *-g++-+([0-9])
done 
)
complete -o default -o bashdefault -F _gcc $WORDS
$extglob_reset
unset -v extglob_reset WORDS


