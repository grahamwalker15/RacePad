//
//  AlertData.m
//  MatchPad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AlertData.h"
#import "DataStream.h"


@implementation AlertDataItem

@synthesize type;
@synthesize timeStamp;
@synthesize description;

- (AlertDataItem *) initWithStream:(DataStream*)stream
{
	type = [stream PopUnsignedChar];
	timeStamp = [stream PopFloat];
	description = [[stream PopString] retain];
	
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
		alerts = [[NSMutableArray alloc] init];
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

- (AlertDataItem *) itemAtIndex:(int)index
{
	if(index >= 0 && index < [alerts count])
		return (AlertDataItem *)[alerts objectAtIndex:index];
	else
		return nil;
}

- (void) loadData : (DataStream *) stream
{
	int count = [stream PopInt];
	for ( int i = 0; i < count; i++ )
	{
		int index = [stream PopInt];
		AlertDataItem *item = [[AlertDataItem alloc] initWithStream:stream];
		[alerts addObject:item];
	}
}

- (void) clearAll
{
	[alerts removeAllObjects];
}
				   
@end
