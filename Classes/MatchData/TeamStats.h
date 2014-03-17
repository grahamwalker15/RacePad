//
//  TeamStats.h
//  MatchPad
//
//  Created by Mark Riches on 12/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;
@class TeamStatsView;
@class Team;
@class ImageList;

enum StatType {
	TS_PIE_CHART,
	TS_BAR_CHART
};

@interface TeamStat : NSObject
{
	unsigned char type;
	NSString *name;
	int home, away;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic) unsigned char type;
@property (nonatomic) int home;
@property (nonatomic) int away;

- (void) loadStat : (DataStream *) stream;

@end

@interface TeamStats : NSObject
{	
	NSMutableArray *stats;
	NSString *home;
	UIColor *homeColour;
	NSString *away;
	UIColor *awayColour;
	UIColor *textColour;
}

@property (nonatomic, retain) NSString * home;
@property (nonatomic, retain) NSString * away;
@property (nonatomic, retain) UIColor * homeColour;
@property (nonatomic, retain) UIColor * awayColour;

- (void) loadStats : (DataStream *) stream;

- (void) drawInView:(TeamStatsView *)view;

@end
