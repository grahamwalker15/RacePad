//
//  MatchPadDatabase.m
//  MatchPad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MatchPadDatabase.h"

@implementation MatchPadDatabase

@synthesize homeTeam;
@synthesize awayTeam;

static MatchPadDatabase *instance = nil;

+ (MatchPadDatabase *)Instance
{
	if ( instance == nil )
		instance = [[super allocWithZone:NULL] init];
	
	return instance;
}

@synthesize pitch;
@synthesize playerStatsData;

- (MatchPadDatabase *)init
{
	pitch = [[Pitch alloc] init];
	playerStatsData = [[TableData alloc] init];
	
	[self setHomeTeam:@"Home"];
	[self setAwayTeam:@"Away"];
	
	return self;
}

- (void) dealloc
{
	[pitch release];
	[playerStatsData release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	[self setHomeTeam:@"Home"];
	[self setAwayTeam:@"Away"];
	homeTeam = nil;
	awayTeam = nil;
}

@end
