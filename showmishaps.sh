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

    local output="$("$function" $@ 2>&1)"

    if [ -n "$output" ]; then
        everythingok=false
        cat <<EOF
<===== $name =====>

$output

EOF
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
    sed -r 's/(^.{1,'$COLUMNS'}).*/\1/'    
}

listfiles(){
    find * -maxdepth 0 -name '*.tex' -print0
}

listlogs(){
    find * -maxdepth 0 -name '*.log' -print0
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
    listfiles | xargs -0 grep -Pn '(^| )\\(ref|cite)\{' | grep -v '[^\\]&' | cuttooneline
}

alltabs(){
    listfiles | xargs -0 grep -Pn '\t' | cuttooneline
}

doublewords(){
    listfiles | xargs -0 grep -Pon '\b(\S+)(?<![0-9])\b\s+\b\1\b'
}

updateallwords(){
    ./listallwords.sh > allwords.txt
}

knownwords(){
    cat /home/e.lorenz/usr/share/words/113_elements.txt
    cat /home/e.lorenz/usr/share/words/200000_de.txt
    cat /home/e.lorenz/usr/share/words/80000_de.txt
    cat /home/e.lorenz/usr/share/words/apostrophiert.txt
    cat spelling/abbreviations.txt
    cat spelling/anglicisms.txt
    cat spelling/chemicals.txt
    cat spelling/latex.txt
    cat spelling/mywords.txt
    cat spelling/propernouns.txt
    imagerefs | sed 's/[0-9]\+//g'
}

unknownwords(){
    {
        cat allwords.txt
        knownwords | sed p
    } | sort | uniq -u
}

listunknownwords(){
    updateallwords # taken care of by crontab
    local unknown
    unknown=`unknownwords`
    [ -n "$unknown" ] && echo -e "$unknown"
}

listlonglines(){
    local maxchars=$1
    [ -z "$maxchars" ] && maxchars=300
    lines=$(
        listfiles|xargs -0n1 | while IFS= read file; do
            sed -r 's/\{[^{}]+(\{[^{}]*\}[^{}]*)*\}//g' $file | sed -e 's/\$[^$]\+\$//' | awk '{if (length > '$maxchars') print length,"'$file':"NR":",$0}' | cuttooneline
        done | sort -nr
    )
    [ -n "$lines" ] && echo -e "$lines"
}

undefinedreferences(){
    listlogs | { xargs -0 grep -Pi 'Reference.*undefined' || echo "ok"; } | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p" | sort -u
}

undefinedcitations(){
    listlogs | { xargs -0 grep -Pi 'Citation.*undefined' || echo "ok"; } | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p" | sort -u
}

multiplelabels(){
    listlogs | { xargs -0 grep -Pi 'multipl[ey]' || echo "ok"; } | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p" | sort -u
}

trailingspaces(){
    listfiles | xargs -0 grep -Pn '\s+$'
}

dotlines(){
    listfiles | xargs -0 grep -Pn '^[^%&]*(?<!engl|Kap|S|Abb|Tab|Gl|Anh|Ref|Prof|vs|Dr|z\.B|Abh|et al|unters|ca|eam|etc|[0-9]|[^A-Z][A-Z])\.(?!$|[0-9]|pdf|cpp|com|eam|\s*(\&|\\todo|%|\\\\|,|\})|Sc\.|B\.)' | grep -Pv '\\(If|State|dcauthoremail|todo)' | cuttooneline
}

asddsa(){
    listfiles | xargs -0 grep -Pin 'asd|dsa'
}

todonotes(){
    listfiles | xargs -0 grep -Pno '\\todo(\[inline\])?(\{[^}]*\})?'
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
    listfiles | xargs -0 grep -n 'ref{eq' | cuttooneline
}

#####################
# begin actual work #
#####################
{

    register "possible typos" listunknownwords
    register "LaTeX Errors" getlatexerrors
    register "word repetitions" doublewords
    register "undefined references" undefinedreferences
    register "undefined citations" undefinedcitations
    register "multiplelabels" multiplelabels
    register "citations with language tag" citationswithlanguagetag
    register "unused citations" unusedcitations
    register "long lines" listlonglines 333
    register "dots within a line" dotlines
    register "trailing spaces" trailingspaces
    register "tab stops" alltabs
    register "cites/refs with leading spaces" spacerefs
    register "ASD occurences" asddsa
    register "LaTeX Warnings" getlatexwarnings
    register "Equation References" equationreferences
    register "todo notes" todonotes
    # register "draft notes" getdrafts

    printfinalstate

} 2>&1
