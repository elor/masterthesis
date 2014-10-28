#!/bin/bash
#
# shows all minor latex mishaps for all .tex files

{
    listfiles(){
        find * -name '*.tex' -print0
    }

    listlogs(){
        find * -name '*.log' -print0
    }

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
    listfiles | xargs -0 grep -Pn '^[^%&]*(?<!engl|Kap|S|Abb|Tab|Gl|Anh|Ref|Prof|vs|Dr|z\.B|et al|unters|ca|eam)\.(?!$|[0-9]|pdf|cpp|com|eam|\s*(\\todo|%|\\\\|,|\})|Sc\.|B\.)' | grep -Pv '\\(If|State)|\\dcauthoremail|Stefan E\. Schulz' || echo "ok"
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
