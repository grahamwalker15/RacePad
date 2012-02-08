//
//  CommentaryView.h
//  RacePad
//
//  Created by Gareth Griffith on 1/18/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleListView.h"

@class CommentaryBubbleViewController;

@interface CommentaryView : SimpleListView
{
	int lastRowCount;
	int lastHeight;
	int firstRow;
	float timeWindow;
	bool smallFont;
	bool midasStyle;
	int minPriority;
	double lastUpdateTime;
	
	float latestMessageTime;
	float firstMessageTime;
	float firstDisplayedTime;
	float lastDisplayedTime;
	int currentRow;
	bool updating;
	
	CommentaryBubbleViewController *bubbleController;
}

@property float timeWindow;
@property bool smallFont;
@property bool midasStyle;
@property int minPriority;
@property double lastUpdateTime;
@property float latestMessageTime;
@property float firstMessageTime;
@property float firstDisplayedTime;
@property float lastDisplayedTime;
@property int lastRowCount;
@property bool updating;
@property (nonatomic, retain) CommentaryBubbleViewController *bubbleController;

- (void) initialDraw;
-(void) drawIfChanged;
-(void) countRows:(int *)count FirstRow:(int *)fRow;

- (void) resetTimings;

@end