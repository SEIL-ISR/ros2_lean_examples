cmake_minimum_required(VERSION 3.12)
project(rcllean_example_interfaces)

find_package(ament_cmake REQUIRED)
find_package(rosidl_default_generators REQUIRED)
find_package(std_msgs REQUIRED)

# Nothing here mentions Lean: rosidl_generator_lean registers with the rosidl
# pipeline and produces bindings alongside the C, C++ and Python ones.
rosidl_generate_interfaces(${PROJECT_NAME}
  "msg/Heartbeat.msg"
  "srv/AddThreeInts.srv"
  "action/Countdown.action"
  DEPENDENCIES std_msgs
)

ament_package()
