#!/bin/bash
#
# shows all minor latex mishaps for all .tex files

#############################
# functions and definitions #
#############################

everythingok=true

register(){
    local name="$1"
    shift
    local function="$1"
    shift

    [ -z "$name" ] && { echo "register(): name not set">&2; return 1; }
    [ -z "$function" ] && { echo "register(): function not set">&2; return 1; }

    local output="$("$function" $@ 2>&1 | cuttooneline)"

    if [ -n "$output" ]; then
        everythingok=false
        cat <<EOF | tr $'\t' t
<===== $name =====>

$output

EOF
    # else
    #     echo "<===== $name =====>"

    fi
}

printfinalstate(){
    if $everythingok; then
        cat <<EOF

Congratulations! No mishaps found!

EOF
    fi
}

compilationfinished(){
    [ "$(date --reference masterthesis.pdf +%s 2>/dev/null)" == "$(date --reference masterthesis.pdf +%s 2>/dev/null)" ]
}

cuttooneline(){
    [ -z "$COLUMNS" ] && local COLUMNS=80
    sed -r 's/(^.{1,'$((COLUMNS-1))'}).*/\1/'    
}

listfiles(){
    if [ -z "$filebuffer" ]; then
        filebuffer="$(find `./texorder.sh` -print0 | xxd -p | tr -d '\n')"
    #    find * -maxdepth 0 -name '*.tex' -print0
    fi

    echo -ne "$filebuffer" | xxd -r -p
}

listlogs(){
    if [ -z "$logbuffer" ]; then
        logbuffer="$(find * -maxdepth 0 -name '*.log' -print0 | xxd -p | tr -d '\n')"
    #    find * -maxdepth 0 -name '*.tex' -print0
    fi

    echo -ne "$logbuffer" | xxd -r -p
}

imagerefs(){
    find img/ -name '*.png' -exec basename {} .png \; -o -name '*.pdf' -exec basename {} .pdf \; -o -name '*.eps' -exec basename {} .eps \; | sort -u
}

usedcitations(){
    sed -n 's/\\citation{\([^},]\+\(,[^},]\+\)*\)}/\1/gp' *.aux | sed 's/,/\n/g' | sort -u
}

availablecitations(){
    sed -n 's/@[a-zA-Z-]*{\([^,]*\),.*/\1/p' *.bib | sort -u
}

citationswithlanguagetag(){
    local lines
    lines=$(sed ':a;N;$!ba;s/,\s*\n/,/g' *.bib  | grep 'language\s*=' | sed -n 's/@[a-zA-Z-]*{\([^,]*\),.*/\1/p')
    [ -n "$lines" ] && echo -e "$lines"
}

unusedcitations(){
    compilationfinished || { echo "latex compilation in progress"; return; }
    local retval
    retval=$({ availablecitations; usedcitations|sed p; } | sort | uniq -u)
    [ -n "$retval" ] && echo -e "$retval"
}

spacerefs(){
    listfiles | xargs -0 grep -Pn '(^| )\\(ref|cite)\{' | grep -v '[^\\]&'
}

alltabs(){
    listfiles | xargs -0 grep -Pn '\t'
}

doublewords(){
    listfiles | xargs -0 grep -Poin '\b(?<![öäüß])(\S+)(?<![0-9])\b\s+\b\1\b'
}

updateallwords(){
    ./listallwords.sh > allwords.txt
}

printmissingwords(){
    file="$1"

    awk '{ if (FNR==NR) { main[$0]=1 } else if (main[$0] == 0) { print $0 }}' "$file" /dev/stdin

}

unknownwords(){
    cat allwords.txt | grep -v _ | printmissingwords /home/e.lorenz/usr/share/words/113_elements.txt \
        | printmissingwords /home/e.lorenz/usr/share/words/200000_de.txt \
        | printmissingwords /home/e.lorenz/usr/share/words/80000_de.txt \
        | printmissingwords /home/e.lorenz/usr/share/words/apostrophiert.txt \
        | printmissingwords spelling/abbreviations.txt \
        | printmissingwords spelling/anglicisms.txt \
        | printmissingwords spelling/chemicals.txt \
        | printmissingwords spelling/latex.txt \
        | printmissingwords spelling/mywords.txt \
        | printmissingwords spelling/propernouns.txt
    #    imagerefs | sed 's/[0-9]\+//g'
}

listunknownwords(){
    updateallwords
    local unknown
    unknown=`unknownwords`
    [ -n "$unknown" ] && echo -e "$unknown"
}

listlonglines(){
    local maxchars=$1
    [ -z "$maxchars" ] && maxchars=300
    lines=$(
        listfiles | xargs -0n1 | while IFS= read file; do
            sed -r 's/\{[^{}]+(\{[^{}]*\}[^{}]*)*\}//g' $file | sed -e 's/\$[^$]\+\$//' | awk '{if (length > '$maxchars') print length,"'$file':"NR":",$0}'
        done | sort -nr
    )
    [ -n "$lines" ] && echo -e "$lines"
}

undefinedreferences(){
    listlogs | xargs -0 grep -Pi 'Reference.*undefined' | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p" | sort -u
}

