#!/bin/bash
#
# shows all minor latex mishaps for all .tex files

listfiles(){
    find * -name '*.tex' -print0
}

listlogs(){
    find * -name '*.log' -print0
}

usedcitations(){
    sed -n 's/\\citation{\([^}]*\)}/\1/gp' *.aux | sort -u
}

availablecitations(){
    sed -n 's/@[a-zA-Z-]*{\([^,]*\),.*/\1/p' *.bib | sort -u
}

unusedcitations(){
    local retval
    retval=$({ availablecitations; usedcitations|sed p; } | sort | uniq -u)
    echo -ne "$retval"
    [ -n "$retval" ]
}

#####################
# begin actual work #
#####################
{

    findmatch='listfiles | xargs grep -n'

    ####################
    # trailing  spaces #
    ####################

    echo "<= trailing spaces =>"
    echo
    listfiles | xargs -0 grep -n '\s+$' || echo "ok"
    echo

    ######################
    # dots within a line #
    ######################

    echo "<= dots within lines (multiple sentences) =>"
    echo
    listfiles | xargs -0 grep -Pn '^[^%&]*(?<!engl|Kap|S|Abb|Tab|Gl|Anh|Ref|Prof|vs|Dr|z\.B|et al|unters|ca|eam)\.(?!$|[0-9]|pdf|cpp|com|eam|\s*(\&|\\todo|%|\\\\|,|\})|Sc\.|B\.)' | grep -Pv '\\(If|State)|\\dcauthoremail|Stefan E\. Schulz' || echo "ok"
    echo

    ####################
    # unused citations #
    ####################

    echo "<= unused citations =>"
    echo
    unusedcitations || echo "ok"
    echo

    ###########################################
    # undefined or multiple labels/references #
    ###########################################

    echo "<= undefined references and multiple labels =>"
    echo
    listlogs | { xargs -0 grep -Pi 'multipl[ey]|undefined' || echo "ok"; } | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p"
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
