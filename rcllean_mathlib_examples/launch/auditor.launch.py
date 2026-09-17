"""
Bring up the Lean heartbeat publisher from rcllean_examples and the auditor.

    ros2 launch rcllean_mathlib_examples auditor.launch.py
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
            package='rcllean_mathlib_examples',
            executable='heartbeat-auditor',
            name='heartbeat_auditor',
            namespace=namespace,
            output='screen',
        ),
    ])
