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

@implementation TelemetryViewController


- (void)viewDidLoad
{
	// Set parameters for views
	RacePadDatabase *database = [RacePadDatabase Instance];
	Telemetry *telemetry = [database telemetry];

	if (telemetry)
	{
		[blueTelemetryView setCar:[telemetry blueCar]];
		[redTelemetryView setCar:[telemetry redCar]];
	}
	
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
	
    //	Tap, pinch, long press and pan recognizers for maps
	[self addTapRecognizerToView:blueTrackMapView];
	[self addPinchRecognizerToView:blueTrackMapView];
	[self addPanRecognizerToView:blueTrackMapView];
	[self addLongPressRecognizerToView:blueTrackMapView];
	
	[self addTapRecognizerToView:redTrackMapView];
	[self addPinchRecognizerToView:redTrackMapView];
	[self addPanRecognizerToView:redTrackMapView];
	[self addLongPressRecognizerToView:redTrackMapView];
	
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
	
	// Resize overlay views to match background
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[backgroundView RequestRedraw];
	[self positionOverlays];
	
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
	CGRect bg_frame = [backgroundView frame];
	
	[blueTelemetryView setFrame:CGRectMake(40, 40, bg_frame.size.width - 80, bg_frame.size.height / 2 - 45)];
	[redTelemetryView setFrame:CGRectMake(40, bg_frame.size.height / 2 + 5, bg_frame.size.width - 80, bg_frame.size.height / 2 - 45)];


	CGRect blue_frame = [blueTelemetryView frame];
	CGRect red_frame = [redTelemetryView frame];
	[blueTrackMapContainer setFrame:CGRectMake(blue_frame.size.width - 250, blue_frame.size.height / 2 - 120, 240, 240)];
	[redTrackMapContainer setFrame:CGRectMake(red_frame.size.width - 250, red_frame.size.height / 2 - 120, 240, 240)];
	
}


@end
