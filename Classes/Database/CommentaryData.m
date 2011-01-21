//
//  CommentaryData.m
//  RacePad
//
//  Created by Gareth Griffith on 1/19/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadDatabase.h"
#import "CommentaryData.h"

@implementation CommentaryData

- (void) fillWithDefaultData:(int)car
{
	if(car == RPD_BLUE_CAR_)
	{
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:1 TimeStamp:48600.3 Focus:@"" Description:@"GREEN LIGHT"];
		[self addItemWithType:ALERT_RACE_EVENT_ Lap:1 TimeStamp:50610.6 Focus:@"" Description:@"RACE START"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:1 TimeStamp:50681.1 Focus:@"MSC" Description:@"Michael overtook J.Trulli at turn 10"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:1 TimeStamp:50738.4 Focus:@"MSC" Description:@"Michael completed lap 1 in 14th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:1 TimeStamp:50738.4 Focus:@"MSC" Description:@"S.Yamamoto is 1.1s ahead.V.Petrov is 1.4s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 TimeStamp:50769.6 Focus:@"MSC" Description:@"Michael was overtaken by V.Petrov at turn 4"];
		[self addItemWithType:ALERT_SAFETY_CAR_ Lap:2 TimeStamp:50823.5 Focus:@"" Description:@"SAFETY CAR DEPLOYED"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:2 TimeStamp:50880.3 Focus:@"MSC" Description:@"Michael completed lap 2 in 13th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:2 TimeStamp:50880.3 Focus:@"MSC" Description:@"Safety car out. K.Kobayashi is 0.6s ahead.J.Alguersuari is 0.8s behind."];
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:3 TimeStamp:51040.6 Focus:@"" Description:@"TRACK CLEAR"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:3 TimeStamp:51058.2 Focus:@"MSC" Description:@"Michael completed lap 3 in 12th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:3 TimeStamp:51058.2 Focus:@"MSC" Description:@"Safety car in. V.Petrov is 0.4s ahead.J.Trulli is 1.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:4 TimeStamp:51179.8 Focus:@"MSC" Description:@"Michael completed lap 4 in 12th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:4 TimeStamp:51179.8 Focus:@"MSC" Description:@"Lap time : 2:01.575. V.Petrov is 0.6s ahead.J.Trulli is 4.2s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:5 TimeStamp:51295.2 Focus:@"MSC" Description:@"Michael completed lap 5 in 12th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:5 TimeStamp:51295.2 Focus:@"MSC" Description:@"Lap time : 1:55.431. V.Petrov is 0.7s ahead.J.Trulli is 7.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:6 TimeStamp:51409.6 Focus:@"MSC" Description:@"Michael completed lap 6 in 12th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:6 TimeStamp:51409.6 Focus:@"MSC" Description:@"Lap time : 1:54.417. V.Petrov is 0.3s ahead.K.Kobayashi is 7.5s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:7 TimeStamp:51524.1 Focus:@"MSC" Description:@"Michael completed lap 7 in 12th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:7 TimeStamp:51524.1 Focus:@"MSC" Description:@"Lap time : 1:54.475. V.Petrov is 0.1s ahead.K.Kobayashi is 6.0s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:8 TimeStamp:51639.2 Focus:@"MSC" Description:@"Michael completed lap 8 in 12th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:8 TimeStamp:51639.2 Focus:@"MSC" Description:@"Lap time : 1:55.122. V.Petrov is 0.9s ahead.K.Kobayashi is 4.2s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:9 TimeStamp:51753.7 Focus:@"MSC" Description:@"Michael completed lap 9 in 12th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:9 TimeStamp:51753.7 Focus:@"MSC" Description:@"Lap time : 1:54.496. V.Petrov is 0.6s ahead.K.Kobayashi is 3.2s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:10 TimeStamp:51868.9 Focus:@"MSC" Description:@"Michael completed lap 10 in 11th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:10 TimeStamp:51868.9 Focus:@"MSC" Description:@"Lap time : 1:55.149. V.Petrov is 0.5s ahead.V.Liuzzi is 1.1s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:11 TimeStamp:51910.5 Focus:@"MSC" Description:@"Michael overtook N.Rosberg at turn 7"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:11 TimeStamp:51983.9 Focus:@"MSC" Description:@"Michael completed lap 11 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:11 TimeStamp:51983.9 Focus:@"MSC" Description:@"Lap time : 1:55.093. V.Petrov is 1.0s ahead.N.Rosberg is 0.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:12 TimeStamp:52097.6 Focus:@"MSC" Description:@"Michael completed lap 12 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:12 TimeStamp:52097.6 Focus:@"MSC" Description:@"Lap time : 1:53.663. V.Petrov is 0.8s ahead.N.Rosberg is 1.7s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:13 TimeStamp:52211.7 Focus:@"MSC" Description:@"Michael completed lap 13 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:13 TimeStamp:52211.7 Focus:@"MSC" Description:@"Lap time : 1:54.064. V.Petrov is 1.4s ahead.N.Rosberg is 2.0s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:14 TimeStamp:52325.4 Focus:@"MSC" Description:@"Michael completed lap 14 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:14 TimeStamp:52325.4 Focus:@"MSC" Description:@"Lap time : 1:53.771. V.Petrov is 1.9s ahead.N.Rosberg is 2.5s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:15 TimeStamp:52439.9 Focus:@"MSC" Description:@"Michael completed lap 15 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:15 TimeStamp:52439.9 Focus:@"MSC" Description:@"Lap time : 1:54.462. V.Petrov is 2.9s ahead.N.Rosberg is 2.2s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:16 TimeStamp:52554.6 Focus:@"MSC" Description:@"Michael completed lap 16 in 8th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:16 TimeStamp:52554.6 Focus:@"MSC" Description:@"Lap time : 1:54.682. N.Hulkenberg is 1.8s ahead.V.Petrov is 1.3s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:17 TimeStamp:52668.8 Focus:@"MSC" Description:@"Michael completed lap 17 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:17 TimeStamp:52668.8 Focus:@"MSC" Description:@"Lap time : 1:54.176. A.Sutil is 14.5s ahead.N.Rosberg is 2.3s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:18 TimeStamp:52782.3 Focus:@"MSC" Description:@"Michael completed lap 18 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:18 TimeStamp:52782.3 Focus:@"MSC" Description:@"Lap time : 1:53.521. A.Sutil is 14.7s ahead.N.Rosberg is 2.5s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:19 TimeStamp:52897.6 Focus:@"MSC" Description:@"Michael completed lap 19 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:19 TimeStamp:52897.6 Focus:@"MSC" Description:@"Lap time : 1:55.362. A.Sutil is 13.9s ahead.N.Rosberg is 2.1s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:20 TimeStamp:53011.6 Focus:@"MSC" Description:@"Michael completed lap 20 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:20 TimeStamp:53011.6 Focus:@"MSC" Description:@"Lap time : 1:53.954. A.Sutil is 12.9s ahead.N.Rosberg is 2.3s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:21 TimeStamp:53125.5 Focus:@"MSC" Description:@"Michael completed lap 21 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:21 TimeStamp:53125.5 Focus:@"MSC" Description:@"Lap time : 1:53.899. A.Sutil is 10.2s ahead.N.Rosberg is 1.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:22 TimeStamp:53238.4 Focus:@"MSC" Description:@"Michael completed lap 22 in 5th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:22 TimeStamp:53238.4 Focus:@"MSC" Description:@"Lap time : 1:52.927. M.Webber is 19.8s ahead.N.Rosberg is 1.9s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:23 TimeStamp:53351.7 Focus:@"MSC" Description:@"Michael completed lap 23 in 5th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:23 TimeStamp:53351.7 Focus:@"MSC" Description:@"Lap time : 1:53.247. F.Massa is 17.9s ahead.N.Rosberg is 1.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:24 TimeStamp:53464.2 Focus:@"MSC" Description:@"Michael completed lap 24 in 5th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:24 TimeStamp:53464.2 Focus:@"MSC" Description:@"Lap time : 1:52.489. F.Massa is 6.2s ahead.A.Sutil is 0.5s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:25 TimeStamp:53493.5 Focus:@"MSC" Description:@"Michael was overtaken by A.Sutil at turn 5"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:25 TimeStamp:53577.4 Focus:@"MSC" Description:@"Michael completed lap 25 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:25 TimeStamp:53577.4 Focus:@"MSC" Description:@"Lap time : 1:53.194. A.Sutil is 2.2s ahead.N.Rosberg is 1.2s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:26 TimeStamp:53689.5 Focus:@"MSC" Description:@"Michael completed lap 26 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:26 TimeStamp:53689.5 Focus:@"MSC" Description:@"Lap time : 1:52.117. A.Sutil is 3.6s ahead.N.Rosberg is 1.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:27 TimeStamp:53801.6 Focus:@"MSC" Description:@"Michael completed lap 27 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:27 TimeStamp:53801.6 Focus:@"MSC" Description:@"Lap time : 1:52.152. A.Sutil is 4.1s ahead.N.Rosberg is 2.0s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:28 TimeStamp:53913.7 Focus:@"MSC" Description:@"Michael completed lap 28 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:28 TimeStamp:53913.7 Focus:@"MSC" Description:@"Lap time : 1:52.098. A.Sutil is 4.5s ahead.N.Rosberg is 2.6s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:29 TimeStamp:54026.1 Focus:@"MSC" Description:@"Michael completed lap 29 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:29 TimeStamp:54026.1 Focus:@"MSC" Description:@"Lap time : 1:52.387. A.Sutil is 5.8s ahead.N.Rosberg is 2.3s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:30 TimeStamp:54138.4 Focus:@"MSC" Description:@"Michael completed lap 30 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:30 TimeStamp:54138.4 Focus:@"MSC" Description:@"Lap time : 1:52.305. A.Sutil is 6.8s ahead.N.Rosberg is 2.4s behind."];
		[self addItemWithType:ALERT_PIT_INSIGHT_ Lap:30 TimeStamp:54160.8 Focus:@"MSC" Description:@"Pit Insight : Weather will decide this race for us now."];
		[self addItemWithType:ALERT_PIT_INSIGHT_ Lap:30 TimeStamp:54160.8 Focus:@"MSC" Description:@"Pit Insight : We need rain in the next 3 to 4 laps."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:31 TimeStamp:54250.6 Focus:@"MSC" Description:@"Michael completed lap 31 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:31 TimeStamp:54250.6 Focus:@"MSC" Description:@"Lap time : 1:52.185. A.Sutil is 7.5s ahead.N.Rosberg is 1.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:32 TimeStamp:54362.5 Focus:@"MSC" Description:@"Michael completed lap 32 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:32 TimeStamp:54362.5 Focus:@"MSC" Description:@"Lap time : 1:51.914. A.Sutil is 8.4s ahead.N.Rosberg is 1.9s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:33 TimeStamp:54477.1 Focus:@"MSC" Description:@"Michael completed lap 33 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:33 TimeStamp:54477.1 Focus:@"MSC" Description:@"Lap time : 1:54.566. A.Sutil is 11.1s ahead.N.Rosberg is 2.6s behind."];
		[self addItemWithType:ALERT_PIT_STOP_ Lap:34 TimeStamp:54601.1 Focus:@"MSC" Description:@"Michael pitted on lap 34"];
		[self addItemWithType:ALERT_PIT_STOP_ Lap:34 TimeStamp:54605.7 Focus:@"ROS" Description:@"Nico pitted on lap 34"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:35 TimeStamp:54742.1 Focus:@"MSC" Description:@"Michael completed lap 35 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:35 TimeStamp:54742.1 Focus:@"MSC" Description:@"A.Sutil is 5.9s ahead.K.Kobayashi is 1.5s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:36 TimeStamp:54863.7 Focus:@"MSC" Description:@"Michael completed lap 36 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:36 TimeStamp:54863.7 Focus:@"MSC" Description:@"Lap time : 2:01.650. A.Sutil is 5.1s ahead.K.Kobayashi is 1.1s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:37 TimeStamp:54986.6 Focus:@"MSC" Description:@"Michael completed lap 37 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:37 TimeStamp:54986.6 Focus:@"MSC" Description:@"Lap time : 2:02.901. A.Sutil is 6.2s ahead.K.Kobayashi is 0.7s behind."];
		[self addItemWithType:ALERT_SAFETY_CAR_ Lap:38 TimeStamp:55067.4 Focus:@"" Description:@"SAFETY CAR DEPLOYED"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:38 TimeStamp:55116.5 Focus:@"MSC" Description:@"Michael completed lap 38 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:38 TimeStamp:55116.5 Focus:@"MSC" Description:@"Safety car out. A.Sutil is 5.1s ahead.K.Kobayashi is 0.9s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:39 TimeStamp:55283.8 Focus:@"MSC" Description:@"Michael completed lap 39 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:39 TimeStamp:55283.8 Focus:@"MSC" Description:@"Safety car out. A.Sutil is 0.9s ahead.K.Kobayashi is 0.4s behind."];
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:40 TimeStamp:55459.5 Focus:@"" Description:@"TRACK CLEAR"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:40 TimeStamp:55471.7 Focus:@"MSC" Description:@"Michael completed lap 40 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:40 TimeStamp:55471.7 Focus:@"MSC" Description:@"Safety car in. A.Sutil is 0.4s ahead.K.Kobayashi is 0.5s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:41 TimeStamp:55502.4 Focus:@"MSC" Description:@"Michael was overtaken by N.Rosberg at turn 4"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:41 TimeStamp:55599.7 Focus:@"MSC" Description:@"Michael completed lap 41 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:41 TimeStamp:55599.7 Focus:@"MSC" Description:@"Lap time : 2:08.008. N.Rosberg is 1.1s ahead.K.Kobayashi is 2.3s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:42 TimeStamp:55723.9 Focus:@"MSC" Description:@"Michael completed lap 42 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:42 TimeStamp:55723.9 Focus:@"MSC" Description:@"Lap time : 2:04.252. N.Rosberg is 2.1s ahead.K.Kobayashi is 2.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:43 TimeStamp:55846.7 Focus:@"MSC" Description:@"Michael completed lap 43 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:43 TimeStamp:55846.7 Focus:@"MSC" Description:@"Lap time : 2:02.735. N.Rosberg is 3.2s ahead.K.Kobayashi is 2.7s behind."];
		[self addItemWithType:ALERT_CHEQUERED_FLAG_ Lap:44 TimeStamp:55954.6 Focus:@"" Description:@"CHEQUERED FLAG"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:44 TimeStamp:55969.7 Focus:@"MSC" Description:@"Michael finished the race in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:44 TimeStamp:55969.7 Focus:@"MSC" Description:@"Lap time : 2:03.079. N.Rosberg is 3.3s ahead.K.Kobayashi is 1.0s behind."];
	}
	else
	{
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:1 TimeStamp:48600.3 Focus:@"" Description:@"GREEN LIGHT"];
		[self addItemWithType:ALERT_RACE_EVENT_ Lap:1 TimeStamp:50610.6 Focus:@"" Description:@"RACE START"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:1 TimeStamp:50649.4 Focus:@"ROS" Description:@"Nico overtook J.Alguersuari at turn 5"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:1 TimeStamp:50649.4 Focus:@"ROS" Description:@"Nico overtook V.Liuzzi at turn 5"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:1 TimeStamp:50653.3 Focus:@"ROS" Description:@"Nico overtook N.Hulkenberg at turn 6"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 TimeStamp:50731.2 Focus:@"ROS" Description:@"Nico was overtaken by N.Hulkenberg at turn 19"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:1 TimeStamp:50733.6 Focus:@"ROS" Description:@"Nico completed lap 1 in 9th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:1 TimeStamp:50733.6 Focus:@"ROS" Description:@"A.Sutil is 0.1s ahead.R.Barrichello is 2.2s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 TimeStamp:50741.7 Focus:@"ROS" Description:@"Nico was overtaken by J.Alguersuari at turn 1"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 TimeStamp:50764.0 Focus:@"ROS" Description:@"Nico overtook J.Alguersuari at turn 4"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:2 TimeStamp:50774.1 Focus:@"ROS" Description:@"Nico was overtaken by V.Liuzzi at turn 5"];
		[self addItemWithType:ALERT_SAFETY_CAR_ Lap:2 TimeStamp:50823.5 Focus:@"" Description:@"SAFETY CAR DEPLOYED"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:2 TimeStamp:50876.6 Focus:@"ROS" Description:@"Nico completed lap 2 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:2 TimeStamp:50876.6 Focus:@"ROS" Description:@"Safety car out. V.Liuzzi is 1.3s ahead.K.Kobayashi is 2.1s behind."];
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:3 TimeStamp:51040.6 Focus:@"" Description:@"TRACK CLEAR"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:3 TimeStamp:51057.1 Focus:@"ROS" Description:@"Nico completed lap 3 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:3 TimeStamp:51057.1 Focus:@"ROS" Description:@"Safety car in. V.Liuzzi is 0.3s ahead.V.Petrov is 0.7s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:4 TimeStamp:51177.9 Focus:@"ROS" Description:@"Nico completed lap 4 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:4 TimeStamp:51177.9 Focus:@"ROS" Description:@"Lap time : 2:00.843. V.Liuzzi is 0.3s ahead.V.Petrov is 1.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:5 TimeStamp:51293.8 Focus:@"ROS" Description:@"Nico completed lap 5 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:5 TimeStamp:51293.8 Focus:@"ROS" Description:@"Lap time : 1:55.874. V.Liuzzi is 0.6s ahead.V.Petrov is 0.9s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:6 TimeStamp:51408.4 Focus:@"ROS" Description:@"Nico completed lap 6 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:6 TimeStamp:51408.4 Focus:@"ROS" Description:@"Lap time : 1:54.697. V.Liuzzi is 0.5s ahead.V.Petrov is 0.9s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:7 TimeStamp:51522.9 Focus:@"ROS" Description:@"Nico completed lap 7 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:7 TimeStamp:51522.9 Focus:@"ROS" Description:@"Lap time : 1:54.432. V.Liuzzi is 0.4s ahead.V.Petrov is 0.9s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:8 TimeStamp:51637.8 Focus:@"ROS" Description:@"Nico completed lap 8 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:8 TimeStamp:51637.8 Focus:@"ROS" Description:@"Lap time : 1:54.895. V.Liuzzi is 0.5s ahead.V.Petrov is 0.7s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:9 TimeStamp:51752.6 Focus:@"ROS" Description:@"Nico completed lap 9 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:9 TimeStamp:51752.6 Focus:@"ROS" Description:@"Lap time : 1:54.884. V.Liuzzi is 0.3s ahead.V.Petrov is 0.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:10 TimeStamp:51868.0 Focus:@"ROS" Description:@"Nico completed lap 10 in 9th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:10 TimeStamp:51868.0 Focus:@"ROS" Description:@"Lap time : 1:55.360. N.Hulkenberg is 5.0s ahead.V.Petrov is 0.4s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:11 TimeStamp:51906.1 Focus:@"ROS" Description:@"Nico was overtaken by V.Petrov at turn 6"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:11 TimeStamp:51910.5 Focus:@"ROS" Description:@"Nico was overtaken by M.Schumacher at turn 7"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:11 TimeStamp:51984.8 Focus:@"ROS" Description:@"Nico completed lap 11 in 11th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:11 TimeStamp:51984.8 Focus:@"ROS" Description:@"Lap time : 1:56.798. M.Schumacher is 0.8s ahead.K.Kobayashi is 0.7s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:12 TimeStamp:52099.4 Focus:@"ROS" Description:@"Nico completed lap 12 in 11th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:12 TimeStamp:52099.4 Focus:@"ROS" Description:@"Lap time : 1:54.620. M.Schumacher is 1.8s ahead.K.Kobayashi is 0.5s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:13 TimeStamp:52213.6 Focus:@"ROS" Description:@"Nico completed lap 13 in 11th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:13 TimeStamp:52213.6 Focus:@"ROS" Description:@"Lap time : 1:54.202. M.Schumacher is 1.9s ahead.K.Kobayashi is 0.6s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:14 TimeStamp:52328.0 Focus:@"ROS" Description:@"Nico completed lap 14 in 11th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:14 TimeStamp:52328.0 Focus:@"ROS" Description:@"Lap time : 1:54.347. M.Schumacher is 2.5s ahead.K.Kobayashi is 1.1s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:15 TimeStamp:52442.2 Focus:@"ROS" Description:@"Nico completed lap 15 in 11th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:15 TimeStamp:52442.2 Focus:@"ROS" Description:@"Lap time : 1:54.225. M.Schumacher is 2.2s ahead.K.Kobayashi is 2.0s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:16 TimeStamp:52557.2 Focus:@"ROS" Description:@"Nico completed lap 16 in 10th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:16 TimeStamp:52557.2 Focus:@"ROS" Description:@"Lap time : 1:54.964. V.Petrov is -0.1s ahead.K.Kobayashi is 1.9s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:17 TimeStamp:52671.1 Focus:@"ROS" Description:@"Nico completed lap 17 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:17 TimeStamp:52671.1 Focus:@"ROS" Description:@"Lap time : 1:53.975. M.Schumacher is 2.3s ahead.K.Kobayashi is 1.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:18 TimeStamp:52784.8 Focus:@"ROS" Description:@"Nico completed lap 18 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:18 TimeStamp:52784.8 Focus:@"ROS" Description:@"Lap time : 1:53.637. M.Schumacher is 2.5s ahead.K.Kobayashi is 1.7s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:19 TimeStamp:52899.6 Focus:@"ROS" Description:@"Nico completed lap 19 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:19 TimeStamp:52899.6 Focus:@"ROS" Description:@"Lap time : 1:54.822. M.Schumacher is 2.1s ahead.K.Kobayashi is 1.7s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:20 TimeStamp:53013.9 Focus:@"ROS" Description:@"Nico completed lap 20 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:20 TimeStamp:53013.9 Focus:@"ROS" Description:@"Lap time : 1:54.352. M.Schumacher is 2.2s ahead.K.Kobayashi is 1.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:21 TimeStamp:53127.0 Focus:@"ROS" Description:@"Nico completed lap 21 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:21 TimeStamp:53127.0 Focus:@"ROS" Description:@"Lap time : 1:53.085. M.Schumacher is 1.4s ahead.K.Kobayashi is 1.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:22 TimeStamp:53240.4 Focus:@"ROS" Description:@"Nico completed lap 22 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:22 TimeStamp:53240.4 Focus:@"ROS" Description:@"Lap time : 1:53.341. M.Schumacher is 1.9s ahead.K.Kobayashi is 1.0s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:23 TimeStamp:53353.6 Focus:@"ROS" Description:@"Nico completed lap 23 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:23 TimeStamp:53353.6 Focus:@"ROS" Description:@"Lap time : 1:53.200. M.Schumacher is 1.8s ahead.A.Sutil is 0.3s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:24 TimeStamp:53382.1 Focus:@"ROS" Description:@"Nico was overtaken by A.Sutil at turn 5"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:24 TimeStamp:53466.5 Focus:@"ROS" Description:@"Nico completed lap 24 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:24 TimeStamp:53466.5 Focus:@"ROS" Description:@"Lap time : 1:52.946. A.Sutil is 1.8s ahead.K.Kobayashi is 1.6s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:25 TimeStamp:53578.7 Focus:@"ROS" Description:@"Nico completed lap 25 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:25 TimeStamp:53578.7 Focus:@"ROS" Description:@"Lap time : 1:52.175. M.Schumacher is 1.3s ahead.K.Kobayashi is 2.5s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:26 TimeStamp:53691.0 Focus:@"ROS" Description:@"Nico completed lap 26 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:26 TimeStamp:53691.0 Focus:@"ROS" Description:@"Lap time : 1:52.275. M.Schumacher is 1.4s ahead.K.Kobayashi is 2.6s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:27 TimeStamp:53803.9 Focus:@"ROS" Description:@"Nico completed lap 27 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:27 TimeStamp:53803.9 Focus:@"ROS" Description:@"Lap time : 1:52.929. M.Schumacher is 2.0s ahead.K.Kobayashi is 2.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:28 TimeStamp:53916.3 Focus:@"ROS" Description:@"Nico completed lap 28 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:28 TimeStamp:53916.3 Focus:@"ROS" Description:@"Lap time : 1:52.458. M.Schumacher is 2.5s ahead.K.Kobayashi is 2.7s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:29 TimeStamp:54028.4 Focus:@"ROS" Description:@"Nico completed lap 29 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:29 TimeStamp:54028.4 Focus:@"ROS" Description:@"Lap time : 1:52.102. M.Schumacher is 2.2s ahead.K.Kobayashi is 2.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:30 TimeStamp:54140.8 Focus:@"ROS" Description:@"Nico completed lap 30 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:30 TimeStamp:54140.8 Focus:@"ROS" Description:@"Lap time : 1:52.375. M.Schumacher is 2.3s ahead.K.Kobayashi is 3.1s behind."];
		[self addItemWithType:ALERT_PIT_INSIGHT_ Lap:30 TimeStamp:54160.8 Focus:@"ROS" Description:@"Pit Insight : Weather will decide this race for us now."];
		[self addItemWithType:ALERT_PIT_INSIGHT_ Lap:30 TimeStamp:54160.8 Focus:@"ROS" Description:@"Pit Insight : We need rain in the next 3 to 4 laps."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:31 TimeStamp:54252.5 Focus:@"ROS" Description:@"Nico completed lap 31 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:31 TimeStamp:54252.5 Focus:@"ROS" Description:@"Lap time : 1:51.688. M.Schumacher is 1.8s ahead.K.Kobayashi is 3.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:32 TimeStamp:54364.5 Focus:@"ROS" Description:@"Nico completed lap 32 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:32 TimeStamp:54364.5 Focus:@"ROS" Description:@"Lap time : 1:51.986. M.Schumacher is 1.9s ahead.K.Kobayashi is 3.4s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:33 TimeStamp:54479.8 Focus:@"ROS" Description:@"Nico completed lap 33 in 7th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:33 TimeStamp:54479.8 Focus:@"ROS" Description:@"Lap time : 1:55.285. M.Schumacher is 2.6s ahead.K.Kobayashi is 1.2s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:34 TimeStamp:54508.3 Focus:@"ROS" Description:@"Nico was overtaken by K.Kobayashi at turn 4"];
		[self addItemWithType:ALERT_PIT_STOP_ Lap:34 TimeStamp:54601.1 Focus:@"MSC" Description:@"Michael pitted on lap 34"];
		[self addItemWithType:ALERT_PIT_STOP_ Lap:34 TimeStamp:54605.7 Focus:@"ROS" Description:@"Nico pitted on lap 34"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:35 TimeStamp:54592.4 Focus:@"ROS" Description:@"Nico was overtaken by F.Alonso at turn 18"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:35 TimeStamp:54752.1 Focus:@"ROS" Description:@"Nico completed lap 35 in 9th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:35 TimeStamp:54752.1 Focus:@"ROS" Description:@"F.Alonso is 4.5s ahead.V.Petrov is 3.8s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:36 TimeStamp:54877.1 Focus:@"ROS" Description:@"Nico completed lap 36 in 9th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:36 TimeStamp:54877.1 Focus:@"ROS" Description:@"Lap time : 2:04.990. F.Alonso is 8.6s ahead.V.Petrov is 2.1s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:37 TimeStamp:55000.8 Focus:@"ROS" Description:@"Nico completed lap 37 in 9th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:37 TimeStamp:55000.8 Focus:@"ROS" Description:@"Lap time : 2:03.666. F.Alonso is 10.9s ahead.V.Petrov is 1.7s behind."];
		[self addItemWithType:ALERT_SAFETY_CAR_ Lap:38 TimeStamp:55067.4 Focus:@"" Description:@"SAFETY CAR DEPLOYED"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:38 TimeStamp:55132.8 Focus:@"ROS" Description:@"Nico completed lap 38 in 8th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:38 TimeStamp:55132.8 Focus:@"ROS" Description:@"Safety car out. K.Kobayashi is 15.3s ahead.V.Petrov is 3.1s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:39 TimeStamp:55285.9 Focus:@"ROS" Description:@"Nico completed lap 39 in 8th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:39 TimeStamp:55285.9 Focus:@"ROS" Description:@"Safety car out. K.Kobayashi is 1.5s ahead.V.Petrov is 2.1s behind."];
		[self addItemWithType:ALERT_GREEN_FLAG_ Lap:40 TimeStamp:55459.5 Focus:@"" Description:@"TRACK CLEAR"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:40 TimeStamp:55472.5 Focus:@"ROS" Description:@"Nico completed lap 40 in 8th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:40 TimeStamp:55472.5 Focus:@"ROS" Description:@"Safety car in. K.Kobayashi is 0.0s ahead.V.Petrov is 1.1s behind."];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:41 TimeStamp:55477.1 Focus:@"ROS" Description:@"Nico overtook K.Kobayashi at turn 1"];
		[self addItemWithType:ALERT_OVERTAKE_ Lap:41 TimeStamp:55502.4 Focus:@"ROS" Description:@"Nico overtook M.Schumacher at turn 4"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:41 TimeStamp:55598.8 Focus:@"ROS" Description:@"Nico completed lap 41 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:41 TimeStamp:55598.8 Focus:@"ROS" Description:@"Lap time : 2:06.280. A.Sutil is 0.6s ahead.M.Schumacher is 1.1s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:42 TimeStamp:55722.0 Focus:@"ROS" Description:@"Nico completed lap 42 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:42 TimeStamp:55722.0 Focus:@"ROS" Description:@"Lap time : 2:03.235. A.Sutil is 1.1s ahead.M.Schumacher is 2.2s behind."];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:43 TimeStamp:55843.7 Focus:@"ROS" Description:@"Nico completed lap 43 in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:43 TimeStamp:55843.7 Focus:@"ROS" Description:@"Lap time : 2:01.698. A.Sutil is 1.4s ahead.M.Schumacher is 3.2s behind."];
		[self addItemWithType:ALERT_CHEQUERED_FLAG_ Lap:44 TimeStamp:55954.6 Focus:@"" Description:@"CHEQUERED FLAG"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:44 TimeStamp:55966.6 Focus:@"ROS" Description:@"Nico finished the race in 6th place"];
		[self addItemWithType:ALERT_LAP_COMPLETE_ Lap:44 TimeStamp:55966.6 Focus:@"ROS" Description:@"Lap time : 2:02.894. A.Sutil is 3.2s ahead.M.Schumacher is 3.3s behind."];
	}
}

@end
