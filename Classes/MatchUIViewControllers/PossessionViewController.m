//
//  PossessionViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 8/30/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "PossessionViewController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"

#import "MatchPadDatabase.h"
#import "Possession.h"

#import "PossessionView.h"
#import "BackgroundView.h"
#import "ShinyButton.h"
#import "MatchPadSponsor.h"

#import "AnimationTimer.h"

#import "UIConstants.h"


@implementation PossessionViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[backgroundView setStyle:BG_STYLE_TRANSPARENT_];

	// Add tap, double tap, pan and pinch for graph
	[self addTapRecognizerToView:possessionView];
	[self addDoubleTapRecognizerToView:possessionView];
	[self addPanRecognizerToView:possessionView];
	[self addPinchRecognizerToView:possessionView];
	
	[[MatchPadCoordinator Instance] AddView:possessionView WithType:MPC_POSSESSION_VIEW_];	
	[[MatchPadCoordinator Instance] AddView:self WithType:MPC_POSSESSION_VIEW_];
}

- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[MatchPadTitleBarController Instance] displayInViewController:self];
	
	[super viewWillAppear:animated];
	
	[self positionOverlays];

	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:( MPC_POSSESSION_VIEW_ )];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:possessionView];
	[[MatchPadCoordinator Instance] SetViewDisplayed:self];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] SetViewHidden:possessionView];
	[[MatchPadCoordinator Instance] SetViewHidden:self];
	
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self positionOverlays];

	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)prePositionOverlays
{
}

- (void) postPositionOverlays
{
}

- (void)positionOverlays
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
	
	if([gestureView isKindOfClass:[PossessionView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(PossessionView *)gestureView adjustScaleY:scale X:x Y:y];	
		else
			[(PossessionView *)gestureView adjustScaleX:scale X:x Y:y];	

		[(PossessionView *)gestureView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[PossessionView class]])
	{
		[(PossessionView *)gestureView setUserOffsetX:0.0];
		[(PossessionView *)gestureView setUserScaleX:1.0];
		[(PossessionView *)gestureView setUserOffsetY:0.0];
		[(PossessionView *)gestureView setUserScaleY:1.0];
		[(PossessionView *)gestureView RequestRedraw];
	}
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	if([gestureView isKindOfClass:[PossessionView class]])
	{
		if(gestureStartPoint.x > [gestureView bounds].size.width - 50)
			[(PossessionView *)gestureView adjustPanY:y];
		else
			[(PossessionView *)gestureView adjustPanX:x];
		
		[(PossessionView *)gestureView RequestRedraw];
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
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:possessionView];
}

- (void) willHide
{
}

- (void) didDisplay
{
}

- (void) didHide
{
	[[MatchPadCoordinator Instance] SetViewHidden:possessionView];
}


@end

