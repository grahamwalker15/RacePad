//
//  AccidentBubble.h
//  BasePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TitleBarViewController.h"
#import "AccidentBubbleViewController.h"

@interface AccidentBubble : NSObject <UIPopoverControllerDelegate>
{
	AccidentBubbleViewController * accidentController;
	UIPopoverController * accidentPopover;
	
	UIView *accidentView;
	
	NSMutableArray *passThroughViews;
	
	bool bubblePref;
	
	bool shownBeforeRotate;
}

@property bool bubblePref;

+ (AccidentBubble *)Instance;

- (void) showIfNeeded;
- (void) toggleShow;
- (void) popDown;
- (void) allowBubbles: (UIView *) view;
- (void) noBubbles;
- (void) showNow;
- (void) willRotateInterface;
- (void) didRotateInterface;

@end
