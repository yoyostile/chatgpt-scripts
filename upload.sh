#!/bin/bash
set -e

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
        upload_file "$TARGET" "$PREFIX"
    fi
}

[[ -z "$B2_BUCKET_ID" || -z "$B2_ACCOUNT_ID" || -z "$B2_ACCOUNT_KEY" ]] && { echo "Error: B2_BUCKET_ID, B2_ACCOUNT_ID or B2_ACCOUNT_KEY is not set."; exit 1; }

TARGET="$1"
PREFIX="$(basename "$TARGET")"

recursive_upload "$TARGET" "$PREFIX"
