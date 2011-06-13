//
//  MatchPadDatabase.m
//  MatchPad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MatchPadDatabase.h"

@implementation MatchPadDatabase

static MatchPadDatabase *instance = nil;

+ (MatchPadDatabase *)Instance
{
	if ( instance == nil )
		instance = [[super allocWithZone:NULL] init];
	
	return instance;
}

@synthesize pitch;

- (MatchPadDatabase *)init
{
	pitch = [[Pitch alloc] init];
	
	return self;
}

- (void) dealloc
{
	[pitch release];
	
	[super dealloc];
}

-(void) clearStaticData
{
}

@end
