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

@interface MatchPadDatabase : BasePadDatabase
{
	Pitch *pitch;
	PlayerGraph *playerGraph;
	TableData *playerStatsData;
	
	NSString *homeTeam;
	NSString *awayTeam;
}

@property (retain) NSString *homeTeam;
@property (retain) NSString *awayTeam;
@property (readonly) Pitch *pitch;
@property (readonly) PlayerGraph *playerGraph;
@property (readonly) TableData *playerStatsData;

+ (MatchPadDatabase *)Instance;
- (void) clearStaticData;

@end
