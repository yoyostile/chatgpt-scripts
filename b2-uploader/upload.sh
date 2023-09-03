#!/bin/bash
set -e
MAX_PARALLEL_UPLOADS=3
current_uploads=0

check_file_exists() {
    local PREFIX="$1"
    local FILE_SHA1="$2"

    FILES_INFO=$(curl -s -H "Authorization: $AUTHORIZATION_TOKEN" "$API_URL/b2api/v2/b2_list_file_names?bucketId=$B2_BUCKET_ID&prefix=$PREFIX")

    if [ -z "$FILES_INFO" ]; then
        echo "Failed to fetch file information."
        return 1
    fi

    EXISTING_SHA1=$(echo "$FILES_INFO" | jq -r --arg PREFIX "$PREFIX" '.files[]? | select(.fileName == $PREFIX) | .contentSha1 // empty')

    if [ -z "$EXISTING_SHA1" ]; then
        return 1
    fi

    [[ "$EXISTING_SHA1" == "$FILE_SHA1" ]]
}


upload_file() {
    local FILE_PATH="$1"
    local FILE_NAME="random/$2"

    AUTH_RESPONSE=$(curl -s https://api.backblazeb2.com/b2api/v2/b2_authorize_account -u "$B2_ACCOUNT_ID":"$B2_ACCOUNT_KEY")
    AUTHORIZATION_TOKEN=$(echo "$AUTH_RESPONSE" | jq -r '.authorizationToken')
    API_URL=$(echo "$AUTH_RESPONSE" | jq -r '.apiUrl')

    UPLOAD_DATA=$(curl -s -H "Authorization: $AUTHORIZATION_TOKEN" -d "{\"bucketId\":\"$B2_BUCKET_ID\"}" "$API_URL/b2api/v2/b2_get_upload_url")
    UPLOAD_URL=$(echo "$UPLOAD_DATA" | jq -r '.uploadUrl')
    UPLOAD_AUTHORIZATION_TOKEN=$(echo "$UPLOAD_DATA" | jq -r '.authorizationToken')

    CONTENT_SHA1=$(sha1sum "$FILE_PATH" | awk '{ print $1 }')

    if check_file_exists "$FILE_NAME" "$CONTENT_SHA1"; then
        echo "File already exists with the same SHA1. Skipping upload."
        return
    fi

    curl -s -H "Authorization: $UPLOAD_AUTHORIZATION_TOKEN" -H "X-Bz-File-Name: $FILE_NAME" -H "Content-Type: b2/x-auto" -H "X-Bz-Content-Sha1: $CONTENT_SHA1" --data-binary "@$FILE_PATH" "$UPLOAD_URL"

    echo "Uploaded: https://cdn.r4r3.me/$FILE_NAME"
}

recursive_upload() {
    local TARGET="$1"
    local PREFIX="$2"

    if [[ -d "$TARGET" ]]; then
        for item in "$TARGET"/*; do
            local new_prefix="$PREFIX/$(basename "$item")"
            recursive_upload "$item" "$new_prefix"
        done
    else
        ((current_uploads++))

        upload_file "$TARGET" "$PREFIX" &  # Starte den Upload im Hintergrund

        # Warte, wenn die maximale Anzahl paralleler Uploads erreicht ist
        if [[ $current_uploads -ge $MAX_PARALLEL_UPLOADS ]]; then
            wait  # Warte auf alle Hintergrundjobs
            current_uploads=0
        fi
    fi
}

[[ -z "$B2_BUCKET_ID" || -z "$B2_ACCOUNT_ID" || -z "$B2_ACCOUNT_KEY" ]] && { echo "Error: B2_BUCKET_ID, B2_ACCOUNT_ID or B2_ACCOUNT_KEY is not set."; exit 1; }

TARGET="$1"
PREFIX="$(basename "$TARGET")"

recursive_upload "$TARGET" "$PREFIX"
