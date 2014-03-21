//
//  TelemetryView.h
//  RacePad
//
//  Created by Gareth Griffith on 11/22/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@interface TelemetryView : DrawingView
{
	int car;
	CGRect mapRect;
	bool drivingMode;
}

@property (nonatomic) int car;
@property (nonatomic) CGRect mapRect;
@property (nonatomic) bool drivingMode;

@end
