//
//  TrackMapViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackMapViewController.h"
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
	trackMapView = (TrackMapView *)[self drawingView];
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];

 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	
	//  Add extra gesture recognizers
 
	//	Tap recognizer for background
	[self addTapRecognizerToView:backgroundView];
	
	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];

    //	Pinch, long press and pan recognizers for map
	[self addPinchRecognizerToView:trackMapView];
	[self addPanRecognizerToView:trackMapView];
	[self addLongPressRecognizerToView:trackMapView];

	[super viewDidLoad];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_DRIVER_LIST_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Resize overlay views
	CGRect bg_frame = [backgroundView frame];
	CGRect map_frame = CGRectInset(bg_frame, 30, 30);
	[trackMapView setFrame:map_frame];
	
	CGRect lb_frame = CGRectMake(map_frame.origin.x + 5, map_frame.origin.y, 60, map_frame.size.height);
	[leaderboardView setFrame:lb_frame];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
	//[[RacePadTitleBarController Instance] hide];
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
	
	CGRect bg_frame = [backgroundView frame];
	CGRect map_frame = CGRectInset(bg_frame, 30, 30);
	[trackMapView setFrame:map_frame];

	CGRect lb_frame = CGRectMake(map_frame.origin.x + 5, map_frame.origin.y, 60, map_frame.size.height);
	[leaderboardView setFrame:lb_frame];
	
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

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[leaderboardView class]])
	{
		RacePadDatabase *database = [RacePadDatabase Instance];
		TrackMap *trackMap = [database trackMap];	
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		[trackMap followCar:name];
		[trackMapView RequestRedraw];
		[leaderboardView RequestRedraw];
	}
	else
	{
		RacePadTimeController * time_controller = [RacePadTimeController Instance];
		
		if(![time_controller displayed])
			[time_controller displayInViewController:self Animated:true];
		else
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
		[(TrackMapView *)gestureView setUserScale:10.0];
		[(TrackMapView *)gestureView setUserXOffset:0.0];
		[(TrackMapView *)gestureView setUserYOffset:0.0];
	}
	else
	{
		float current_scale = [(TrackMapView *)gestureView userScale];
		float current_xoffset = [(TrackMapView *)gestureView userXOffset];
		float current_yoffset = [(TrackMapView *)gestureView userYOffset];
		
		if(current_scale == 1.0 && current_xoffset == 0.0 && current_yoffset == 0.0)
		{
			[trackMap followCar:nil];
			[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:10 X:x Y:y];
		}
		else
		{
			[trackMap followCar:nil];
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
	// Zooms on nearest car in map, or chosen car in leader board
	if(!gestureView)
		return;
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];	
	
	if([gestureView isKindOfClass:[TrackMapView class]])
	{
		[trackMap followCar:nil];
		
		float current_scale = [(TrackMapView *)gestureView userScale];
		if(current_scale > 0.001)
		{
			[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:10/current_scale X:x Y:y];
		}
	}
	else
	{
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		[trackMap followCar:name];
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

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap adjustPanInView:(TrackMapView *)gestureView X:x Y:y];
	
	[trackMapView RequestRedraw];
}

@end
