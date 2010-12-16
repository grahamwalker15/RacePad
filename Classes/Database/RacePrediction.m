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
@synthesize pin;
@synthesize score;
@synthesize position;
@synthesize equal;
@synthesize gameStatus;
@synthesize startTime;
@synthesize cleared;

- (id) init
{
	if(self = [super init])
	{
		count = 8;
		for ( int i = 0; i < 8; i++ )
		{
			prediction[i] = -1;
			scores[i] = 0;
		}
		user = nil;
		position = -1;
		cleared = true;
	}	   
	
	return self;
}

- (void) clear
{
	[user release];
	user = nil;
	for ( int i = 0; i < 8; i++ )
	{
		prediction[i] = -1;
		scores[i] = 0;
	}
	cleared = true;
}

- (bool) load:(DataStream*)stream
{
	NSString *name = [[stream PopString] retain];
	if ( !cleared && [user compare:name] == NSOrderedSame )
	{
		[self clear];
		cleared = false;
		user = name;
		pin = [stream PopInt];
		int c = [stream PopInt];
		for ( int i = 0; i < c; i++ )
		{
			int t = [stream PopInt];
			if ( i < 8 )
				prediction[i] = t;
		}
		
		bool notify = [stream PopBool];
		gameStatus = [stream PopUnsignedChar];
		startTime = [stream PopInt];
		score = [stream PopInt];
		position = [stream PopInt];
		equal = [stream PopBool];
		c = [stream PopInt];
		for ( int i = 0; i < c; i++ )
		{
			int t = [stream PopInt];
			if ( i < 8 )
				scores[i] = t;
		}
		
		return notify;
	}
	else
	{
		[name release];
		[stream PopInt];			// Pin
		int c = [stream PopInt];
		for ( int i = 0; i < c; i++ )
			[stream PopInt];		// Prediction
		
		bool n = [stream PopBool];	// Notify
		gameStatus = [stream PopUnsignedChar];
		startTime = [stream PopInt];
		[stream PopInt];			// score
		[stream PopInt];			// position
		[stream PopBool];			// equal
		c = [stream PopInt];
		for ( int i = 0; i < c; i++ )
			[stream PopInt];		// scores
		
		return n;
	}
}

- (void) setUser:(NSString *) name
{
	[user release];
	user = [name retain];
	cleared = false;
}

- (void) noUser
{
	[user release];
	user = nil;
	cleared = true;
}

- (void) loadStatus:(DataStream *)stream
{
	gameStatus = [stream PopUnsignedChar];
	startTime = [stream PopInt];
}

- (int *) prediction
{
	return prediction;
}

- (int *) scores
{
	return scores;
}

- (void) dealloc
{
	[user release];
	[super dealloc];
}

@end

