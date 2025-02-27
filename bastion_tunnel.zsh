#!/bin/zsh
# bastion_tunnel
if [[ -z $AWS_RDS_ENDPOINT || -z $AWS_RDS_PORT || -z $BASTION_USER || -z $BASTION_ENDPOINT || -z $BASTION_SSH_KEY ]]; then

    echo "Environment variables not set. Please run setup.zsh first."
    echo "VARIABLES:"
    echo "AWS_RDS_ENDPOINT: $AWS_RDS_ENDPOINT"
    echo "AWS_RDS_PORT: $AWS_RDS_PORT"
    echo "BASTION_USER: $BASTION_USER"
    echo "BASTION_ENDPOINT: $BASTION_ENDPOINT"
    echo "BASTION_SSH_KEY: $BASTION_SSH_KEY"
    exit 1
fi

LOCAL_PORT=5440 # Change this to your desired local port

ssh -i ~/.ssh/$BASTION_SSH_KEY -L $LOCAL_PORT:$AWS_RDS_ENDPOINT:$AWS_RDS_PORT -N -T $BASTION_USER@$BASTION_ENDPOINT
