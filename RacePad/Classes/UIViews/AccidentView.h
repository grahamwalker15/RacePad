//
//  AccidentView.h
//  RacePad
//
//  Created by Gareth Griffith on 1/18/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SimpleListView.h"

@class AccidentBubbleViewController;

@interface AccidentView : SimpleListView
{
	int lastRowCount;
	int lastHeight;
	int firstRow;
	
	bool updating;
	int currentRow;
	
	AccidentBubbleViewController *bubbleController;
}

@property int lastRowCount;
@property bool updating;
@property (nonatomic, retain) AccidentBubbleViewController *bubbleController;

- (void) initialDraw;
-(void) drawIfChanged;
-(void) countRows:(int *)count FirstRow:(int *)fRow;

@end