//
//  PositionsViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PositionsViewController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadDatabase.h"
#import "TableDataView.h"
#import "PositionsView.h"
#import "BackgroundView.h"
#import "Pitch.h"

@implementation PositionsViewController

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
	// Set the types on the two map views
	[positionsView setIsZoomView:false];
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GRASS_];

	// Add gesture recognizers
 	[self addTapRecognizerToView:positionsView];
	[self addDoubleTapRecognizerToView:positionsView];
	[self addLongPressRecognizerToView:positionsView];
	
	//	Tap recognizer for background
	[self addTapRecognizerToView:backgroundView];
	[self addLongPressRecognizerToView:backgroundView];
	
    //	Pinch, long press and pan recognizers for map
	[self addPinchRecognizerToView:positionsView];
	[self addPanRecognizerToView:positionsView];
	// Don't zoom on corner for now - it's too confusing if you tap in the wrong place
	//[self addLongPressRecognizerToView:pitchView];

	[super viewDidLoad];
	
	[[MatchPadCoordinator Instance] AddView:positionsView WithType:MPC_POSITIONS_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[MatchPadTitleBarController Instance] displayInViewController:self];
	
	// Register the views
	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:(MPC_POSITIONS_VIEW_)];
	
	// Resize overlay views
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:positionsView];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] SetViewHidden:positionsView];
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideOverlays];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[backgroundView RequestRedraw];
	
	[self positionOverlays];
	[self showOverlays];
	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{	
    [super viewDidUnload];
}

////////////////////////////////////////////////////////////////////////////

- (HelpViewController *) helpController
{
	/*
	if(!helpController)
		helpController = [[MapHelpController alloc] initWithNibName:@"MapHelp" bundle:nil];
	*/
	
	return (HelpViewController *)helpController;
}

- (void) showOverlays
{	
}

- (void) hideOverlays
{
}

- (void) positionOverlays
{
	CGRect bg_frame = [backgroundView frame];
	CGRect map_frame = CGRectInset(bg_frame, 20, 20); // The grass is drawn 20 pixels inside the BGView
	[positionsView setFrame:map_frame];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];

}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[PositionsView class]])
	{
		return;
	}
		
	[(PositionsView *)gestureView setUserXOffset:0.0];
	[(PositionsView *)gestureView setUserYOffset:0.0];
	[(PositionsView *)gestureView setUserScale:1.0];	

	[positionsView RequestRedraw];
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Zooms on point in map, or chosen car in leader board
	if(!gestureView)
		return;
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[PitchView class]])
	{
		return;
	}
	
	MatchPadDatabase *database = [MatchPadDatabase Instance];
	Positions *positions = [database positions];
	
	[positions adjustScaleInView:(PositionsView *)gestureView Scale:scale X:x Y:y];
	
	[positionsView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	// If we're on the track map, pan the map
	if(gestureView == positionsView)
	{
		MatchPadDatabase *database = [MatchPadDatabase Instance];
		Positions *positions = [database positions];
		[positions adjustPanInView:(PositionsView *)gestureView X:x Y:y];	
		[positionsView RequestRedraw];
	}
}

@end
