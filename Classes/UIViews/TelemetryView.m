//
//  TelemetryView.m
//  RacePad
//
//  Created by Gareth Griffith on 11/22/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TelemetryView.h"
#import "RacePadDatabase.h"
#import "Telemetry.h"


@implementation TelemetryView

@synthesize car;
@synthesize mapRect;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

- (void)dealloc
{
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)Draw:(CGRect) rect
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	Telemetry *telemetry = [database telemetry];
	
	if ( telemetry && car >= 0)
	{
		[telemetry drawCar:car InView:self];
	}
}

@end
