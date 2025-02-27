#!/usr/zsh
response=$(curl -X POST "https://api.mapbox.com/uploads/v1/hydrosat/credentials?access_token=$MAPBOX_TOKEN")

# Extract values using jq and store them in variables
export AWS_ACCESS_KEY_ID=$(echo $response | jq -r '.accessKeyId')
export AWS_SECRET_ACCESS_KEY=$(echo $response | jq -r '.secretAccessKey')
export AWS_SESSION_TOKEN=$(echo $response | jq -r '.sessionToken')

export BUCKET=$(echo $response | jq -r '.bucket')
export BUCKET_KEY=$(echo $response | jq -r '.key')
# Print the values or use them in your script
echo "Value of bucket: $BUCKET"
echo "Value of key2: $BUCKET_KEY"

echo "variables set"





