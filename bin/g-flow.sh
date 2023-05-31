#!/bin/bash

#############################################################
#                                                           #
# g-flow - A commplete and practical Gitflow implementation #
# https://github.com/galvao-eti/g-flow                      #
#                                                           #
#############################################################

# Tests for the presence of a .git folder to infer if this is in fact a git project folder

if [ ! -d ".git" ]; then
    echo -n "Error: This folder doesn't seem to be the root of a git project."
    exit 1
fi

trim() {
    local ARG="$(echo -e "${1}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    echo "$ARG"
}

# Initial (default) configuration

declare -A CONFIG=(
    [INIT_VERSION]="0.1.0"
    [EPIC]="epic"
    [FEAT]="feat"
    [FIX]="fix"
    [HOTFIX]="hfix"
    [PROD_BRANCH]="main"
    [HMG_BRANCH]="homolog"
    [DEV_BRANCH]="dev"
    [REMOTE]="origin"
)

USAGE=$'
g-flow - A complete and practical Gitflow implementation
https://github.com/galvao-eti/g-flow

SYNOPSIS:
g-flow.sh COMMAND branch_name [SOURCE_BRANCH]

COMMANDS (unless otherwise overriden by a .g-flowrc file)
    epic
        Creates an epic branch
    feat
        Creates a feature branch
    fix
        Creates a fix branch
    hfix
        Creates a hotfix branch
'

# If no arguments were passed, shows the USAGE and exits

if [ "$#" -eq 0 ]; then
    echo "$USAGE"
    exit 0
fi

# If there's a .g-flowrc file present, override the configuration keys present in this file

if [ -e ".g-flowrc" ]; then
    while IFS='=' read -ra rcConfig; do
        if [[ $rcConfig != "" ]] && [[ $rcConfig != ^"#" ]] && [[ ${CONFIG[${rcConfig[0]}]+1} ]]; then
            CONFIG[${rcConfig[0]}]=${rcConfig[1]}
        fi
    done <.g-flowrc
fi

# Define the Version numbers of the project through a VERSION file or the INIT_VERSION config key

if [ -e "VESION" ]; then
    IFS='.' read -ra versionNums <VERSION
else
    IFS='.' read -ra versionNums <<<${CONFIG[INIT_VERSION]}
fi

MAJOR=${versionNums[0]}
MINOR=${versionNums[1]}
PATCH=${versionNums[2]}

VALID_TYPES=(${CONFIG[EPIC]} ${CONFIG[FEAT]} ${CONFIG[FIX]} ${CONFIG[HOTFIX]})
PREDEF_MAIN=${CONFIG[PROD_BRANCH]}
RESULT=""

TYPE=$(trim $1)
NAME=$(trim $2)
MAIN=$(trim $3)

# Tests if the branch type was supplied

if [ "$TYPE" = "" ]; then
    echo "Error: branch_type is required"
    echo "$USAGE"
    exit 1
fi

# Tests if the branch type is valid

if  ! echo ${VALID_TYPES[@]} | grep -q -w "$TYPE"; then
     echo "$USAGE"
     echo "Error: Invalid branch_type ($TYPE). Accepted types:" ${VALID_TYPES[*]}
     exit 1
fi

# Tests if the branch name was supplied

if [ "$NAME" = "" ]; then
    echo "$USAGE"
    echo "Error: branch_name is required"
    exit 1
fi

# Tests if the main (prod) branch was informed, emits a warning if the source branch is different then prod

if [ "$MAIN" = "" ]; then
    MAIN=$PREDEF_MAIN
elif [ "$MAIN" != "$PREDEF_MAIN" ]; then
    echo "WARNING: Your branch will be created from $MAIN, which is different from $PREDEF_MAIN."
    echo -n "Are you SURE you want to continue ( y / N ) ? "
    read CONFIRMATION

    if [ "$CONFIRMATION" != "y" ]; then
        echo "Aborted."
        exit 0
    fi
fi

# Tries to execute each action, building the summary, fails with error at each step

{
    git checkout ${MAIN} && RESULT+="Checkout em $MAIN;"$'\n'; 
} || {
    echo "Erro ao fazer o checkout da branch $MAIN" && exit 2;
}

{
    git pull && RESULT+="Branch $MAIN atualizada (pull);"$'\n';
} || {
    echo "Erro ao atualizar a branch $MAIN" && exit 2;
}

{
    git checkout -b $TYPE/$NAME && RESULT+="Branch $TYPE/$NAME criada a partir de $MAIN;"$'\n';
} || {
    echo "Erro ao criar a branch $TYPE/$NAME" && exit 2;
}

{
    git push -u origin $TYPE/$NAME && RESULT+="Branch $TYPE/$NAME sincronizada com o Github."$'\n';
} || {
    echo "Erro ao sincronizar a branch $TYPE/$NAME com o Github" && exit 2;
}

# If this point is reached means that the execution was successful, present the summary

echo $'\n'"g-flow executed sucessfully"
echo "Summary of the executed actions:"
echo $'\n'"$RESULT"
echo "Have a good one!"

exit 0