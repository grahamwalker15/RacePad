//
//  JogViewController.h
//  RacePad
//
//  Created by Gareth Griffith on 12/31/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

@interface JogControlView : UIView
{
	float angle;
	float change;
	id target;
	SEL selector;
}

@property (nonatomic) float angle;
@property (nonatomic) float change;
@property (nonatomic, retain) id target;
@property (nonatomic) SEL selector;

- (void)InitialiseMembers;
- (void)InitialiseImages;

- (void)JogAngleChanged;
- (float)value;

@end



@interface JogViewController : BasePadViewController
{
	IBOutlet JogControlView * jogControl;
	
	NSTimer *updateTimer;
}

@property (readonly) JogControlView * jogControl;

- (void) updateTimerCallback: (NSTimer *)theTimer;
- (void) killUpdateTimer;
@end