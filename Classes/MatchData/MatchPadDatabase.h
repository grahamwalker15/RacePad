//
//  MatchPadDatabase.h
//  MatchPad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasePadDatabase.h"
#import "TableData.h"
#import "Pitch.h"
#import "Positions.h"
#import "PlayerGraph.h"
#import "AlertData.h"
#import "Possession.h"
#import "Moves.h"
#import "Ball.h"
#import "TeamStats.h"

@interface MatchPadDatabase : BasePadDatabase
{
	Pitch *pitch;
	Positions *positions;
	PlayerGraph *playerGraph;
	TableData *playerStatsData;
	TeamStats *teamStatsData;
	AlertData *alertData;
	Possession *possession;
	Moves *moves;
	Ball *ball;
	
	NSString *homeTeam;
	NSString *awayTeam;
}

@property (retain) NSString *homeTeam;
@property (retain) NSString *awayTeam;
@property (readonly) Pitch *pitch;
@property (readonly) Positions *positions;
@property (readonly) Possession *possession;
@property (readonly) Moves *moves;
@property (readonly) Ball *ball;
@property (readonly) PlayerGraph *playerGraph;
@property (readonly) TableData *playerStatsData;
@property (readonly) TeamStats *teamStatsData;
@property (readonly) AlertData *alertData;

+ (MatchPadDatabase *)Instance;
- (void) clearStaticData;

@end
