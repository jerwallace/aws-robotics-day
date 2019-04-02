# Deploy a ROS application to your robot

In the previous exercises, you used RoboMaker with Cloud9 to build, bundle and simulate two different robot applications. In the final activity of this workshop, we will deploy the simple Hello World application we built in the first activity. 

In RoboMaker, simulations use Gazebo, which runs in AWS on a fleet of servers with x86 CPU architecture.  However, many physical robots use different CPU architectures, such as ARM.  Before a robot application can be deployed and invoked on a physical robot, it may need to be rebuilt and rebundled for the target CPU architecture of the robot.

In this workshop, you'll be deploying an application to a TurtleBot 3 Burger robot.  This robot uses a Raspberry Pi, which is based on the ARMHF architecture.  Within the RoboMaker Cloud9 environment, we have pre-installed a Docker container that simplifies the process of compiling for alternate architectures.  The initial build and bundle operation for an alternate architecture may take up to 20 minutes, so it is outside the scope of this workshop.  If you have time after completing this exercise, you can review the detailed steps for building for alternate architectures in the [RoboMaker documentation](https://docs.aws.amazon.com/robomaker/latest/dg/gs-deploy.html).  For this exercise, we have pre-created a bundle for the TurtleBot3 Burger robot.  We will use that bundle to deploy the application to your robot.

This activity covers the steps required to prepare a physical robot to receive a ROS application using RoboMaker. When complete, you will have learned:

* How to register your robot in RoboMaker.
* How to deploy authentication certificates to your robots.
* How to create robot application versions, and robot fleets.
* How to deploy a bundled ROS application to your robot.

## Activity tasks

1. Open the Cloud9 development environment you used in exercise 2 of this workshop.

2. Before you can deploy to a robot, you need to create an IAM role that gives the robot permissions to AWS resources. This role will be used by the robot to download our bundled robot application, and it will be used by the application at runtime to access AWS services.

   For this activity, you will create an IAM role that has these permissions. From the **OS tab**, copy and paste the following commands to create a role named *Cloud9-RoboMakerWorkshopDeploymentRole*:

   ```bash
   # ### Begin of copy (include this line) ###
   # Create the policy to allow RoboMaker access
   # RUN THIS COMMAND ONLY TO GET ARN OUTPUT
   aws iam create-role --role-name Cloud9-RoboMakerWorkshopDeploymentRole --assume-role-policy-document '{
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Service": [
              "lambda.amazonaws.com",
              "iot.amazonaws.com",
              "greengrass.amazonaws.com"
            ]
         },
         "Action": "sts:AssumeRole"
       }
     ]
   }'
   # Attach policies that grant access
   # COPY AND PASTE ALL THESE (you can include these comment lines too)
   # Read S3 bucket to download robot and simulation bundles and create log files
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshopDeploymentRole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
   # Ability for simulation job and robot to create CloudWatch Logs/Metrics
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshopDeploymentRole --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess
   # Ability to interact with Kinesis Video Streams
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshopDeploymentRole --policy-arn arn:aws:iam::aws:policy/AmazonKinesisVideoStreamsFullAccess
   # Ability to invoke Rekognition for object detection
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshopDeploymentRole --policy-arn arn:aws:iam::aws:policy/AmazonRekognitionFullAccess
   # Ability to invoke RoboMaker for deployment
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshopDeploymentRole --policy-arn arn:aws:iam::aws:policy/AWSRoboMakerFullAccess
   # ### End of copy (include this line) ###
   ```

   :bulb: This is a role that allows full access to a few AWS services. At the end of the workshop, please delete the role if not needed.

3.  For the next activity, you need the ARN for the role that was created in the previous step.  Look at the output from the first command and copy the value of the Arn, it should look similar to this:

   ```text
   arn:aws:iam::123456789012:role/Cloud9-RoboMakerWorkshopDeploymentRole
   ```
   
4. Using the ARN you found in the previous step, run the command below to allow Greengrass to use it for deployment:
   
   ```bash
   # replace DEPLOYMENT_ROLE_ARN with your ARN
   aws greengrass associate-service-role-to-account --role-arn $DEPLOYMENT_ROLE_ARN
   ```

5. The bundle that you'll deploy to your robot has been pre-created.  Robots retrieve bundles from S3 during deployment, so your first step is to copy the robot bundle to S3:

   From the **ROBOT TAB**:
   
   ```bash
   # Replace <YOUR_BUCKET_NAME> with your bucket
   aws s3 cp s3://bundles.robomakerworkshops.com/turtlebot3-burger/hello-world/robot-armhf.tar s3://<YOUR_BUCKET_NAME>/HelloRobot/output-robot.armhf.tar
   ```

6. Now that you've uploaded an ARMHF version of the application to S3, you need to tell RoboMaker where to find it.  Open the RoboMaker console, and review the Robot Applications (Development->Robot Applications).  Click on the name of the robot application, RoboMakerHelloWorldRobot, to review its details.

7. To view the location of the bundle files for the application, click on the $LATEST link, under Latest version.

6. You will now see the details for the RoboMakerHelloWorldRobot application, including the Sources.  Notice that it currently has only one source:  the X86_64 version (this is the version you just used for simulation).  To tell RoboMaker about the ARMHF version, click the **Update** button.

8. In the ARMHF souce file text box, paste the S3 location for the ARMHF bundle:

   ```bash
   # Replace <YOUR_BUCKET_NAME> with your bucket
   s3://<YOUR_BUCKET_NAME>/HelloRobot/output-robot.armhf.tar
   ```
   
   Click **Create**.
   
