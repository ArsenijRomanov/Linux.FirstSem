#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Usage: $0 <directory>"
	exit 1
fi

DIRECTORY="$1"

if [ ! -d "$DIRECTORY" ]; then
	echo "$DIRECTORY is not a valid directory."
	exit 1
fi

DIRECTORY=$(echo "$DIRECTORY" | sed 's:/*$::')

GENERATED_SCRIPT="rename_to_uppercase.sh"

echo "#!/bin/bash" >"$GENERATED_SCRIPT"

for FILE in "$DIRECTORY"/*; do
	if [ -f "$FILE" ]; then
		BASENAME=$(basename "$FILE")
		NAME="${BASENAME%.*}"
		EXT="${BASENAME##*.}"

		NEW_NAME=$(echo "$NAME" | tr 'a-z' 'A-Z')

		NEW_FILE="$DIRECTORY/$NEW_NAME.$EXT"

		echo "mv \"$FILE\" \"$NEW_FILE\"" >>"$GENERATED_SCRIPT"
	fi
done

chmod +x "$GENERATED_SCRIPT"

echo "$GENERATED_SCRIPT generated."
