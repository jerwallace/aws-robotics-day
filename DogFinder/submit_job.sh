#!/bin/bash

export BUCKET_NAME="your bucket name"
export SUBNET1="your_subnet_1"
export SUBNET2="your_subnet_2"
export SECURITY_GROUP="your_security_group"
export ROLE_ARN="your iam role ARN here"


aws robomaker create-robot-application \
  --name DogFinder_robot \
  --sources "s3Bucket=$BUCKET_NAME,s3Key=dogfinder/output-robot.tar,architecture=X86_64" \
  --robot-software-suite "name=ROS,version=Kinetic"

aws robomaker create-simulation-application \
  --name DogFinder_simulation \
  --sources "s3Bucket=$BUCKET_NAME,s3Key=dogfinder/output-sim.tar,architecture=X86_64" \
  --simulation-software-suite "name=Gazebo,version=7" \
  --robot-software-suite "name=ROS,version=Kinetic"\
  --rendering-engine "name=OGRE,version=1.x"

robot_app=`aws robomaker list-robot-applications | grep -Po '"\K(arn:.*DogFinder.*)"' | sed 's/.$//'`
sim_app=`aws robomaker list-simulation-applications | grep -Po '"\K(arn:.*DogFinder.*)"' | sed 's/.$//'`

template='{"iamRole":"%s","outputLocation":{"s3Bucket":"%s","s3Prefix":"dogfinderOutput"},"maxJobDurationInSeconds":28800,"failureBehavior":"Fail","robotApplications":[{"application":"%s","applicationVersion":"$LATEST","launchConfig":{"packageName":"dogfinder_robot","launchFile":"find_dog.launch","environmentVariables":{}}}],"simulationApplications":[{"application":"%s","applicationVersion":"$LATEST","launchConfig":{"packageName":"dogfinder_simulation","launchFile":"hexagon.launch","environmentVariables":{}}}],"vpcConfig":{"subnets":["%s","%s"],"securityGroups":["%s"],"assignPublicIp":true}}'
json_params=$(printf "$template" "$ROLE_ARN" "$BUCKET_NAME" "$robot_app" "$sim_app" "$SUBNET1" "$SUBNET2" "$SECURITY_GROUP")

aws robomaker create-simulation-job --cli-input-json "$json_params"
