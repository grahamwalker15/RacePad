//
//  AlertData.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AlertData.h"


@implementation AlertDataItem

@synthesize type;
@synthesize timeStamp;
@synthesize lap;
@synthesize focus;
@synthesize description;

- (id) initWithType:(int)typeIn Lap:(int)lapIn TimeStamp:(float)timeStampIn Focus:(int)focusIn Description:(NSString *)descriptionIn
{
	if(self = [super init])
	{
		type = typeIn;
		lap = lapIn;
		timeStamp = timeStampIn;
		focus = focusIn;
		description = [descriptionIn retain];
	}	   
	
	return self;
}

- (id) initWithType:(int)typeIn Lap:(int)lapIn H:(float)hIn M:(float)mIn S:(float)sIn Focus:(int)focusIn Description:(NSString *)descriptionIn;
{
	if(self = [super init])
	{
		type = typeIn;
		lap = lapIn;
		timeStamp = hIn * 3600.0 + mIn * 60.0 + sIn;
		focus = focusIn;
		description = [descriptionIn retain];
	}	   
	
	return self;
}

- (void) dealloc
{
	[description release];
	[super dealloc];
}

@end

@implementation AlertData

- (id) init
{
	if(self = [super init])
	{
	}	   
	   
	return self;
}
	   
- (void) dealloc
{
	[alerts release];
	[super dealloc];
}
	   
- (int) itemCount
{
	return [alerts count];
}

@end
