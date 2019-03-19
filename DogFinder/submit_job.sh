#!/bin/bash

export BUCKET_NAME="your bucket name"
export SUBNETS="your_subnet1,your_subnet2"
export SECURITY_GROUP="your_security_group"
export ROLE_ARN="your iam role ARN here"


aws robomaker create-robot-application \
  --name DogFinder_robot \
  --sources "s3Bucket=$BUCKET_NAME,s3Key=dogfinder/output-robot.tar.gz,architecture=X86_64" \
  --robot-software-suite "name=ROS,version=Kinetic"

aws robomaker create-simulation-application \
  --name DogFinder_simulation \
  --sources "s3Bucket=$BUCKET_NAME,s3Key=dogfinder/output-sim.tar.gz,architecture=X86_64" \
  --simulation-software-suite "name=Gazebo,version=7" \
  --robot-software-suite "name=ROS,version=Kinetic"\
  --rendering-engine "name=OGRE,version=1.x"

robot_app=`aws robomaker list-robot-applications | grep -Po '"\K(arn:.*DogFinder.*)"' | sed 's/.$//'`
sim_app=`aws robomaker list-simulation-applications | grep -Po '"\K(arn:.*DogFinder.*)"' | sed 's/.$//'`

aws robomaker create-simulation-job \
  --max-job-duration-in-seconds=7200 \
  --iam-role "$ROLE_ARN" \
  --vpc-config "subnets=$SUBNETS,securityGroups=$SECURITY_GROUP,assignPublicIp=true" \
  --output-location "s3Bucket=$BUCKET_NAME,s3Prefix=dogfinderOutput" \
  --failure-behavior Fail \
  --robot-applications \
    "application=$robot_app,applicationVersion=\$LATEST,launchConfig={packageName=dogfinder_robot,launchFile=find_dog.launch}" \
  --simulation-applications \
    "application=$sim_app,applicationVersion=\$LATEST,launchConfig={packageName=dogfinder_simulation,launchFile=hexagon.launch}" 