undefinedcitations(){
    listlogs | xargs -0 grep -Pi 'Citation.*undefined' | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p" | sort -u
}

multiplelabels(){
    listlogs | xargs -0 grep -Pi 'multipl[ey]' | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p" | sort -u
}

trailingspaces(){
    listfiles | xargs -0 grep -Pn '\s+$' 
}

dotlines(){
    listfiles | xargs -0 grep -Pn '^[^%&]*(?<!engl|Kap|S|Abb|Tab|Gl|Anh|Ref|Prof|vs|Dr|z\.B|Abh|et al|unters|ca|eam|etc|[0-9]|[^A-Z][A-Z])\.(?!$|[0-9]|pdf|cpp|com|eam|_|\s*(\&|\\todo|%|\\\\|,|\})|Sc\.|B\.)' | grep -Pv '\\(If|State|dcauthoremail|todo|footnote)'
}

asddsa(){
    listfiles | xargs -0 grep -Pin 'asd|dsa'
}

todonotes(){
    listfiles | xargs -0 grep -Po '\\todo(line|\[inline\])?(\{[^}]*\})?' | grep -v settings.tex
}

todocounts(){
    listfiles | xargs -0 grep -Pc '\\todo(line|\[inline\])?(\{[^}]*\})?' | grep -v settings.tex | grep -v :0 | awk -F: '{s+=$2;print $0} END {print "TOTAL",s}'
}

getdrafts(){
    listfiles | xargs -0 grep -Pn 'draft'
}

getlatexerrors(){
    listlogs | xargs -0 grep -Pi 'error' | grep -Pv '^Package: infwarerr [0-9]{4}/[0-9]{2}/[0-9]{2} v[0-9.]+ Providing'
}

getlatexwarnings(){
    listlogs | xargs -0 grep -Pi 'warning' | grep -Pv '^Package: infwarerr [0-9]{4}/[0-9]{2}/[0-9]{2} v[0-9.]+ Providing' | grep -v 'pdflatex (file .*\.pdf): PDF'
}

equationreferences(){
    listfiles | xargs -0 grep -n 'ref{eq'
}

doublespaces(){
    listfiles | xargs -0 grep -Poin '\S*[^%& ~}]\s\s+[^& ~%]\S*' | grep -v '\\\\$'
}

listabbreviations(){
#    grep -Po '[A-Z]{2,}' allwords.txt
    listfiles | xargs -0 grep -hoP '(?<!\\)\b[A-Z]{2,}s?\b' | sort -u
}

listofabbreviations(){
    grep -hoP '(?<!\\)\b[A-Z]{2,}s?\b' "$(listfiles | xargs -0 grep -l Abkürzungsverzeichnis | head -1)" 2>/dev/null | sort -u
}

# TODO use files and printmissingwords()
unexplainedabbreviations(){
    {
        listabbreviations
        listofabbreviations | sed p
    } | sort | uniq -u
}

# TODO use files and printmissingwords()
unusedabbreviations(){
    {
        listabbreviations | sed p
        listofabbreviations
    } | sort | uniq -u
}

disabledincludes(){
    listfiles | xargs -0 grep -Pon '^[^%]*%.*\\in(clude|put){[^}]+}'
}

manoccurences(){
    listfiles | xargs -0 grep -Pin '\bman\b' | grep -Pv '^[^:]+:[0-9]+:\s*%'
}

overfullboxes(){
    local num=$(listlogs | xargs -0 grep -Pi 'overfull' | wc -l)
    (( num > 0 )) && echo "$num overfull boxes left"
}

underfullboxes(){
    local num=$(listlogs | xargs -0 grep -Pi 'underfull' | wc -l)
    (( num > 0 )) && echo "$num underfull boxes left"
}

commentblocks(){
    listfiles | xargs -0 grep -n 'comment'
}

grandcanonical(){
    listfiles | xargs -0 grep -Pin 'großk'
}

#####################
# begin actual work #
#####################
{

    register "grand canonical" grandcanonical
#    register "possible typos" listunknownwords
    register "LaTeX Errors" getlatexerrors
    register "word repetitions" doublewords
    register "undefined references" undefinedreferences
    register "undefined citations" undefinedcitations
    register "unexplained abbreviations" unexplainedabbreviations
    register "multiplelabels" multiplelabels
    register "citations with language tag" citationswithlanguagetag
    register "dots within a line" dotlines
    register "trailing spaces" trailingspaces
    register "double spaces" doublespaces
    register "tab stops" alltabs
    register "cites/refs with leading spaces" spacerefs
    register "unused citations" unusedcitations
    register "unused abbreviations" unusedabbreviations
    register "ASD occurences" asddsa
    register "disabled includes" disabledincludes
    register "LaTeX Warnings" getlatexwarnings
    register "Equation References" equationreferences
    register "Man/man occurences" manoccurences
    register "comment blocks" commentblocks
    register "todo counts" todocounts
    register "todo notes" todonotes
    register "long lines" listlonglines 333
    register "overfull boxes" overfullboxes
    register "underfull boxes" underfullboxes
    register "draft notes" getdrafts

    printfinalstate

} 2>&1
