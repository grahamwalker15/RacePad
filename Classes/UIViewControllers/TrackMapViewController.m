//
//  TrackMapViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackMapViewController.h"

#import "MapHelpController.h"

#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadDatabase.h"
#import "TableDataView.h"
#import "TrackMapView.h"
#import "LeaderboardView.h"
#import "BackgroundView.h"
#import "TrackMap.h"

@implementation TrackMapViewController

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
	[trackMapView setIsZoomView:false];
	[trackZoomView setIsZoomView:true];
	
	[trackZoomContainer setStyle:BG_STYLE_TRANSPARENT_];
	[trackZoomContainer setHidden:true];
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];

 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	[leaderboardView setAssociatedTrackMapView:trackZoomView];

	// Add gesture recognizers
 	[self addTapRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	
	//	Tap recognizer for background
	[self addTapRecognizerToView:backgroundView];
	
	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];

    //	Pinch, long press and pan recognizers for map
	[self addPinchRecognizerToView:trackMapView];
	[self addPanRecognizerToView:trackMapView];
	// Don't zoom on corner for now - it's too confusing if you tap in the wrong place
	//[self addLongPressRecognizerToView:trackMapView];

	// And  for the zoom map
	[self addTapRecognizerToView:trackZoomView];
	[self addDoubleTapRecognizerToView:trackZoomView];
	[self addPinchRecognizerToView:trackZoomView];
	
	// And add pan view to the trackZoomView to allow dragging the container
	[self addPanRecognizerToView:trackZoomView];

	[super viewDidLoad];
	
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackZoomView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	
	// Resize overlay views
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	// Set up zoom mapif necessary
	if([trackZoomView carToFollow] != nil)
	{
		[trackZoomView setUserScale:10.0];
		[trackZoomContainer setHidden:false];
	}
	
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] SetViewHidden:trackZoomView];
	[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
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
	if(!helpController)
		helpController = [[MapHelpController alloc] initWithNibName:@"MapHelp" bundle:nil];
	
	return (HelpViewController *)helpController;
}

- (void) showOverlays
{
	bool showZoomMap = ([trackZoomView carToFollow] != nil);
	
 	[leaderboardView setAlpha:0.0];
 	[leaderboardView setHidden:false];
	
	if(showZoomMap)
	{
		[trackZoomContainer setAlpha:0.0];
		[trackZoomContainer setHidden:false];
	}
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
  	[leaderboardView setAlpha:1.0];
	
	if(showZoomMap)
	{
		[trackZoomContainer setAlpha:1.0];
	}
	
	[UIView commitAnimations];
}

- (void) hideOverlays
{
	[leaderboardView setHidden:true];
	[trackZoomContainer setHidden:true];
}
- (void) showZoomMap
{
	[trackZoomContainer setAlpha:0.0];
	[trackZoomContainer setHidden:false];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[trackZoomContainer setAlpha:1.0];
	[UIView commitAnimations];
}

- (void) hideZoomMap
{
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[trackZoomContainer setAlpha:0.0];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideZoomMapAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[trackZoomContainer setHidden:true];
		[trackZoomContainer setAlpha:1.0];
		[trackZoomView setCarToFollow:nil];
		[leaderboardView RequestRedraw];
	}
}

- (void) positionOverlays
{
	int inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect map_frame = CGRectInset(bg_frame, inset, inset);
	[trackMapView setFrame:map_frame];
	
	CGRect lb_frame = CGRectMake(map_frame.origin.x + 5, map_frame.origin.y, 60, map_frame.size.height);
	[leaderboardView setFrame:lb_frame];
	
	CGRect zoom_frame = CGRectMake(map_frame.origin.x + 80, map_frame.origin.y + map_frame.size.height - 320, 300, 300);
	[trackZoomContainer setFrame:zoom_frame];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[leaderboardView class]])
	{
		bool zoomMapVisible = ([trackZoomView carToFollow] != nil);
		
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		
		if(name && [name length] > 0)
		{
			if([[trackZoomView carToFollow] isEqualToString:name])
			{
				[self hideZoomMap];
				[leaderboardView RequestRedraw];
			}
			else
			{
				[trackZoomView followCar:name];
				
				if(!zoomMapVisible)
					[self showZoomMap];
				
				[trackZoomView setUserScale:10.0];
				[trackZoomView RequestRedraw];
				[leaderboardView RequestRedraw];
			}
			
			return;
			
		}
		
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
	{
		[time_controller displayInViewController:self Animated:true];
	}
	else
	{
		[time_controller hide];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	if([(TrackMapView *)gestureView isZoomView])
	{
		[self hideZoomMap];
	}
	else
	{
		// Don't zoom on corner for now - it's too confusing if you tap in the wrong place
		/*
		float current_scale = [(TrackMapView *)gestureView userScale];
		float current_xoffset = [(TrackMapView *)gestureView userXOffset];
		float current_yoffset = [(TrackMapView *)gestureView userYOffset];
		
		if(current_scale == 1.0 && current_xoffset == 0.0 && current_yoffset == 0.0)
		{
			[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:10 X:x Y:y];
		}
		else
		*/
		{
			[(TrackMapView *)gestureView setUserXOffset:0.0];
			[(TrackMapView *)gestureView setUserYOffset:0.0];
			[(TrackMapView *)gestureView setUserScale:1.0];	
		}
	}
	
	[trackMapView RequestRedraw];
	[leaderboardView RequestRedraw];
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Zooms on point in map, or chosen car in leader board
	if(!gestureView)
		return;
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];	
	
	if([gestureView isKindOfClass:[TrackMapView class]])
	{
		float current_scale = [(TrackMapView *)gestureView userScale];
		// Don't zoom on corner for now - it's too confusing if you tap in the wrong place
		/*
		if(current_scale > 0.001)
		{
			[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:10/current_scale X:x Y:y];
		}
		*/
	}
	else if([gestureView isKindOfClass:[LeaderboardView class]])
	{
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		[[(LeaderboardView *)gestureView associatedTrackMapView] followCar:name];
		[trackZoomContainer setHidden:false];
		
	}
	
	[trackMapView RequestRedraw];
	[leaderboardView RequestRedraw];
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:scale X:x Y:y];
	
	[trackMapView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	// If we're on the track zoom, drag the container
	if(gestureView == trackZoomView)
	{
		CGRect frame = [trackZoomContainer frame];
		CGRect newFrame = CGRectOffset(frame, x, y);
		[trackZoomContainer setFrame:newFrame];
	}
		
	// If we're on the track map, pan the map
	if(gestureView == trackMapView)
	{
		RacePadDatabase *database = [RacePadDatabase Instance];
		TrackMap *trackMap = [database trackMap];
		[trackMap adjustPanInView:(TrackMapView *)gestureView X:x Y:y];	
		[trackMapView RequestRedraw];
	}
}

@end
