"""Bring up the Lean service server for the custom interfaces."""

from launch import LaunchDescription
from launch_ros.actions import Node


def generate_launch_description():
    return LaunchDescription([
        Node(
            package='rcllean_examples',
            executable='add-three-ints-server',
            name='add_three_ints_server',
            output='screen',
        ),
    ])
