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
#import "PlayerGraph.h"
#import "AlertData.h"
#import "Possession.h"
#import "Moves.h"
#import "Ball.h"

@interface MatchPadDatabase : BasePadDatabase
{
	Pitch *pitch;
	PlayerGraph *playerGraph;
	TableData *playerStatsData;
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
@property (readonly) Possession *possession;
@property (readonly) Moves *moves;
@property (readonly) Ball *ball;
@property (readonly) PlayerGraph *playerGraph;
@property (readonly) TableData *playerStatsData;
@property (readonly) AlertData *alertData;

+ (MatchPadDatabase *)Instance;
- (void) clearStaticData;

@end
