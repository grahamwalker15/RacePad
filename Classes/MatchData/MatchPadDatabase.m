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
@synthesize positions;
@synthesize possession;
@synthesize moves;
@synthesize ball;
@synthesize playerGraph;
@synthesize playerStatsData;
@synthesize alertData;
@synthesize teamStatsData;

- (MatchPadDatabase *)init
{
	pitch = [[Pitch alloc] init];
	positions = [[Positions alloc] init];
	possession = [[Possession alloc] init];
	moves = [[Moves alloc] init];
	ball= [[Ball alloc] init];
	playerGraph = [[PlayerGraph alloc] init];
	playerStatsData = [[TableData alloc] init];
	teamStatsData = [[TeamStats alloc] init];
	alertData = [[AlertData alloc] init];
	
	[self setHomeTeam:@"Home"];
	[self setAwayTeam:@"Away"];
	
	return self;
}

- (void) dealloc
{
	[pitch release];
	[positions release];
	[possession release];
	[moves release];
	[ball release];
	[playerGraph release];
	[playerStatsData release];
	[teamStatsData release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	[self setHomeTeam:@"Home"];
	[self setAwayTeam:@"Away"];
	homeTeam = nil;
	awayTeam = nil;
	
	[alertData release];
	alertData = [[AlertData alloc] init];
}

@end