9. Before RoboMaker can deploy to a physical robot, you need to configure your robot.  You need to create authentication certificates that will enable the device to securely communicate with AWS.  You also need to register your robot in RoboMaker.  To get started with this task, click on the Robots link under Fleet Management.

10. Click on the **Create robot** button.

11. Give your robot a friendly name (i.e. HelloRobot), and set the Architecture to ARMHF.  By setting this value, you're telling RoboMaker to use the ARMHF bundle when deploying to this robot.

12. RoboMaker uses AWS GreenGrass to deploy your robot bundles to your device.  You must now configure RoboMaker's GreenGrass settings.  You can leave the *AWS Grengrass group* and *AWS Greengrass prefix* settings as their default values.  

13.  For *IAM role*, choose "HelloRobot-deployment-role".  This role was created in exercise 1 of this worksop.  This role is assumed by your robot application when it runs on your device and gives your device permission to access AWS services on your behalf.

14.  Click **Create**.

15.  You must now download the certificates that need to be installed on your robot.  When installed on your robot, they will give your robot access to call AWS services.  Click the orange **Download** button.  There is no need to download the Greengrass Core software.  Your device has been pre-configured with the Greengrass binaries.  This will download a zip file named HelloRobot-setup.zip (or similar, depending on the name you provided for your robot in Step 9 above).

   ![3_download_certs](img/download-certs.jpg)

16.  The certificates you just downloaded need to be copied to the physical robot and extracted to a directory on the device.  These instructions use scp to copy files to the device, and ssh to connect to the device.  Both commands are available in Terminal on macOS, and in the Windows PowerShell.  However, availability of these tools may vary, depending on your configuration (particularly on Windows).

17. If you're using a Windows computer, skip to the next step.  On macOS, open Terminal by pressing Command-spacebar to launch Spotlight and type "Terminal," then double-click the search result.  Skip the next step regarding Windows, and proceed to step 17.

18. If you're using Windows, press the Windows key, or click the Windows (Start) button, and type "PowerShell" and press Enter.

19. On your laptop, navigate to the directory where you downloaded the certificates in Step 13 above. ($ cd Downloads)

20. Copy the zip file to your robot.  Replace the file name with the file name of the file you downloaded.  The IP address for your robot was provided with the robot.  You will be prompted for a password.  The password for the pi user is: roboMaker2019
   
      ```bash
      # replace FILE_NAME with the value for your zip file
      $ scp FILE_NAME.zip pi@<ROBOT_IP_ADDRESS>:/home/pi 
      ```

21. Connect to the robot, flash the OpenCR board, configure the certificates and start the Greengrass service.  In this step, you use ssh to connect to the robot, and then you unzip the certificates file to the location used by Greengrass.  Finally, you start the Greengrass service.  This enalbes the device to retrieve your robot bundle and deploy it to the robot.  As a reminder, you are connecting as the pi user, and the password is:  roboMaker2019
   
   ```bash
   # use SSH and connect to the robot.  Replace ROBOT_IP_ADDRESS with the IP address for your device.
   $ ssh pi@<ROBOT_IP_ADDRESS>
   $ sudo su

   $ export OPENCR_PORT=/dev/ttyACM0
   $ export OPENCR_MODEL=burger
   $ rm -rf ./opencr_update.tar.bz2
   $ wget https://github.com/ROBOTIS-GIT/OpenCR-Binaries/raw/master/turtlebot3/ROS1/latest/opencr_update.tar.bz2 && tar -xvf opencr_update.tar.bz2 && cd ./opencr_update && ./update.sh $OPENCR_PORT $OPENCR_MODEL.opencr && cd ..

   # unzip the certificates into the /greengrass directory.  Replace FILE_NAME with file you copied earlier.
   $ unzip FILE_NAME.zip -d /greengrass
   
   #start the Greengrass service
   $ /greengrass/ggc/core/greengrassd start
   ```

22. Create a Fleet and add your robot to the Fleet.  Fleets enable you to manage a group of robots.  For example, you can deploy the same robot application to all robots in a fleet.  Then ensures that all your robots are running the same software.  If you need different robots to run differnt software, you can create multiple fleets.  In this workshop, you'll create a single fleet, that contains a single robot.  In the AWS RoboMaker console, choose *Fleets* under *Fleet managment*.  Click the **Create fleet** button. 

23. Give your fleet an appropriate name and click **Create**.

24. You now must add your robot to the newly-created fleeet.  On the fleet page for your new fleet, click the **Register new** button under the *Registered robots* section.

   ![3_register_new](img/register_new.jpg)

25. Select your robot, and choose **Register robot**.  Congratulations, your robot is now a member of your fleet!

26. The final step is to deploy our application to our fleet.  To get started, click *Deployments* under *Fleet management*, and choose **Create deployment**.  

27. Choose the Fleet and Robot application (RoboMakerHelloWorldRobot) you created earlier.  

28. For *Robot application version*, choose *Create new*, and click **Create** on the confirmation.  This will create a new version for the HelloRobot_application robot application.

29. For *Package name*, enter `hello_world_robot`.  This is the ROS package contained in our bundle that contains the startup file for our robot.

30. For *Launch file*, enter `deploy_rotate.launch`.  This is the launch file within the above package.  It contains information about the ROS nodes that will be started on the device.

31. All other fields can use their default values.  Scroll to the bottom and choose **Create**.
   
Within a few seconds, your robot will begin to download the robot bundle.  Because this is the first time this application is being deployed to your robot, the bundle size is large (~600MB).  It will take about 15 minutes for the robot to download and extract the contents on the robot.  You can follow the deployment progress in the *Robots status* section:

![3_robots_status](img/robots-status.png)

When the bundle has been successfully deployed, the robot application will automatically be launched on your robot!




