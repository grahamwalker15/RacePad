    //
//  TelemetryViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/22/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TelemetryViewController.h"

#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "RacePadDatabase.h"
#import "Telemetry.h"

#import "TrackMapView.h"
#import "TelemetryView.h"
#import "BackgroundView.h"

#import "UIConstants.h"

@implementation TelemetryViewController


- (void)viewDidLoad
{
	// Set parameters for views
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	
	[blueTrackMapView setIsZoomView:true];
	[redTrackMapView setIsZoomView:true];
	
	[blueTrackMapView followCar:@"MSC"];
	[redTrackMapView followCar:@"ROS"];
	
	[blueTrackMapView setUserScale:10.0];
	[redTrackMapView setUserScale:10.0];
	
	[blueTrackMapContainer setStyle:BG_STYLE_TRANSPARENT_];
	[redTrackMapContainer setStyle:BG_STYLE_TRANSPARENT_];
	
	//  Add extra gesture recognizers
	
	//	Tap recognizer for background and telemetry views
	[self addTapRecognizerToView:backgroundView];
	[self addTapRecognizerToView:blueTelemetryView];
	[self addTapRecognizerToView:redTelemetryView];
	
    //	Tap, pinch, and double tap recognizers for maps
	[self addTapRecognizerToView:blueTrackMapView];
	[self addPinchRecognizerToView:blueTrackMapView];
	[self addDoubleTapRecognizerToView:blueTrackMapView];
	
	[self addTapRecognizerToView:redTrackMapView];
	[self addPinchRecognizerToView:redTrackMapView];
	[self addDoubleTapRecognizerToView:redTrackMapView];
	
    [super viewDidLoad];
 
	[[RacePadCoordinator Instance] AddView:blueTelemetryView WithType:RPC_TELEMETRY_VIEW_];
	[[RacePadCoordinator Instance] AddView:redTelemetryView WithType:RPC_TELEMETRY_VIEW_];
	[[RacePadCoordinator Instance] AddView:blueTrackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:redTrackMapView WithType:RPC_TRACK_MAP_VIEW_];

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
	[blueTelemetryView setCar:RPD_BLUE_CAR_];
	[redTelemetryView setCar:RPD_RED_CAR_];
	
	// Resize overlay views to match background
	[self showOverlays];
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TELEMETRY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	[[RacePadCoordinator Instance] SetViewDisplayed:blueTelemetryView];
	[[RacePadCoordinator Instance] SetViewDisplayed:redTelemetryView];
	[[RacePadCoordinator Instance] SetViewDisplayed:blueTrackMapView];
	[[RacePadCoordinator Instance] SetViewDisplayed:redTrackMapView];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:blueTelemetryView];
	[[RacePadCoordinator Instance] SetViewHidden:redTelemetryView];
	[[RacePadCoordinator Instance] SetViewHidden:blueTrackMapView];
	[[RacePadCoordinator Instance] SetViewHidden:redTrackMapView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideOverlays];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[backgroundView RequestRedraw];

	[blueTelemetryView setAlpha:0.0];
	[redTelemetryView setAlpha:0.0];
	[blueTelemetryView setHidden:false];
	[redTelemetryView setHidden:false];

	[self positionOverlays];

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[blueTelemetryView setAlpha:1.0];
	[redTelemetryView setAlpha:1.0];
	[UIView commitAnimations];
	
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
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	CGRect bg_frame = [backgroundView frame];
	
	int inset = [backgroundView inset] + 5;
	
	[blueTelemetryView setFrame:CGRectMake(inset, inset, bg_frame.size.width - inset * 2, bg_frame.size.height / 2 - inset - 5)];
	[redTelemetryView setFrame:CGRectMake(inset, bg_frame.size.height / 2 + 5, bg_frame.size.width - inset * 2, bg_frame.size.height / 2 - inset - 5)];
	
	CGRect blue_frame = [blueTelemetryView frame];
	CGRect red_frame = [redTelemetryView frame];
	
	int mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		
	CGRect blueMapRect = CGRectMake(blue_frame.size.width - mapWidth -10, (blue_frame.size.height - mapWidth) / 2, mapWidth, mapWidth);
	CGRect redMapRect = CGRectMake(red_frame.size.width - mapWidth -10, (red_frame.size.height - mapWidth) / 2, mapWidth, mapWidth);
	
	[blueTrackMapContainer setFrame:blueMapRect];
	[redTrackMapContainer setFrame:redMapRect];
	
	[blueTelemetryView setMapRect:blueMapRect];
	[redTelemetryView setMapRect:redMapRect];
	
	[blueTrackMapView setFrame:CGRectMake(0,0, mapWidth, mapWidth)];
	[blueTrackMapView setFrame:CGRectMake(0,0, mapWidth, mapWidth)];
}

- (void)showOverlays
{
	[blueTelemetryView setHidden:false];
	[redTelemetryView setHidden:false];
	[blueTelemetryView setAlpha:1.0];
	[redTelemetryView setAlpha:1.0];
}

- (void)hideOverlays
{
	[blueTelemetryView setHidden:true];
	[redTelemetryView setHidden:true];
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	// Make sure we're on a map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:scale X:x Y:y];
	
	[(TrackMapView *)gestureView RequestRedraw];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on a map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
	
	[(TrackMapView *)gestureView setUserScale:10.0];
	[(TrackMapView *)gestureView RequestRedraw];
}

@end
