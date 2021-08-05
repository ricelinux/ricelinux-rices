#!/bin/bash

# Dependencies:
# - toml-cli (cargo install toml-cli)

TOML="$HOME/.cargo/bin/toml"

if [ ! -f "$TOML" ]; then
    echo "You must install 'toml-cli' to be able to run this"
    exit 1
fi

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
        CONTENT+="$($TOML get $RICES/$FILE $FIELD | tr -d '"'),"
    done

    PKGS=""
    PACMAN_PKGS=$($TOML get $RICES/$FILE packages.pacman | tr -d '[]\"' | sed "s/\\,/ /g")
    AUR_PKGS=$($TOML get $RICES/$FILE packages.aur | tr -d '[]\"' | sed "s/\\,/ /g")
    
    for PACMAN_PKG in $PACMAN_PKGS; do
        PKGS="$PKGS""pacman/$PACMAN_PKG;"
    done

    for AUR_PKG in $AUR_PKGS; do
        PKGS="$PKGS""aur/$AUR_PKG;"
    done

    CONTENT+="$PKGS,"
    CONTENT+="$(sha256sum $DB | awk '{print $1}')$cr"
    echo "Done!"
done

echo -n "Writting $DB... "
echo "$CONTENT" > $DB
echo "Done!"

HASH=$(sha256sum $DB | awk '{print $1}')

echo -n "Writting $DB.sha256sum... "
echo ${HASH^^} > $DB.sha256sum
echo "Done!"
