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
@synthesize focus;
@synthesize description;

- (id) initWithType:(int)typeIn TimeStamp:(float)timeStampIn Focus:(int)focusIn Description:(NSString *)descriptionIn
{
	if(self = [super init])
	{
		type = typeIn;
		timeStamp = timeStampIn;
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
