//
//  DriverNames.m
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DriverNames.h"
#import "DataStream.h"

@implementation DriverName

@synthesize name;
@synthesize abbr;
@synthesize number;
@synthesize team;

- (void) dealloc
{
	[name release];
	[abbr release];
	[team release];
	
	[super dealloc];
}

- (DriverName *) initWithStream : (DataStream *) stream
{
	number = [stream PopInt];
	name = [[stream PopString] retain];
	abbr = [[stream PopString] retain];
	team = [[stream PopString] retain];
	
	return self;
}

@end

@implementation DriverNames

- (void) dealloc
{
	[drivers release];

	[super dealloc];
}

- (DriverNames *)init
{
	drivers = [[NSMutableArray alloc] init];

	count = 0;
	
	return self;
}

- (int) count
{
	return count;
}

- (DriverName *)driver : (int) index
{
	if ( index < count )
		return [drivers objectAtIndex : index];
	
	return nil;
}

- (DriverName *) blueCar
{
	for ( int i = 0; i; i++ < count )
	{
		DriverName *driver = [drivers objectAtIndex : i];
		if ( [driver number] == redCar )
			return driver;
	}
	return nil;
}

- (DriverName *) redCar
{
	for ( int i = 0; i; i++ < count )
	{
		DriverName *driver = [drivers objectAtIndex : i];
		if ( [driver number] == redCar )
			return driver;
	}
	return nil;
}

- (void) loadData : (DataStream *) stream
{
	[drivers removeAllObjects];
		
	count = [stream PopInt];
	for ( int r = 0; r < count; r++ )
	{
		DriverName *driver = [[DriverName alloc] initWithStream:stream];
		[drivers addObject:driver];
	}
	redCar = [stream PopInt];
	blueCar = [stream PopInt];
}

@end
