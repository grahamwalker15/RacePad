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

 	//[timing_view_ SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	//[timing_view_ SetRowHeight:28];
	//[timing_view_ SetHeading:true];
	
	//  Add extra gesture recognizers
 
	//	Tap recognizer for background
	[self addTapRecognizerToView:background_view_];
	
    //	Pinch and pan recognizers for map
	[self addPinchRecognizerToView:trackMapView];
	[self addPanRecognizerToView:trackMapView];

	[super viewDidLoad];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	//[[RacePadCoordinator Instance] AddView:timing_view_ WithType:RPC_DRIVER_LIST_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Resize map view
	CGRect bg_frame = [background_view_ frame];
	CGRect map_frame = CGRectInset(bg_frame, 30, 30);
	[trackMapView setFrame:map_frame];
	
	// Force background refresh
	[background_view_ RequestRedraw];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	//[[RacePadCoordinator Instance] SetViewDisplayed:timing_view_];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	//[[RacePadCoordinator Instance] SetViewHidden:timing_view_];
	[[RacePadTitleBarController Instance] hide];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	[background_view_ ReleaseBackground];

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
	[background_view_ RequestRedraw];
	
	CGRect bg_frame = [background_view_ frame];
	CGRect map_frame = CGRectInset(bg_frame, 30, 30);
	[trackMapView setFrame:map_frame];
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
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
		[time_controller displayInViewController:self Animated:true];
	else
		[time_controller hide];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap setUserXOffset:0.0];
	[trackMap setUserYOffset:0.0];
	[trackMap setUserScale:1.0];
	
	[trackMapView RequestRedraw];
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	CGRect viewBounds = [gestureView bounds];
	CGSize viewSize = viewBounds.size;
	
	if(viewSize.width < 1 || viewSize.height < 1)
		return;
	
	float currentUserPanX = [trackMap userXOffset] * viewSize.width;
	float currentUserPanY = [trackMap userYOffset] * viewSize.height;
	float currentUserScale = [trackMap userScale];
	float currentMapPanX = [trackMap mapXOffset];
	float currentMapPanY = [trackMap mapYOffset];
	float currentMapScale = [trackMap mapScale];
	float currentScale = currentUserScale * currentMapScale;
	
	if(fabs(currentScale) < 0.001 || fabs(scale) < 0.001)
		return;
	
	// Calculate where the centre point is in the untransformed map
	float x_in_map = (x - currentUserPanX - currentMapPanX) / currentScale; 
	float y_in_map = (y - currentUserPanY - currentMapPanY) / currentScale;
	
	// Now work out the new scale	
	float newScale = currentScale * scale;
	float newUserScale = currentUserScale * scale;
	
	// Now work out where that point in the map would go now
	float new_x = (x_in_map) * newScale + currentMapPanX;
	float new_y = (y_in_map) * newScale + currentMapPanY;
	
	// And set the user pan to put it back where it was on the screen
	float newPanX = x - new_x ;
	float newPanY = y - new_y ;
	
	[trackMap setUserXOffset:newPanX / viewSize.width];
	[trackMap setUserYOffset:newPanY / viewSize.height];
	[trackMap setUserScale:newUserScale];
	
	[trackMapView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	CGRect viewBounds = [gestureView bounds];
	CGSize viewSize = viewBounds.size;
	
	if(viewSize.width < 1 || viewSize.height < 1)
		return;
	
	float newPanX = [trackMap userXOffset] * viewSize.width + x;
	float newPanY = [trackMap userYOffset] * viewSize.height + y;

	[trackMap setUserXOffset:newPanX / viewSize.width];
	[trackMap setUserYOffset:newPanY / viewSize.height];
	
	[trackMapView RequestRedraw];
}

@end
