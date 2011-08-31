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
@property int minPriority;
@property double lastUpdateTime;
@property float latestMessageTime;
@property float firstMessageTime;
@property float firstDisplayedTime;
@property float lastDisplayedTime;
@property int lastRowCount;
@property bool updating;
@property (nonatomic, retain) CommentaryBubbleViewController *bubbleController;

- (void) initalDraw;
-(void) drawIfChanged;
-(void) countRows:(int *)count FirstRow:(int *)fRow;

- (void) resetTimings;

@end