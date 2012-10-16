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

- (MidasDatabase *)init
{
	if ( self = [super init] )
	{
	}
	
	return self;
}

- (void) dealloc
{
	[super dealloc];
}

-(void) clearStaticData
{
	[super clearStaticData];
}

@end
