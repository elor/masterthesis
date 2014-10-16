#!/bin/bash
#
# shows all minor latex mishaps for all .tex files

listfiles(){
    find -name '*.tex'
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
{ listfiles | xargs grep -Pn '^[^%&]*(?<!engl|Kap|S|Abb|Tab|Gl|Anh|Ref|Prof|vs|Dr|E|z\.B|et al|unters|ca|eam)\.(?!$|[0-9]|pdf|com|eam|\s*(\\todo|%|\\\\|,|\})|Sc\.|B\.)' || echo "ok"; } | grep -Pv '\\(If|State)|@'

