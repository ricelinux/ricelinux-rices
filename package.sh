#!/bin/bash

# Dependencies:
# - toml-cli (cargo install toml-cli)

cr=`echo $'\n.'`
cr=${cr%.}

RICES=rices
FILES=$(ls $RICES)
FIELDS=(
    theme.name
    theme.id
    theme.description
    theme.version
    window-manager.name
)
DB="rices.db"

CONTENT=""

for FILE in $FILES; do
    
    echo -n "Preparing $FILE's info... "

    for FIELD in ${FIELDS[@]}; do
        CONTENT+="$(toml get $RICES/$FILE $FIELD | tr -d '"'),"
    done

    PKGS=""
    PACMAN_PKGS=$(toml get $RICES/$FILE packages.pacman | tr -d '[]\"' | sed "s/\\,/ /g")
    AUR_PKGS=$(toml get $RICES/$FILE packages.aur | tr -d '[]\"' | sed "s/\\,/ /g")
    
    for PACMAN_PKG in $PACMAN_PKGS; do
        PKGS="$PKGS""pacman/$PACMAN_PKG;"
    done

    for AUR_PKG in $AUR_PKGS; do
        PKGS="$PKGS""pacman/$AUR_PKG;"
    done

    CONTENT+="$PKGS$cr"
    echo "Done!"
done

echo -n "Writting $DB... "
echo "$CONTENT" > $DB
echo "Done!"
echo -n "Writting $DB.sha256sum... "
sha256sum $DB | awk '{print $1}' > $DB.sha256sum
echo "Done!"
