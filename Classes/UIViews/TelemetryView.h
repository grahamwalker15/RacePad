//
//  TelemetryView.h
//  RacePad
//
//  Created by Gareth Griffith on 11/22/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DrawingView.h"

@class TelemetryCar;

@interface TelemetryView : DrawingView
{
	TelemetryCar * car;
}

@property (nonatomic, retain) TelemetryCar * car;

@end
