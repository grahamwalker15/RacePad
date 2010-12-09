//
//  RacePrediction.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePrediction.h"
#import "DataStream.h"


@implementation RacePrediction

@synthesize count;
@synthesize user;
@synthesize score;
@synthesize position;
@synthesize equal;
@synthesize gameStatus;

- (id) init
{
	if(self = [super init])
	{
		count = 8;
		for ( int i = 0; i < 8; i++ )
			prediction[i] = -1;
		user = nil;
	}	   
	
	return self;
}

- (void) clear
{
	[user release];
	user = nil;
	for ( int i = 0; i < 8; i++ )
		prediction[i] = -1;
}

- (bool) load:(DataStream*)stream
{
	[self clear];
	user = [[stream PopString] retain];
	int c = [stream PopInt];
	for ( int i = 0; i < c; i++ )
	{
		int t = [stream PopInt];
		if ( i < 8 )
			prediction[i] = t;
	}
	
	bool notify = [stream PopBool];
	gameStatus = [stream PopUnsignedChar];
	score = [stream PopInt];
	position = [stream PopInt];
	equal = [stream PopBool];
	
	return notify;
}

- (int *) prediction
{
	return prediction;
}

- (void) dealloc
{
	[user release];
	[super dealloc];
}

@end

