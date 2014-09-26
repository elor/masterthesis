#!/bin/bash
#
# lists all words of every tex file in this folder

{
    #######################
    # extract every word  #
    ######################################################################
    # 1. remove LaTeX comments                                           #
    # 2. remove LaTeX commands                                           #
    # 3. remove LaTeX command options                                    #
    # 4. remove LaTeX command parameters, if they are no text (captions) #
    # 5. remove '\-' hyphenation marks                                   #
    # 6. remove everything that's no word character                      #
    # 7. remove punctuation marks                                        #
    # 8. remove hyphens                                                  #
    ######################################################################
    sed -e 's/%.*$//' -e 's/\\[a-zA-Z]\+/ /g' -e 's/\[[^]]*\]/ /g' -e 's/[{][a-z_0-9:-]*[}]/ /g' -e 's/\\-//g' -e 's/[^a-zA-Z_-:]/ /g' -e 's/\([a-zA-Z-]\)[,.?:]\(\s\|$\)/\1 /g' -e 's/-/ /g' *.tex
} | {
    #####################
    # one word per line #
    #####################
    xargs -n1 | sort -u
} | {
    #########################################
    # remove case-insensitive-similar words #
    #########################################
    uniq -i
} | {
    #####################################################
    # remove lines up to one character or an underscore #
    #####################################################
    grep -Pv '^.?$|^_|_$'
} | {
    ###############################################
    # strip different, but similar german endings #
    ###############################################
    xargs | sed -r 's/((\S+?)[et]?[nrs]?)( \2[et]?[nrs]?)+(\s|$)/\1 \4/g' | xargs -n1
}
