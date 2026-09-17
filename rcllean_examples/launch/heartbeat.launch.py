"""
Bring up the Lean heartbeat publisher and its monitor.

Nothing here is Lean-specific: the launch system resolves an executable to
<prefix>/lib/<package>/<executable>, which is where colcon-ros-lake installs
them.

    ros2 launch rcllean_examples heartbeat.launch.py
"""

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    namespace = LaunchConfiguration('namespace')

    return LaunchDescription([
        DeclareLaunchArgument(
            'namespace',
            default_value='',
            description='Namespace to push both nodes into.',
        ),
        Node(
            package='rcllean_examples',
            executable='heartbeat-publisher',
            name='heartbeat_publisher',
            namespace=namespace,
            output='screen',
        ),
        Node(
            package='rcllean_examples',
            executable='heartbeat-monitor',
            name='heartbeat_monitor',
            namespace=namespace,
            output='screen',
        ),
    ])
