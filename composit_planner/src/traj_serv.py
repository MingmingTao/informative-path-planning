#!/usr/bin/env python

# Copyright 2018 Massachusetts Institute of Technology

import rospy
import actionlib
from composit_planner.srv import *
from composit_planner.msg import *
from nav_msgs.msg import Path
from geometry_msgs.msg import *
from tf.transformations import quaternion_from_euler

class ExecuteDubinSeq():
	def __init__(self):
		#initialize node and callback
		rospy.init_node('execute_dubin')

		self.allowed_error = 0.5
		self.last_viable = None

		#subscribe to trajectory topic
		self.sub = rospy.Subscriber("/selected_trajectory", Path, self.handle_trajectory, queue_size=1)
		self.pose_sub = rospy.Subscriber("/pose", PoseStamped, self.handle_pose, queue_size=1)
		#access replan service to trigger when finished a trajectory
		self.replan = rospy.ServiceProxy('replan', RequestReplan)

		#create polygon object to send along
		self.path_pub = rospy.Publisher("/trajectory/current", PolygonStamped,
                                        queue_size=1)

		#spin until shutdown
		while not rospy.is_shutdown():
			rospy.spin()

	def handle_trajectory(self, traj):
		'''
		The trajectory comes in as a series of poses. It is assumed that the desired angle has already been determined
		'''
		print 'Executing new Trajectory'
		# self.client.cancel_goal()
		self.new_goals = traj.poses
		if len(self.new_goals) != 0:
		    msg = PolygonStamped()
		    msg.header.stamp = rospy.Time(0)
		    msg.header.frame_id = 'world'
		    points = []
		    for p in self.new_goals:
			points += [Point32(p.pose.position.x, p.pose.position.y, 0)]
		    msg.polygon.points = points
		    self.path_pub.publish(msg)
		    self.last_viable = self.new_goals[-1].pose
		else:
		    print 'No trajectory is viable, Triggering Replan'
		    self.replan()

	def handle_pose(self, msg):
		self.pose = msg
		if self.last_viable is not None:
		    if (msg.pose.position.x-self.last_viable.position.x)**2 + (msg.pose.position.y-self.last_viable.position.y)**2 < self.allowed_error**2:
			self.replan()


if __name__ == '__main__':
	try:
		ExecuteDubinSeq()
	except rospy.ROSInterruptException:
		rospy.loginfo("Navigation test finished.")