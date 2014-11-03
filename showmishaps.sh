#!/bin/bash
#
# shows all minor latex mishaps for all .tex files

cuttooneline(){
    [ -z "$COLUMNS" ] && local COLUMNS=80
    sed -r 's/(^.{1,'$COLUMNS'}).*/\1/'    
}

listfiles(){
    find * -name '*.tex' -print0
}

listlogs(){
    find * -name '*.log' -print0
}

imagerefs(){
    find img/ -name '*.png' -exec basename {} .png \; -o -name '*.pdf' -exec basename {} .pdf \; -o -name '*.eps' -exec basename {} .eps \; | sort -u
}

usedcitations(){
    sed -n 's/\\citation{\([^}]*\)}/\1/gp' *.aux | sort -u
}

availablecitations(){
    sed -n 's/@[a-zA-Z-]*{\([^,]*\),.*/\1/p' *.bib | sort -u
}

citationswithlanguagetag(){
    sed ':a;N;$!ba;s/,\s*\n/,/g' *.bib  | grep language | sed -n 's/@[a-zA-Z-]*{\([^,]*\),.*/\1/p'
}

unusedcitations(){
    local retval
    retval=$({ availablecitations; usedcitations|sed p; } | sort | uniq -u)
    [ -n "$retval" ] && echo -e "$retval"
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
            sed -r 's/\{[^{}]+(\{[^{}]*\}[^{}]*)*\}//g' $file | sed 's/\$[^$]\+\$//' | awk '{if (length > '$maxchars') print length,"'$file':"NR":",$0}' | cuttooneline
        done | sort -nr
    )
    [ -n "$lines" ] && echo -e "$lines"
}

#####################
# begin actual work #
#####################
{
    findmatch='listfiles | xargs grep -n'

    ##############
    # list typos #
    ##############

    echo "<= possible typos =>"
    echo
    listunknownwords || echo "ok"
    echo

    ###########################################
    # undefined or multiple labels/references #
    ###########################################

    echo "<= undefined references and multiple labels =>"
    echo
    listlogs | { xargs -0 grep -Pi 'multipl[ey]|undefined' || echo "ok"; } | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p"
    echo

    ####################
    # unused citations #
    ####################

    echo "<= unused citations =>"
    echo
    unusedcitations || echo "ok"
    echo

    ###############################
    # citations with language tag #
    ###############################

    echo "<= citations with language tag =>"
    echo
    citationswithlanguagetag || echo "ok"
    echo

    ##############
    # long lines #
    ##############

    echo "<= lines > 333 chars =>"
    echo
    listlonglines 333 || echo "ok"
    echo

    ####################
    # trailing  spaces #
    ####################

    echo "<= trailing spaces =>"
    echo
    listfiles | xargs -0 grep -Pn '\s+$' || echo "ok"
    echo

    ######################
    # dots within a line #
    ######################

    echo "<= dots within lines (multiple sentences) =>"
    echo
    { listfiles | xargs -0 grep -Pn '^[^%&]*(?<!engl|Kap|S|Abb|Tab|Gl|Anh|Ref|Prof|vs|Dr|z\.B|et al|unters|ca|eam|[0-9])\.(?!$|[0-9]|pdf|cpp|com|eam|\s*(\&|\\todo|%|\\\\|,|\})|Sc\.|B\.)' | grep -Pv '\\(If|State)|\\dcauthoremail|Stefan E\. Schulz' || echo "ok"; } | cuttooneline
    echo

    ###################################
    # search for asd and its variants #
    ###################################

    echo "<= ASD occurences =>"
    echo
    listfiles | { xargs -0 grep -Pin 'asd|dsa' || echo "ok"; }
    echo

    ##############
    # todo notes #
    ##############

    echo "<= todos =>"
    echo
    listfiles | { xargs -0 grep -Pno '\\todo(\[inline\])?(\{[^}]*\})?'; }
    echo

} 2>&1
