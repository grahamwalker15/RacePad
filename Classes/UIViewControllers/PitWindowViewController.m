//
//  PitWindowViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PitWindowViewController.h"
#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadDatabase.h"
#import "PitWindowView.h"
#import "BackgroundView.h"
#import "PitWindow.h"

#import "UIConstants.h"

@implementation PitWindowViewController

- (id)init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];

	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GRASS_];

	// Add gesture recognizers
 	[self addTapRecognizerToView:redPitWindowView];
	[self addLongPressRecognizerToView:redPitWindowView];
	
	[self addDoubleTapRecognizerToView:redPitWindowView];
	[self addPanRecognizerToView:redPitWindowView];
	[self addPinchRecognizerToView:redPitWindowView];
	
 	[self addTapRecognizerToView:bluePitWindowView];
	[self addLongPressRecognizerToView:bluePitWindowView];
	
	[self addDoubleTapRecognizerToView:bluePitWindowView];
	[self addPanRecognizerToView:bluePitWindowView];
	[self addPinchRecognizerToView:bluePitWindowView];
	
	//	Add tap recognizer for background
	[self addTapRecognizerToView:backgroundView];
	
	[[RacePadCoordinator Instance] AddView:redPitWindowView WithType:RPC_PIT_WINDOW_VIEW_];
	[[RacePadCoordinator Instance] AddView:bluePitWindowView WithType:RPC_PIT_WINDOW_VIEW_];
}

- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Set parameters for views
	[bluePitWindowView setCar:RPD_BLUE_CAR_];
	[redPitWindowView setCar:RPD_RED_CAR_];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_PIT_WINDOW_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	
	// Resize overlay view to match background
	int inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect pw_frame = CGRectInset(bg_frame, inset, inset);
	CGRect bottom_frame = CGRectMake(pw_frame.origin.x, pw_frame.origin.y + pw_frame.size.height / 2, pw_frame.size.width, pw_frame.size.height / 2);
	CGRect top_frame = CGRectMake(pw_frame.origin.x, pw_frame.origin.y, pw_frame.size.width, pw_frame.size.height / 2);
	[redPitWindowView setFrame:bottom_frame];
	[bluePitWindowView setFrame:top_frame];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	[[RacePadCoordinator Instance] SetViewDisplayed:redPitWindowView];
	[[RacePadCoordinator Instance] SetViewDisplayed:bluePitWindowView];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:redPitWindowView];
	[[RacePadCoordinator Instance] SetViewHidden:bluePitWindowView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[backgroundView RequestRedraw];
	
	int inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect pw_frame = CGRectInset(bg_frame, inset, inset);
	CGRect bottom_frame = CGRectMake(pw_frame.origin.x, pw_frame.origin.y + pw_frame.size.height / 2, pw_frame.size.width, pw_frame.size.height / 2);
	CGRect top_frame = CGRectMake(pw_frame.origin.x, pw_frame.origin.y, pw_frame.size.width, pw_frame.size.height / 2);
	[redPitWindowView setFrame:bottom_frame];
	[bluePitWindowView setFrame:top_frame];

	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	[(PitWindowView *)gestureView setUserOffset:0.0];
	[(PitWindowView *)gestureView setUserScale:1.0];	
	
	[(PitWindowView *)gestureView RequestRedraw];
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Will give info about car
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed 
{
	[(PitWindowView *)gestureView adjustScale:scale X:x Y:y];	
	[(PitWindowView *)gestureView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;

	[(PitWindowView *)gestureView adjustPanX:x Y:y];	
	[(PitWindowView *)gestureView RequestRedraw];
}

@end
