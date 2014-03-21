//
//  AlertView.h
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleListView.h"

enum AlertFilter {
	AV_ALL_,
	AV_PERIOD_,
	AV_PLAYER_,
	AV_GOAL_,
	AV_KICK_,
	AV_CARD_,
	AV_OTHER_,
	AV_FOLLOW_,
};	// Keepin same order as segments in nib file

@interface AlertView : SimpleListView
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
