//
//  BallViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 8/30/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "BallViewController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"

#import "MatchPadDatabase.h"
#import "Moves.h"

#import "BallView.h"
#import "BackgroundView.h"
#import "ShinyButton.h"
#import "MatchPadSponsor.h"

#import "AnimationTimer.h"

#import "UIConstants.h"


@implementation BallViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[backgroundView setStyle:BG_STYLE_TRANSPARENT_];

	// Add tap, double tap, pan and pinch for graph
	[self addTapRecognizerToView:ballView];
	[self addDoubleTapRecognizerToView:ballView];
	[self addPanRecognizerToView:ballView];
	[self addPinchRecognizerToView:ballView];

	// Add tap recognizers to buttons to prevent them bringing up ti;e controls
	//[self addTapRecognizerToView:allButton];
	//[self addTapRecognizerToView:seeLapsButton];
	
	[[MatchPadCoordinator Instance] AddView:ballView WithType:MPC_BALL_VIEW_];	
}

- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[MatchPadTitleBarController Instance] displayInViewController:self];
	
	[super viewWillAppear:animated];
	
	[self positionOverlays];

	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:( MPC_BALL_VIEW_ )];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:ballView];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] SetViewHidden:ballView];
	[[MatchPadCoordinator Instance] SetViewHidden:self];
	
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)prePositionOverlays
{
}

- (void) postPositionOverlays
{
}

- (void)positionOverlays
{
	[self addBackgroundFrames];
}

- (void)addBackgroundFrames
{
}


- (void)showOverlays
{
}

- (void)hideOverlays
{
}

////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////
// Gesture recognizers

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[UIButton class]]) // Prevents time controllers being invoked on button press
	{
		return;
	}
	
	[super OnTapGestureInView:gestureView AtX:x Y:y];
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[BallView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(BallView *)gestureView adjustScaleY:scale X:x Y:y];	
		else
			[(BallView *)gestureView adjustScaleX:scale X:x Y:y];	

		[(BallView *)gestureView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[BallView class]])
	{
		[(BallView *)gestureView setUserOffsetX:0.0];
		[(BallView *)gestureView setUserScaleX:1.0];
		[(BallView *)gestureView setUserOffsetY:0.0];
		[(BallView *)gestureView setUserScaleY:1.0];
		[(BallView *)gestureView RequestRedraw];
	}
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	if([gestureView isKindOfClass:[BallView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(BallView *)gestureView adjustPanY:y];
		else
			[(BallView *)gestureView adjustPanX:x];
		
		[(BallView *)gestureView RequestRedraw];
	}
}

- (void) OnDragGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state Recognizer:(UIDragDropGestureRecognizer *)recognizer
{
}

////////////////////////////////////////////////////
// Popup methods


- (void) willDisplay
{
	[self positionOverlays];
		
	[[MatchPadCoordinator Instance] SetViewDisplayed:ballView];
	
}

- (void) willHide
{
}

- (void) didDisplay
{
}

- (void) didHide
{
	[[MatchPadCoordinator Instance] SetViewHidden:ballView];
}

@end

