#!/usr/zsh
# Check if the filename parameter is provided
if [ -z "$1" ]; then
    echo "Usage: ./mapbox_map_upload.zsh <filename>"
    exit 1
fi
if [ -z "$2" ]; then
    echo "Usage: ./mapbox_map_upload.zsh <filename> <tileset> <name>"
    exit 1
fi

filename=$1
tileset=$2
name=$3


# the ENV variables should be set by mapbox_set_env.zsh script
aws s3 cp $filename s3://$BUCKET/$BUCKET_KEY --region us-east-1

export S3_UPLOAD_URL="http://$BUCKET.s3.amazonaws.com/$BUCKET_KEY"
echo "Uploading to $S3_UPLOAD_URL"

json_body='{
  "url": "'"$S3_UPLOAD_URL"'",
  "tileset": "'"$tileset"'",
  "name": "'"$name"'"
}'

curl -X POST -H "Content-Type: application/json" -H "Cache-Control: no-cache" -d "$json_body" "https://api.mapbox.com/uploads/v1/hydrosat?access_token=$MAPGL_SECRET_TOKEN"

