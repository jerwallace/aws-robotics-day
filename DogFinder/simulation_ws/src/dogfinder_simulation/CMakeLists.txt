cmake_minimum_required(VERSION 2.8.3)
project(dogfinder_simulation)

find_package(catkin REQUIRED COMPONENTS
  gazebo_ros
  turtlebot3_description    # required to install .rviz model
)

find_package(gazebo REQUIRED)

catkin_package(
  CATKIN_DEPENDS gazebo_ros
  DEPENDS gazebo
)

install(DIRECTORY launch worlds
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}
)

# Copy the rviz model for easier access in B9 RViz 
install(FILES ${turtlebot3_description_DIR}/../rviz/model.rviz
  DESTINATION ${CATKIN_PACKAGE_SHARE_DESTINATION}/rviz
  RENAME turtlebot3_model.rviz
)
