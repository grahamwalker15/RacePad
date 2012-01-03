//
//  CommentaryBubble.h
//  BasePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarViewController.h"
#import "CommentaryBubbleViewController.h"

@interface CommentaryBubble : NSObject <UIPopoverControllerDelegate>
{
	CommentaryBubbleViewController * commentaryController;
	UIPopoverController * commentaryPopover;
	
	UIView *bubbleView;
	bool bottomRight;
	
	NSTimer *popdownTimer;
	NSMutableArray *passThroughViews;
	
	bool bubblePref;
	
	bool shownBeforeRotate;
}

@property bool bubblePref;

+ (CommentaryBubble *)Instance;

- (void) showIfNeeded;
- (void) toggleShow;
- (void) popDown;
- (void) allowBubbles: (UIView *) view BottomRight: (bool) br;
- (void) noBubbles;
- (void) resetBubbleTimings;
- (void) showNow;
- (void) willRotateInterface;
- (void) didRotateInterface;

@end
