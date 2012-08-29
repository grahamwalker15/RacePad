//
//  MidasDatabase.m
//  MidasDemo
//
//  Created by Gareth Griffith on 8/28/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasDatabase.h"

@implementation MidasDatabase

static MidasDatabase *instance = nil;

+ (MidasDatabase *)Instance
{
	if ( instance == nil )
		instance = [[super allocWithZone:NULL] init];
	
	return instance;
}

@synthesize midasVoting;

- (MidasDatabase *)init
{
	if ( [super init] == self )
	{
		midasVoting = [[MidasVoting alloc] init];
	}
	
	return self;
}

- (void) dealloc
{
	[midasVoting release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	[super clearStaticData];
}

@end
