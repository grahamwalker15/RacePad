//
//  HeadToHead.m
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "HeadToHead.h"
#import "DataStream.h"

@implementation HeadToHeadLap

@synthesize gap;
@synthesize pos0;
@synthesize pos1;
@synthesize pit0;
@synthesize pit1;

- (HeadToHeadLap *) initWithStream: (DataStream *) stream
{
	if ( [super init] == self )
	{
		pos0 = [stream PopInt];
		pit0 = [stream PopBool];
		pos1 = [stream PopInt];
		pit1 = [stream PopBool];
		gap = [stream PopFloat];
	}
	
	return self;
}

@end


@implementation HeadToHead

@synthesize driver0;
@synthesize driver1;
@synthesize abbr0;
@synthesize firstName0;
@synthesize surname0;
@synthesize teamName0;
@synthesize abbr1;
@synthesize firstName1;
@synthesize surname1;
@synthesize teamName1;
@synthesize completedLapCount;
@synthesize laps;

- (id) init
{
	if(self = [super init])
	{
		driver0 =nil;
		driver1 =nil;
		
		abbr0 = nil;
		firstName0 = nil;
		surname0 = nil;
		teamName0 = nil;
		abbr1 = nil;
		firstName1 = nil;
		surname1 = nil;
		teamName1 = nil;
		
		laps = [[NSMutableArray alloc] init];
	}	
	return self;
}

- (void) dealloc
{
	[self clearData];
	
	[super dealloc];
}

////////////////////////////////////////////////////////////////////////

- (void) clearData
{
	[driver0 release];
	[driver1 release];
	
	[abbr0 release];	
	[firstName0 release];
	[surname0 release];
	[teamName0 release];
	[abbr1 release];	
	[firstName1 release];
	[surname1 release];
	[teamName1 release];
	
	driver0 = nil;
	driver1 = nil;
	
	abbr0 = nil;
	firstName0 = nil;
	surname0 = nil;
	teamName0 = nil;
	abbr1 = nil;
	firstName1 = nil;
	surname1 = nil;
	teamName1 = nil;
	
	[laps release];
	laps = nil;
}

- (void) loadData : (DataStream *) stream
{
	[abbr0 release];	
	[firstName0 release];
	[surname0 release];
	[teamName0 release];
	[abbr1 release];	
	[firstName1 release];
	[surname1 release];
	[teamName1 release];
	[laps release];
	
	abbr0 = [[stream PopString] retain];
	firstName0 = [[stream PopString] retain];
	surname0 = [[stream PopString] retain];
	teamName0 = [[stream PopString] retain];
	abbr1 = [[stream PopString] retain];
	firstName1 = [[stream PopString] retain];
	surname1 = [[stream PopString] retain];
	teamName1 = [[stream PopString] retain];
	
	
	completedLapCount = [stream PopInt];
	totalLapCount = [stream PopInt];
	laps = [[NSMutableArray alloc] initWithCapacity:totalLapCount + 1];
	for ( int i = 0; i <= totalLapCount; i++ )
	{
		HeadToHeadLap *lap = [[HeadToHeadLap alloc] initWithStream: stream];
		[laps addObject:lap];
	}
}



@end
