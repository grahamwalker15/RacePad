//
//  DrivingViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrivingViewController.h"

#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "RacePadDatabase.h"
#import "Telemetry.h"

#import "TrackMapView.h"
#import "TelemetryView.h"
#import "BackgroundView.h"

#import "UIConstants.h"

@implementation DrivingViewController

@synthesize car;

- (void)viewDidLoad
{
	// Set parameters for views
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	
	[trackMapView setIsZoomView:true];
	[trackMapView setUserScale:10.0];
	[trackMapContainer setStyle:BG_STYLE_TRANSPARENT_];
	
	[telemetryView setDrivingMode:true];
	
	//  Add extra gesture recognizers
	
	//	Tap recognizer for background,pit window and telemetry views
	[self addTapRecognizerToView:backgroundView];
	[self addTapRecognizerToView:telemetryView];
	[self addTapRecognizerToView:stop];
	
    //	Tap, pinch, and double tap recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	
	[super viewDidLoad];
	
	[[RacePadCoordinator Instance] AddView:telemetryView WithType:RPC_TELEMETRY_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}


- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Set paramters for views

	if(car == RPD_BLUE_CAR_)
	{
		[telemetryView setCar:RPD_BLUE_CAR_];
		[trackMapView followCar:@"MSC"];
		[trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.3]];
	}
	else
	{
		[telemetryView setCar:RPD_RED_CAR_];
		[trackMapView followCar:@"ROS"];
		[trackMapContainer setBackgroundColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.3]];
	}
	
	// Resize overlay views to match background
	[self showOverlays];
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
		
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TELEMETRY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	[[RacePadCoordinator Instance] SetViewDisplayed:telemetryView];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:telemetryView];
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	// [self hideOverlays];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	/*
	[backgroundView RequestRedraw];
	
	[telemetryView setAlpha:0.0];
	[trackMapContainer setAlpha:0.0];
	[telemetryView setHidden:false];
	[trackMapContainer setHidden:false];
	
	[self positionOverlays];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[telemetryView setAlpha:1.0];
	[trackMapContainer setAlpha:1.0];
	[UIView commitAnimations];
	*/
	
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)positionOverlays
{
	int inset = [backgroundView inset] + 10;
	CGRect bg_frame = [backgroundView frame];
	float mapWidth = bg_frame.size.width - inset * 2;
	float mapHeight = bg_frame.size.height / 2 - inset;
	
	[telemetryView setFrame:CGRectMake(inset, (bg_frame.size.height + inset) / 2, mapWidth, mapHeight)];
	
	CGRect telemetry_frame = [telemetryView frame];
	
	CGRect mapRect;
	CGRect normalMapRect;
	mapRect = CGRectMake(inset, inset, mapWidth, mapHeight);
	normalMapRect = mapRect;
	
	[trackMapContainer setFrame:mapRect];
	[telemetryView setMapRect:CGRectOffset(normalMapRect, -telemetry_frame.origin.x, -telemetry_frame.origin.y)];
	
	[trackMapView setFrame:CGRectMake(0,0, mapWidth, mapHeight)];
	
	[backgroundView clearFrames];
	[backgroundView addFrame:[telemetryView frame]];
}

- (void)showOverlays
{
	[telemetryView setHidden:false];
	[trackMapContainer setHidden:false];
	[telemetryView setAlpha:1.0];
	[trackMapContainer setAlpha:1.0];
}

- (void)hideOverlays
{
	[telemetryView setHidden:true];
	[trackMapContainer setHidden:true];
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[TrackMapView class]] || [gestureView isKindOfClass:[UIButton class]])
		return;
	
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
		[time_controller displayInViewController:self Animated:true];
	else
		[time_controller hide];
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[TrackMapView class]])
	{
		RacePadDatabase *database = [RacePadDatabase Instance];
		TrackMap *trackMap = [database trackMap];
	
		[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:scale X:x Y:y];
		[(TrackMapView *)gestureView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[TrackMapView class]])
	{
		[(TrackMapView *)gestureView setUserScale:10.0];
		[(TrackMapView *)gestureView RequestRedraw];
	}
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Will give info about car in pit window
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
}

- (IBAction) stopPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:NO];
}


@end


