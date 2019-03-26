# Deploy a ROS application to your robot

In the previous exercise, you used RoboMaker with Cloud9 to build, bundle and simulate the Find Fido robot application.  In RoboMaker, simulations use Gazebo, which runs in AWS on a fleet of servers with x86 CPU architecture.  However, many physical robots use different CPU architecture, such as ARM.  Before a robot application can be deployed and invoked on a physical robot, it may need to be rebuilt and rebundled for the target CPU architecture of the robot.

In this workshop, you'll be deploying an application to a TurtleBot 3 Burger robot.  This robot uses a Raspberry Pi, which is based on the ARMHF architecture.  Within the RoboMaker Cloud9 environment, we have pre-installed a Docker container that simplifies the process of compiling for alternate architectures.  The initial build and bundle operation for an alternate architecture may take up to 20 minutes, so it is outside the scope of this workshop.  If you have time after completing this exercise, you can review the detailed steps for building for alternate architectures in the [RoboMaker documentation](https://docs.aws.amazon.com/robomaker/latest/dg/gs-deploy.html).  For this exercise, we have pre-created a bundle for the TurtleBot3 Burger robot.  We will use that bundle to deploy the application to your robot.

This activity covers the steps required to prepare a physical robot to receive a ROS application using RoboMaker. When complete, you will have learned:

* How to register your robot in RoboMaker.
* How to deploy authentication certificates to your robots.
* How to create robot application versions, and robot fleets.
* How to deploy a bundled ROS application to your robot.


## Activity tasks

1. Open the Cloud9 development environment you used in exercise 2 of this workshop.

2. The bundle that you'll deploy to your robot has been pre-created.  Robots retrieve bundles from S3 during deployment, so your first step is to copy the robot bundle to S3:

   From the **ROBOT TAB**:
   
   ```bash
   # Replace YOUR_BUCKET_NAME with your bucket
   aws s3 cp bundle/output.armhf.tar.gz s3://YOUR_BUCKET_NAME/dogfinder/output-robot.armhf.tar.gz
   ```

3. Now that you've uploaded an ARMHF version of the application to S3, you need to tell RoboMaker where to find it.  Open the RoboMaker console, and review the Robot applications Development->Robot applications).  Click on the name of the robot application, DogFinder_robot, to reiew its details.

4. To view the location of the bundle files for the application, click on the $LATEST link, under Latest version.

5. You will now see the details for the DogFinder_robot application, including the Sources.  Notice that it currently has only one source:  the X86_64 version (this is the version you just used for simulation).  To tell RoboMaker about the ARMHF version, click the **Update** button.

6. In the ARMHF souce file text box, paste the S3 location for the ARMHF bundle:

   ```bash
   # Replace YOUR_BUCKET_NAME with your bucket
   s3://YOUR_BUCKET_NAME/dogfinder/output-robot.armhf.tar.gz
   ```
   
   Click **Create**.
   
7. Before RoboMaker can deploy to a physical robot, you need to configure your robot.  You need to create authentication certificates that will enable the device to securely communicate with AWS.  You also need to register your robot in RoboMaker.  To get started with this task, click on the Robots link under Fleet Management.

8. Click on the **Create robot** button.

9. Give your robot a friendly name (i.e. DogFinder), and set the Architecture to ARMHF.  By setting this value, you're telling RoboMaker to use the ARMHF bundle when deploying to this robot.

10. RoboMaker uses AWS GreenGrass to deploy your robot bundles to your device.  You must now configure RoboMaker's GreenGrass settings.  You can leave the *AWS Grengrass group* and *AWS Greengrass prefix* settings as their default values.  

11.  For *IAM role*, choose "dogfinder-deployment-role".  This role was created in exercise 1 of this worksop.  This role is assumed by your robot application when it runs on your device and gives your device permission to access AWS services on your behalf.

12.  Click **Create**.

13.  You must now download the certificates that need to be installed on your robot.  When installed on your robot, they will give your robot access to call AWS services.  Click the orange **Download** button.  There is no need to download the Greengrass Core software.  Your device has been pre-configured with the Greengrass binaries.  This will download a zip file named DogFinder-setup.zip (or similar, depending on the name you provided for your robot in Step 9 above).

   ![3_download_certs](img/download_certs.jpg)

14.  The certificates you just downloaded need to be copied to the physical robot and extracted to a directory on the device.  These instructions use scp to copy files to the device, and ssh to connect to the device.  Both commands are available in Terminal on macOS, and in the Windows PowerShell.  However, availability of these tools may vary, depending on your configuration (particularly on Windows).
   a. If you're using a Windows computer, skip to the next step.  On macOS, open Terminal by pressing Command-spacebar to launch Spotlight and type "Terminal," then double-click the search result.  Skip the next step regarding Windows, and proceed to step 14(c).
   b. If you're using Windows, press the Windows key, or click the Windows (Start) button, and type "PowerShell" and press Enter.
   c. On your laptop, navigate to the directory where you downloaded the certificates in Step 13 above. ($ cd Downloads)
   d. Copy the zip file to your robot:
   
      ```bash
      # replace FILE_NAME with the value for your zip file
      $ scp FILE_NAME.zip pi@<ROBOT_IP_ADDRESS>:/home/pi 


