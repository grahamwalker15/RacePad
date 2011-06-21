//
//  DrivingViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrivingViewController.h"

#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "RacePadDatabase.h"
#import "Telemetry.h"

#import "TrackMapView.h"
#import "TelemetryView.h"
#import "BackgroundView.h"
#import "TabletState.h"

#import "UIConstants.h"

@implementation DrivingViewController

@synthesize car;

- (void)viewDidLoad
{
	[super viewDidLoad];

	// Set parameters for views
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	
	[trackMapView setIsZoomView:true];
	[trackMapView setUserScale:10.0];
	[trackMapView setAutoRotate:true];
	[trackMapContainer setStyle:BG_STYLE_TRANSPARENT_];
	
	[telemetryView setDrivingMode:true];
	
	//  Add extra gesture recognizers
	
	//	Tap recognizer for background,pit window and telemetry views
	[self addTapRecognizerToView:backgroundView];
	[self addTapRecognizerToView:telemetryView];
	[self addTapRecognizerToView:trackMapView];
	[self addTapRecognizerToView:stop];
	[self addTapRecognizerToView:brake];
	[self addTapRecognizerToView:throttle];
	
    //	Tap, pinch, and double tap recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
		
	[[RacePadCoordinator Instance] AddView:telemetryView WithType:RPC_TELEMETRY_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	viewOrientation = interfaceOrientation;
    return !disableRotation;
}


- (void)viewWillAppear:(BOOL)animated
{
	disableRotation = YES;
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / 10)]; // 10 Hz update
	[[UIAccelerometer sharedAccelerometer] setDelegate:[TabletState Instance]];
	[[TabletState Instance] setBaseRotation: viewOrientation];
	
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TELEMETRY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];

	// Set paramters for views

	if(car == RPD_BLUE_CAR_)
	{
		[telemetryView setCar:RPD_BLUE_CAR_];
		[trackMapView followCar:@"MSC"];
		[trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.3]];
		[[[[RacePadDatabase Instance] telemetry] blueCar] resetDriving];
	}
	else
	{
		[telemetryView setCar:RPD_RED_CAR_];
		[trackMapView followCar:@"ROS"];
		[trackMapContainer setBackgroundColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.3]];
		[[[[RacePadDatabase Instance] telemetry] redCar] resetDriving];
	}
	
	// Resize overlay views to match background
	[self showOverlays];
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
		
	[[RacePadCoordinator Instance] SetViewDisplayed:telemetryView];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	disableRotation = NO;
	[[RacePadCoordinator Instance] SetViewHidden:telemetryView];
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	[[UIAccelerometer sharedAccelerometer] setDelegate:nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
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
	
	CGRect controlFrame = [brake frame];
	[brake setFrame:CGRectMake(0, bg_frame.size.height / 2 + 20, controlFrame.size.width, controlFrame.size.height)];
	[throttle setFrame:CGRectMake(bg_frame.size.width - controlFrame.size.width, bg_frame.size.height / 2 + 20, controlFrame.size.width, controlFrame.size.height)];
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
	if([gestureView isKindOfClass:[UIButton class]])
		return;
	
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
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

- (IBAction) controlPressed:(id)sender
{
	TelemetryCar *userCar;
	if ( car == RPD_BLUE_CAR_ )
		userCar = [[[RacePadDatabase Instance] telemetry] blueCar];
	else
		userCar = [[[RacePadDatabase Instance] telemetry] redCar];
	
	if ( sender == brake )
		[userCar setBrakePressed:true];
	else
		[userCar setThrottlePressed:true];
}

- (IBAction) controlReleased:(id)sender
{
	TelemetryCar *userCar;
	if ( car == RPD_BLUE_CAR_ )
		userCar = [[[RacePadDatabase Instance] telemetry] blueCar];
	else
		userCar = [[[RacePadDatabase Instance] telemetry] redCar];
	
	if ( sender == brake )
		[userCar setBrakePressed:false];
	else
		[userCar setThrottlePressed:false];
}


@end


