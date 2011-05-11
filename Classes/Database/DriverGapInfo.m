//
//  DriverGapInfo.m
//  RacePad
//
//  Created by Gareth Griffith on 5/10/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverGapInfo.h"
#import "DataStream.h"

@implementation DriverGapInfo

@synthesize requestedDriver;
@synthesize abbr;
@synthesize firstName;
@synthesize surname;
@synthesize teamName;
@synthesize position;
@synthesize inPit;
@synthesize stopped;
@synthesize carAhead;
@synthesize carBehind;
@synthesize gapAhead;
@synthesize gapBehind;

- (id) init
{
	if(self = [super init])
	{
		requestedDriver =nil;
		
		abbr = nil;
		firstName = nil;
		surname = nil;
		teamName = nil;

		position = 1;
		inPit = false;
		stopped = false;

		carAhead = nil;
		carBehind = nil;
		
		gapAhead = 0.0;
		gapBehind = 0.0;
		
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
	[requestedDriver release];
	
	[abbr release];	
	[firstName release];
	[surname release];
	[teamName release];
	[carAhead release];
	[carBehind release];
	
	requestedDriver = nil;
	
	abbr = nil;
	firstName = nil;
	surname = nil;
	teamName = nil;
	carAhead = nil;
	carBehind = nil;
	
	gapAhead = 0.0;
	gapBehind = 0.0;
	position = 1;
	inPit = false;
	stopped = false;

}

- (void) loadData : (DataStream *) stream
{
	abbr = [stream PopString];
	
	firstName = [stream PopString];
	surname = [stream PopString];
	teamName = [stream PopString];
	
	position = [stream PopInt];
	inPit = [stream PopBool];
	stopped = [stream PopBool];
	
	carAhead = [stream PopString];
	carBehind = [stream PopString];
	
	gapAhead = [stream PopFloat];
	gapBehind = [stream PopFloat];
}



@end
