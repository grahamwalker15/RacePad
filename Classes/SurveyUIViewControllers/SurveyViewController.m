//
//  SurveyViewController.m
//  TrackSurvey
//
//  Created by Mark Riches 2/5/2011.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "SurveyViewController.h"

#import "TrackSurveyTitleBarController.h"
#import "SurveyView.h"
#import "BackgroundView.h"

@implementation SurveyViewController

@synthesize surveying;

static SurveyViewController *instance = nil;

+ (SurveyViewController *)Instance
{
	return instance;
}

- (id)init
{
	if(self = [super init])
	{
		instance = self;
		surveying = false;
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
	instance = self;
	surveying = false;

	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GRASS_];

	// Add gesture recognizers
 	[self addTapRecognizerToView:surveyView];
	[self addDoubleTapRecognizerToView:surveyView];
	[self addLongPressRecognizerToView:surveyView];
	
	//	Tap recognizer for background
	[self addTapRecognizerToView:backgroundView];
	[self addLongPressRecognizerToView:backgroundView];
	
    //	Pinch, long press and pan recognizers for map
	[self addPinchRecognizerToView:surveyView];
	[self addPanRecognizerToView:surveyView];
	// Don't zoom on corner for now - it's too confusing if you tap in the wrong place
	//[self addLongPressRecognizerToView:pitchView];

	[super viewDidLoad];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{	
	// Grab the title bar
	[[TrackSurveyTitleBarController Instance] displayInViewController:self];
	
	// Resize overlay views
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	corner = 0;
}

- (void)viewWillDisappear:(BOOL)animated
{
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
	[surveyView setFrame:map_frame];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[SurveyView class]])
	{
		return;
	}
		
	[(SurveyView *)gestureView setUserXOffset:0.0];
	[(SurveyView *)gestureView setUserYOffset:0.0];
	[(SurveyView *)gestureView setUserScale:1.0];	
	
	[surveyView RequestRedraw];
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
	if(!gestureView || ![gestureView isKindOfClass:[SurveyView class]])
	{
		return;
	}
	
	/*
	TrackSurveyDatabase *database = [TrackSurveyDatabase Instance];
	Pitch *pitch = [database pitch];
	
	[pitch adjustScaleInView:(PitchView *)gestureView Scale:scale X:x Y:y];
	*/
	
	[surveyView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	// If we're on the map, pan the map
	if(gestureView == surveyView)
	{
		/*
		TrackSurveyDatabase *database = [TrackSurveyDatabase Instance];
		Pitch *pitch = [database pitch];
		[pitch adjustPanInView:(PitchView *)gestureView X:x Y:y];
		*/
		[surveyView RequestRedraw];
	}
}

- (void) toggleSurveying
{
	if ( surveying )
	{
		[[TabletState Instance] stopTracking];
		[surveyView saveSurvey];
		surveying = false;
		[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	}
	else
	{
		[surveyView startSurvey];
		[[TabletState Instance] startTracking:self TrackType:TS_LOCATION | TS_HEADING];
		surveying = true;
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}

}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	static int counter = 0;
	counter++;
	double x, y, radius;
	[[TabletState Instance] currentPosition: &x Lat: &y Accuracy: &radius];
	
	if ( radius <= 10 )
	{
		[surveyView addPoint:x Lat:y];
		NSString * text = [[NSString alloc] initWithFormat: @"%10.6f : %10.6f (%5.1f) : %d", x, y, radius, counter];
		[surveyView setText: text];
	}
	else
		[surveyView setText: @"Please wait for more accurate position"];
		
	[surveyView RequestRedraw];
}

@end
