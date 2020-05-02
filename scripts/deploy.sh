echo "Processing deploy.sh"
# Set EB BUCKET as env variable
EB_BUCKET=elasticbeanstalk-us-west-1-845114594136
# Set the default region for aws cli
aws configure set default.region us-west-1
# Log in to ECR
eval $(aws ecr get-login --no-include-email --region us-west-1)
# Build docker image based on our production Dockerfile
docker build -t abbeysuri/mm .
# tag the image with the Travis-CI SHA
docker tag abbeysuri/mm:latest 845114594136.dkr.ecr.us-west-1.amazonaws.com/mm: d5:01:1a:34:46:d3:22:24:93:29:81:58:1b:96:e7:a3
# Push built image to ECS
docker push 845114594136.dkr.ecr.us-west-1.amazonaws.com/mm: d5:01:1a:34:46:d3:22:24:93:29:81:58:1b:96:e7:a3
# Use the linux sed command to replace the text '<VERSION>' in our Dockerrun file with the Travis-CI SHA key
sed -i='' "s/<VERSION>/ d5:01:1a:34:46:d3:22:24:93:29:81:58:1b:96:e7:a3/" Dockerrun.aws.json
# Zip up our codebase, along with modified Dockerrun and our .ebextensions directory
zip -r mm-prod-deploy.zip Dockerrun.aws.json .ebextensions
# Upload zip file to s3 bucket
aws s3 cp mm-prod-deploy.zip s3://elasticbeanstalk-us-west-1-845114594136/mm-prod-deploy.zip
# Create a new application version with new Dockerrun
aws elasticbeanstalk create-application-version --application-name megamarkets --version-label  d5:01:1a:34:46:d3:22:24:93:29:81:58:1b:96:e7:a3 --source-bundle S3Bucket=$EB_BUCKET,S3Key=mm-prod-deploy.zip
# Update environment to use new version number
aws elasticbeanstalk update-environment --environment-name Megamarkets-prod --version-label  d5:01:1a:34:46:d3:22:24:93:29:81:58:1b:96:e7:a3
