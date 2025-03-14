#!/bin/zsh
SUPPORTED_PROFILES=("IRRIWATCH_STAGING" "IRRIWATCH_PROD")


PROFILE=$1

if [[ -z $PROFILE ]]; then
    echo "Please specify a profile."
    echo "Supported Profiles:"
    for profile in "${SUPPORTED_PROFILES[@]}"; do  # ✅ Fixed array loop
        echo "  - $profile"
    done
    return 1  # ✅ Use return instead of exit
fi

case $PROFILE in
    "YFP_STAGING")
        export AWS_RDS_ENDPOINT=$STAGING_YFP_RDS
        export AWS_RDS_PORT="5432"
        export BASTION_USER="ec2-user"
        export BASTION_ENDPOINT="bastion.staging.yield-forecast.hydrosat.com"
        export BASTION_SSH_KEY="hydrosat-lux-yfp-staging-keys.key"
        ;;
    "YFP_PROD")
        export AWS_RDS_ENDPOINT=$PROD_YFP_RDS
        export AWS_RDS_PORT="5432"
        export BASTION_USER="ec2-user"
        export BASTION_ENDPOINT="bastion.yield-forecast.hydrosat.com"
        export BASTION_SSH_KEY="hydrosat-lux-yfp-prod-keys.key"
        ;;
    "IRRIWATCH_STAGING")
        export AWS_RDS_ENDPOINT=$STAGING_RDS

        export AWS_RDS_PORT="5432"
        export BASTION_USER="ec2-user"
        export BASTION_ENDPOINT="bastion.irriwatch-staging.hydrosat.com"
        export BASTION_SSH_KEY="hydrosat-lux-irriwatch-staging-keys.key"
        ;;
    "IRRIWATCH_PROD")
        export AWS_RDS_ENDPOINT=$PROD_RDS

        export AWS_RDS_PORT="5432"
        export BASTION_USER="ec2-user"
        export BASTION_ENDPOINT="bastion.irriwatch.hydrosat.com"
        export BASTION_SSH_KEY="hydrosat-lux-irriwatch-prod-keys.key"
        ;;
    *)
        echo "Unknown profile: $PROFILE"
        return 1
        ;;
esac

echo "AWS RDS $AWS_RDS_ENDPOINT" 
echo "Environment variables set for $PROFILE"
