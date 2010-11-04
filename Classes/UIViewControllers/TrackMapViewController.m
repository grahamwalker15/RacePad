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
	track_map_view_ = (TrackMapView *)[self drawingView];

 	//[timing_view_ SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	//[timing_view_ SetRowHeight:28];
	//[timing_view_ SetHeading:true];
	
	//  Add extra gesture recognizers
	
	UIGestureRecognizer * recognizer;
	
    //	Tap recognizer for background
	recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleTapFrom:)];
	[recognizer setCancelsTouchesInView:false];
    [background_view_ addGestureRecognizer:recognizer];
    [recognizer release];
	
    //	Pinch recognizer for map
	recognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePinchFrom:)];
    [track_map_view_ addGestureRecognizer:recognizer];
    [recognizer release];
		
    // Pan recognizer for map
	recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(HandlePanFrom:)];
    [track_map_view_ addGestureRecognizer:recognizer];
    [recognizer release];

	[super viewDidLoad];
	[[RacePadCoordinator Instance] AddView:track_map_view_ WithType:RPC_TRACK_MAP_VIEW_];
	//[[RacePadCoordinator Instance] AddView:timing_view_ WithType:RPC_DRIVER_LIST_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	[background_view_ RequestRedraw];
	
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:track_map_view_];
	//[[RacePadCoordinator Instance] SetViewDisplayed:timing_view_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:track_map_view_];
	//[[RacePadCoordinator Instance] SetViewHidden:timing_view_];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	[background_view_ ReleaseBackground];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[background_view_ RequestRedraw];
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

- (void) OnGestureTapAtX:(float)x Y:(float)y
{
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
		[time_controller displayInViewController:self Animated:true];
	else
		[time_controller hide];
}

- (void) OnGestureDoubleTapAtX:(float)x Y:(float)y
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap setUserXOffset:0.0];
	[trackMap setUserYOffset:0.0];
	[trackMap setUserScale:1.0];
	
	[track_map_view_ RequestRedraw];
}

- (void) OnGesturePinchAtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	float currentUserPanX = [trackMap userXOffset];
	float currentUserPanY = [trackMap userYOffset];
	float currentUserScale = [trackMap userScale];
	float currentMapPanX = [trackMap mapXOffset];
	float currentMapPanY = [trackMap mapYOffset];
	float currentMapScale = [trackMap mapScale];
	float currentScale = currentUserScale * currentMapScale;
	
	if(abs(currentScale) < 0.001 || abs(scale) < 0.001)
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
	
	// Andset the user pan to put it back where it was on the screen
	float newPanX = x - new_x ;
	float newPanY = y - new_y ;
	
	[trackMap setUserXOffset:newPanX];
	[trackMap setUserYOffset:newPanY];
	[trackMap setUserScale:newUserScale];
	
	[track_map_view_ RequestRedraw];
}

- (void) OnGesturePanByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap setUserXOffset:[trackMap userXOffset] + x];
	[trackMap setUserYOffset:[trackMap userYOffset] + y];
	
	[track_map_view_ RequestRedraw];
}

@end
