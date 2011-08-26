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
	
	NSTimer *popdownTimer;
	NSMutableArray *passThroughViews;
	
	bool bubblePref;
}

@property bool bubblePref;

+ (CommentaryBubble *)Instance;

- (void) showIfNeeded;
- (void) toggleShow;
- (void) popDown;
- (void) allowBubbles: (UIView *) view;
- (void) noBubbles;
- (void) resetBubbleTimings;

@end
