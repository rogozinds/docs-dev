#!/bin/zsh

# Ensure the script is executed with one argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <prod|staging>"
    exit 1
fi

ENVIRONMENT=$1

ENV_NAME="irriwatch"
# Define key paths based on environment
if [[ "$ENVIRONMENT" == "prod" ]]; then
    KEY_PATH="~/.ssh/hydrosat-lux-irriwatch-prod-keys.key"
    BASTION_HOST="irriwatch-prod-bastion"
elif [[ "$ENVIRONMENT" == "staging" ]]; then
    KEY_PATH="~/.ssh/hydrosat-lux-irriwatch-staging-keys.key"
    BASTION_HOST="irriwatch-staging-bastion"
else
    echo "Invalid environment: $ENVIRONMENT. Use 'prod' or 'staging'."
    exit 1
fi

echo "Fetching instance ID for environment: $ENV_NAME..."
# Fetch all instance IDs
INSTANCE_LIST=$(aws elasticbeanstalk describe-environment-resources --environment-name "$ENV_NAME" \
    --query "EnvironmentResources.Instances[*].Id" --output text)

# Convert instance list into an array
INSTANCES=(${=INSTANCE_LIST})

if [[ ${#INSTANCES[@]} -eq 0 ]]; then
    echo "Error: No running instances found."
    exit 1
elif [[ ${#INSTANCES[@]} -eq 1 ]]; then
    # If only one instance, connect automatically
    INST_ID=${INSTANCES[1]}
    echo "Only one instance found: $INST_ID"
else
    # Multiple instances: Show options
    echo -e "\nAvailable Instances:"
    for i in {1..${#INSTANCES[@]}}; do
        echo "$i. ${INSTANCES[i]}"
    done

    # Ask user to choose
    while true; do
           read "choice?Enter the number of the instance to connect: "

        # Use [[ $choice == <pattern> ]] instead of [[ $choice =~ <regex> ]] in Zsh
        if [[ "$choice" == <-> ]] && (( choice >= 1 && choice <= ${#INSTANCES[@]} )); then
            INST_ID=${INSTANCES[choice]}  # No need for -1 because Zsh arrays are 1-based
            break
        else
            echo "Invalid selection. Please enter a number between 1 and ${#INSTANCES[@]}."
        fi
    done
fi

echo "Instance ID: $INST_ID"

# Fetch public DNS
PUB_DNS=$(aws ec2 describe-instances --instance-ids "$INST_ID" \
    --query "Reservations[0].Instances[0].PublicDnsName" --output text)

if [[ -z "$PUB_DNS" || "$PUB_DNS" == "None" ]]; then
    echo "Error: Failed to retrieve public DNS."
    exit 1
fi

echo "Public DNS: $PUB_DNS"

# SSH into the instance
echo "Connecting to EC2 instance..."
ssh -J "$BASTION_HOST" ec2-user@"$PUB_DNS" -i "$KEY_PATH"
