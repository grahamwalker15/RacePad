//
//  CodingView.h
//  MatchPad
//
//  Created by Simon Cuff on 15/04/2014.
//
//

#import <UIKit/UIKit.h>
#import "SimpleListView.h"

enum CodingFilter {
	CV_ALL_,
	CV_PERIOD_,
	CV_PLAYER_,
	CV_GOAL_,
	CV_KICK_,
	CV_CARD_,
	CV_OTHER_,
	CV_FOLLOW_,
};	// Keepin same order as segments in nib file

@interface CodingView : SimpleListView
{
	int filter;
	NSString *player;
    
	UIColor * defaultTextColour;
	UIColor * defaultBackgroundColour;
}

@property (retain) UIColor * defaultTextColour;
@property (retain) UIColor * defaultBackgroundColour;

-(void) setFilter:(int) type Player:(NSString *)player;
-(int) filteredRowToDataRow:(int)row;

@end