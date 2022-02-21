#!/bin/bash

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY

########################################################################
user_id="user-a"
account_id="448372837363"
region="ap-northeast-2"

export AWS_ACCESS_KEY_ID=""
export AWS_SECRET_ACCESS_KEY=""
########################################################################

if ! command -v aws &> /dev/null ; then
	echo;echo "ERROR:Require <aws-cli> but it's not installed. Aborting." ; exit 1
fi

echo 
echo "Warning : Current config file will be deleted.(~/.aws/credentials)"
echo 
printf "Enter MFA Code: "
read mfa
value=$(aws sts get-session-token --serial-number arn:aws:iam::$account_id:mfa/$user_id --token-code $mfa --output text)

if [ -z "$value" ] ; then
	exit 1;
fi

access_key_id=$(echo $value | awk '{print $2}' | tr -d '"' | tr -d ',')
secret_access_key=$(echo $value | awk '{print $4}' | tr -d '"' | tr -d ',')
session_token=$(echo $value | awk '{print $5}' | tr -d '"' | tr -d ',')

mkdir -p ~/.aws

echo "[default]
aws_access_key_id = $access_key_id
aws_secret_access_key = $secret_access_key
aws_session_token = $session_token" > ~/.aws/credentials

echo "[default]
region=$region
output=json" > ~/.aws/config
