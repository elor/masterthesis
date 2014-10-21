#!/bin/bash
#
# shows all minor latex mishaps for all .tex files

listfiles(){
    find * -name '*.tex'
}

listlogs(){
    find * -name '*.log'
}

findmatch='listfiles | xargs grep -n'

####################
# trailing  spaces #
####################

echo "<= trailing spaces =>"
echo
listfiles | xargs grep -n '\s+$' || echo "ok"
echo

######################
# dots within a line #
######################

echo "<= dots within lines (multiple sentences) =>"
echo
listfiles | xargs grep -Pn '^[^%&]*(?<!engl|Kap|S|Abb|Tab|Gl|Anh|Ref|Prof|vs|Dr|z\.B|et al|unters|ca|eam)\.(?!$|[0-9]|pdf|cpp|com|eam|\s*(\\todo|%|\\\\|,|\})|Sc\.|B\.)' | grep -Pv '\\(If|State)|\\dcauthoremail|Stefan E\. Schulz' || echo "ok"
echo

###########################################
# undefined or multiple labels/references #
###########################################

echo "<= undefined references and multiple labels =>"
echo
listlogs | { xargs grep -Pi 'multipl[ey]|undefined' || echo "ok";} | sed -r -n "s/^[^\`]*\`([^']+)'.*$/\1/p"
echo
