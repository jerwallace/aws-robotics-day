# Development environment and HelloWorld

This activity covers setting up the AWS RoboMaker development environment and quickly compiling at running a "Hello World" ROS application. When complete, you will have learned:

* How to navigate the AWS RoboMaker console and access development environment and simulation jobs
* Basic ROS workspace layout and build/bundle tasks
* How to submit and interact with a simulation job

## Activity tasks

1. Open a new tab to the AWS RoboMaker console (*Services->RoboMaker->right-click->new tab*)

2. Create a development environment (*Development->Development environments->Create environment*) and complete the following:

   * Name: `workshop` or something descriptive
   * Instance type: `m4.large`
   * Choose the VPC (default), and a subnet for your development environment
   * Click Create

3. This opens the environment's detail page, click *Open environment*, which will open a new browser tab with the Cloud9 IDE.

   :bulb: This may take a few minutes to complete, but when the creation process has completed, you will see something similar to this:

   ![1_cloud9](img/1_cloud9.png)

   The Welcome page provides helpful information to get started, but for now we are not going to use it, so click the *X* on the tab to close.The IDE is broken down into four sections:

   ![1_c9_layout](img/1_c9_layout.png)

   1. The AWS RoboMaker menu provide quick access to common actions. It is updated when the `roboMakerSettings.json` is modified later in this task.
   2. Any files and folders will reside here, and can be selected and double-clicked to open in the editor pane (#4).
   3. The lower section is an adjustable pane for creating or monitoring command line operations. ROS developers work in this area to build, test, and interact with local code.
   4. This is the main editor pane.

4. Delete the `roboMakerSettings.json` file by right-clicking on it and selecting *Delete*->Yes. We will use the example applications file to complete.

5. Next, use the menu to download and create the HelloWorld application by clicking *RoboMaker Resources->Download Samples->1. Hello World*. This will download, unzip, and load the readme file for the Hello World application.

6. Before updating the file that builds the menus, you will first need to create an IAM role that gives the simulation service the proper permissions to other AWS resources. For instance you could allow the simulation to have access to CloudWatch Logs, but not have access to S3.

   For this and the next activity, you will create an IAM role that has the permissions needed for both. From the CLI (terminal) pane, copy and paste the following commands to create a role named *Cloud9-RoboMakerWorkshop*:

   ```bash
   # ### Begin of copy (include this line) ###
   # Create the policy to allow RoboMaker access
   # RUN THIS COMMAND ONLY TO GET ARN OUTPUT
   aws iam create-role --role-name Cloud9-RoboMakerWorkshop --assume-role-policy-document '{
     "Version": "2012-10-17",
     "Statement": [
       {
         "Effect": "Allow",
         "Principal": {
           "Service": "robomaker.amazonaws.com"
         },
         "Action": "sts:AssumeRole"
       }
     ]
   }'
   # Attach policies that grant access
   # COPY AND PASTE ALL THESE (you cna include these comment lines too)
   # Read S3 bucket to download robot and simulation bundles and create log files
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshop --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
   # Ability for simulation job and robot to create CloudWatch Logs/Metrics
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshop --policy-arn arn:aws:iam::aws:policy/CloudWatchFullAccess
   # Ability to interact with Kinesis Video Streams
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshop --policy-arn arn:aws:iam::aws:policy/AmazonKinesisVideoStreamsFullAccess
   # Ability to invoke Rekognition for object detection
   aws iam attach-role-policy --role-name Cloud9-RoboMakerWorkshop --policy-arn arn:aws:iam::aws:policy/AmazonRekognitionFullAccess
   # ### End of copy (include this line) ###
   ```

   :bulb: This is a role that allows full access to a few AWS services. At the end of the workshop, please delete the role if not needed.

7. To get the role's ARN, look at the output from the first command and copy the value of the Arn, it should look similar to this:

   ```text
   arn:aws:iam::123456789012:role/Cloud9-RoboMakerWorkshop
   ```

8. With the role created and policies attached, go back to your Cloud9 IDE window. For this project, we are going to use the menu option to build, bundle and simulate. Close the `README.md` file in the editor pane, then twirl open the *HelloWorld* folder (double-click), and double-click the `roboMakerSettings.json` file to edit.

   This file contains all the settings to build the menu above. You will use these default settings, but need to complete the S3 bucket and IAM Role ARN  sections for your account.

9. Scroll down to the `simulation` section and replace the `output location` with your S3 bucket name. Below that, replace the `<your ... role ARN>` with the full ARN saved from the previous step. Save the file. This will refresh the menu options to use the new values.

   Just above the simulation attribute, also replace the s3Bucket entries for `robotApp` and `simulationApp`.

   :bulb: There are three locations to enter the S3 bucket details. If you receive an error when running, check to make sure all three are complete and the role ARN has been entered.

   When done, the modified sections should look similar to this:

   ```json
       }, {
         "id": "HelloWorld_SimulationJob1",
         "name": "HelloWorld",
         "type": "simulation",
         "cfg": {
           "robotApp": {
             "name": "RoboMakerHelloWorldRobot",
             "s3Bucket": "df-workshop",
             "sourceBundleFile": "./HelloWorld/robot_ws/bundle/output.tar.gz",
             "architecture": "X86_64",
             "robotSoftwareSuite": {
               "version": "Kinetic",
               "name": "ROS"
             },
             "launchConfig": {
               "packageName": "hello_world_robot",
               "launchFile": "rotate.launch"
             }
           },
           "simulationApp": {
             "name": "RoboMakerHelloWorldSimulation",
             "s3Bucket": "df-workshop",
             "sourceBundleFile": "./HelloWorld/simulation_ws/bundle/output.tar.gz",
             "architecture": "X86_64",
             "launchConfig": {
               "packageName": "hello_world_simulation",
               "launchFile": "empty_world.launch"
             },
             "simulationSoftwareSuite": {
               "name": "Gazebo",
               "version": "7"
             },
             "renderingEngine": {
               "name": "OGRE",
               "version": "1.x"
             },
             "robotSoftwareSuite": {
               "version": "Kinetic",
               "name": "ROS"
             }
           },
           "simulation": {
             "outputLocation": "df-workshop",
             "failureBehavior": "Fail",
             "maxJobDurationInSeconds": 28800,
             "iamRole": "arn:aws:iam::YOUR_ACCOUNT:role/YOUR_ROLE"
           }
         }
       },
   ```

10. You next use the menu to build and bundle both the robot and simulation application. Click *RoboMaker Run->Build->HelloWorld Robot* to start the compile for the robot application. This will take approximately 1-2 minutes as it needs to download and compile the code. When you see a `Process exited with code: 0` which indicated success, use the same command to build the *HelloWorld Simulation*.

  At this point both applications have been compiled locally. To run as a AWS RoboMaker simulation job, you will first need to bundle them. This process "bundles" the application along with all operating system dependencies, sort of like a container. This creates compressed output files locally.

11. As with the build steps above, do the same for both the robot and simulation application, but select *RoboMaker Run->Bundle->...* instead of build. This will take 10-15 minutes or so to complete for both, and you may see Cloud9 warnings about low memory, which you can disregard.

   While these are building, review the JSON file for the simulation area. Here you can see that the launch configs reference the package name (hello_world_robot or hello_world_simulation) and the launch file to use (rotate.launch and empty_world.launch respectively). 

12. When both bundle operations are completed, launch a simulation job (*RoboMaker Run->Launch Simulation->HelloWorld*). This will do the following:

    * Upload the robot and simulation application bundles (approximately 1.2GiB) to the S3 bucket
    * Create a robot application and simulation application which reference the uploaded bundles
    * Start the simulation job in your defined VPC

13. Open the AWS RoboMaker console and click on simulation jobs. You should see your job in a *Running* status. Click on the job id to see the values that were passed as part of the job. This view provides all the details of the job and access to tools which you will use in a moment.

    :exclamation:If the status shows Failed, it is most likely a typo or configuration issue to resolve. In the *Details* section, look for the *Failure reason* to determine what took place so you can correct.

14. From the simulation job details, we will launch a couple tools to interact with the robot. First, click on Gazebo, which will launch a pop-up window for the application. This is a client that provides a view into the virtual world.

    ![1_gazebo](img/1_gazebo.png)

    Using your mouse or trackpad, click into main window. Please refer to [this page](http://gazebosim.org/tutorials?tut=guided_b2&cat=) for more details and how to navigate (near the bottom of the page).

    When zoomed in, you will see robot turning slowing counter-clockwise in the same position. This is due to the `rotate.launch` file sent as the part of the robot application.

    Leave this window open for now and go back to the simulation job page. Here, click on Rviz, which will open a new window. :bulb: If possible, make the window larger on your laptop for better visibility.

    [Rviz](http://wiki.ros.org/rviz) is a 3D visualization tool for ROS. It provides information on the robot state and world around it (virtual or real). To get your virtual robot properly working, we need to point to a robot component. Click in the window, and then click on the "map" next to Fixed Frame:

    ![1_rviz_start](img/1_rviz_start.png)

    From the drop-down, select `base_footprint` and then click in the whitespace below. This should fix the *Global Status: Error* message. Next, select the Add button in the lower left, and from the *By display type*, select *Camera* and click *OK*. Notice the grid pattern in the camera window. To view what the virtual robot "sees", click the triangle next to Camera to twirl it down, then click into the Image Topic field. There should be a single topic name /camera/rgb/image_raw for you to select:

    ![1_rviz_camera](img/1_rviz_camera.png)

    Like above, once select click outside this area (or click on *Global Status: OK*) to have it take effect. The camera window should change to a two-tones gray view. This is correct as the world you launched in is truly empty. It's time to add something(s).

15. Navigate back to the Gazebo window and select on object (cube, ball, or cylinder) menu and then inside the world view drag you object near the robot and click to place. Do this a couple times to add objects around it.

    ![1_gazebo_objects](img/1_gazebo_objects.png) 

    And now go back to Rviz and look at the camera window. You will see the objects pass in front as the robot turns! :bulb: If you can, position both windows so you can see the robot in Gazebo and the camera view from Rviz:

    ![1_both_apps](img/1_both_apps.png)

16. For the Hello World example, these are the basic operations of the robot and world. Before moving onto the next activity, let's take a look at some of the other things this simulation did.

17. First, close the Gazebo and Rviz windows and navigate back to the Simulation jobs page. From the simulation, under actions select *Cancel->Yes, Cancel* to stop the simulation. This gracefully terminates the simulation and stops charges. Go back to the list of simulation jobs and you should see the job in a *Cancelled* state. Click back into the job again, and under *Details* click on the *Simulation job output destination* link. This opens a new tab to S3 where this is folder corresponding to the simulation job ID. 

    Click into the folder, and then into the date/time stamped folder. Here you will three sets of outputs. The `gazebo-logs` folder contains the log files of the simulation applications output, while the `ros-logs` contains the robot applications output. The `ros-bags` will contain recordings of all events that can be used as simulation input for other tasks. For the simulation or robot application download one of the files and open locally. This will give you an idea of what types of events are saved for review or future use.

18. S3 contains the log files of the output of the applications but you can also get those from CloudWatch Logs.  Navigate to the CloudWatch console and select Logs from the left. In here you will see a Log Group names `/aws/robomaker/SimulationJobs`. Click on that, and then click on your simulations ID for either RobotApplicationLogs or SimulationApplicationLogs and view the entries.

## Activity wrap-up

In this activity, you have worked two of the main AWS RoboMaker products: Development environment and Simulation jobs. The Development environment provides a web-based cloud IDE with all main ROS packages and dependencies built in. You can create as many as needed, and when not in use, the IDE will automatically suspend itself to reduces costs. Here you can work to create, test and build/bundle your code.

When ready to test, the creation of Simulation job automates the process of combing the two applications, provides a web-based graphical interaction with your robot and the simulated world, and logs the output of all components in multiple manners.

Some of the key benefits of using AWS RoboMaker include:

*  Not limited to local resources - By using the cloud, AWS RoboMaker provides resources as needed and only for when you need them.
* Develop anywhere on any web-based device - By streaming the output of graphically intensive applications such as Gazebo instead of processing it locally, you can use a desktop, laptop, or even tablet to develop and interact with simulations.
* Scale - This activity showed a single simulation of an application. If the need to test a robot against different environments (simulations) is needed, or testing different iterations of robot applications against a single simulated environment, both of these can be done by scaling to multiple simulation jobs.

### Clean-up

In this activity, you created a Development environment, CloudWatch logs, and S3 objects that incure cost. Please follow the clean-up steps in the main. README document on how to remove these and stop any potential costs for occurring.
