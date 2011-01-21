    //
//  CarViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CarViewController.h"

#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "RacePadDatabase.h"
#import "Telemetry.h"

#import "TrackMapView.h"
#import "TelemetryView.h"
#import "CommentaryView.h"
#import "PitWindowView.h"
#import "BackgroundView.h"

#import "AnimationTimer.h"

#import "UIConstants.h"

@implementation CarViewController

@synthesize car;

- (void)viewDidLoad
{
	// Set parameters for views
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	
	trackMapExpanded = false;
	trackMapPinched = false;
	backupUserScale = 1.0;	// Used for switching track map mode between zoom and full
	[trackMapView setIsZoomView:true];
	
	[trackMapView setUserScale:10.0];
	[trackMapContainer setStyle:BG_STYLE_TRANSPARENT_];
	
	//  Add extra gesture recognizers
	
	//	Tap recognizer for background,pit window and telemetry views
	[self addTapRecognizerToView:backgroundView];
	[self addTapRecognizerToView:telemetryView];
	[self addTapRecognizerToView:pitWindowView];
	
    //	Tap, pinch, and double tap recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	
	// Long press, double tap, pan and pinch for pit window
 	[self addLongPressRecognizerToView:pitWindowView];
	[self addDoubleTapRecognizerToView:pitWindowView];
	[self addPanRecognizerToView:pitWindowView];
	[self addPinchRecognizerToView:pitWindowView];
	
	[super viewDidLoad];
	
	[[RacePadCoordinator Instance] AddView:telemetryView WithType:RPC_TELEMETRY_VIEW_];
	[[RacePadCoordinator Instance] AddView:commentaryView WithType:RPC_COMMENTARY_VIEW_];
	[[RacePadCoordinator Instance] AddView:pitWindowView WithType:RPC_PIT_WINDOW_VIEW_];
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
		[pitWindowView setCar:RPD_BLUE_CAR_];
		[commentaryView setCar:RPD_BLUE_CAR_];
		[trackMapView followCar:@"MSC"];
		[trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.3]];
	}
	else
	{
		[telemetryView setCar:RPD_RED_CAR_];
		[pitWindowView setCar:RPD_RED_CAR_];
		[commentaryView setCar:RPD_RED_CAR_];
		[trackMapView followCar:@"ROS"];
		[trackMapContainer setBackgroundColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.3]];
	}
	
	[commentaryView SetBackgroundAlpha:0.5];
	
	animationTimer = nil;
	
	// Resize overlay views to match background
	[self showOverlays];
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
		
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TELEMETRY_VIEW_ | RPC_PIT_WINDOW_VIEW_ | RPC_COMMENTARY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	[[RacePadCoordinator Instance] SetViewDisplayed:telemetryView];
	[[RacePadCoordinator Instance] SetViewDisplayed:commentaryView];
	[[RacePadCoordinator Instance] SetViewDisplayed:pitWindowView];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	if(animationTimer)
		[animationTimer kill];
	
	[[RacePadCoordinator Instance] SetViewHidden:telemetryView];
	[[RacePadCoordinator Instance] SetViewHidden:commentaryView];
	[[RacePadCoordinator Instance] SetViewHidden:pitWindowView];
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if(animationTimer)
		[animationTimer kill];
	
	[self hideOverlays];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[backgroundView RequestRedraw];
	
	[commentaryView ScrollToEnd];
	
	[telemetryView setAlpha:0.0];
	[pitWindowView setAlpha:0.0];
	[trackMapContainer setAlpha:0.0];
	[telemetryView setHidden:false];
	[commentaryView setHidden:false];
	[pitWindowView setHidden:false];
	[trackMapContainer setHidden:false];
	
	[self positionOverlays];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[telemetryView setAlpha:1.0];
	[pitWindowView setAlpha:1.0];
	[commentaryView setAlpha:1.0];
	[trackMapContainer setAlpha:1.0];
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
	
	int inset = [backgroundView inset] + 10;
	CGRect bg_frame = [backgroundView frame];
	
	int commentaryHeight = (orientation == UI_ORIENTATION_PORTRAIT_) ? 120 : 80;
		
	[telemetryView setFrame:CGRectMake(inset, inset, bg_frame.size.width - inset * 2, bg_frame.size.height / 2 - 20 - inset * 3)];
	[commentaryView setFrame:CGRectMake(inset, bg_frame.size.height / 2 - 20, bg_frame.size.width - inset * 2, commentaryHeight)];
	[pitWindowView setFrame:CGRectMake(inset, bg_frame.size.height / 2 + commentaryHeight - 20 + inset * 2, bg_frame.size.width - inset * 2, bg_frame.size.height / 2  - (commentaryHeight - 20) - inset * 3)];
	
	CGRect telemetry_frame = [telemetryView frame];
	
	CGRect mapRect;
	CGRect normalMapRect;
	float mapWidth;
	
	if(trackMapExpanded)
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		mapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth - 10, telemetry_frame.origin.y + 10, mapWidth, mapWidth);
		float normalMapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		normalMapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - normalMapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - normalMapWidth) / 2, normalMapWidth, normalMapWidth);
	}
	else
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		mapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - mapWidth) / 2, mapWidth, mapWidth);
		normalMapRect = mapRect;
	}
	
	[trackMapContainer setFrame:mapRect];
	[telemetryView setMapRect:CGRectOffset(normalMapRect, -telemetry_frame.origin.x, -telemetry_frame.origin.y)];
	
	[trackMapView setFrame:CGRectMake(0,0, mapWidth, mapWidth)];
	[trackMapSizeButton setFrame:CGRectMake(4, mapWidth - 24, 20, 20)];
	
	
	[backgroundView clearFrames];
	[backgroundView addFrame:[telemetryView frame]];
	[backgroundView addFrame:[commentaryView frame]];
	[backgroundView addFrame:[pitWindowView frame]];
}

- (void)showOverlays
{
	[telemetryView setHidden:false];
	[commentaryView setHidden:false];
	[pitWindowView setHidden:false];
	[trackMapContainer setHidden:false];
	[telemetryView setAlpha:1.0];
	[trackMapContainer setAlpha:1.0];
	[commentaryView setAlpha:1.0];
	[pitWindowView setAlpha:1.0];
}

- (void)hideOverlays
{
	[telemetryView setHidden:true];
	[commentaryView setHidden:true];
	[pitWindowView setHidden:true];
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
		if(!trackMapExpanded)
		{
			RacePadDatabase *database = [RacePadDatabase Instance];
			TrackMap *trackMap = [database trackMap];
		
			[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:scale X:x Y:y];
			[(TrackMapView *)gestureView RequestRedraw];
			
			trackMapPinched = true;
		}
	}
	else if([gestureView isKindOfClass:[PitWindowView class]])
	{
		[(PitWindowView *)gestureView adjustScale:scale X:x Y:y];	
		[(PitWindowView *)gestureView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[TrackMapView class]])
	{
		if(trackMapExpanded || !trackMapPinched)
		{
			[self trackMapSizeChanged];
		}
		else
		{
			[(TrackMapView *)gestureView setUserScale:10.0];
			[(TrackMapView *)gestureView RequestRedraw];
			
			trackMapPinched = false;
		}
	}
	else if([gestureView isKindOfClass:[PitWindowView class]])
	{
		[(PitWindowView *)gestureView setUserOffset:0.0];
		[(PitWindowView *)gestureView setUserScale:1.0];
		[(PitWindowView *)gestureView RequestRedraw];
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
	
	if([gestureView isKindOfClass:[PitWindowView class]])
	{
		[(PitWindowView *)gestureView adjustPanX:x Y:y];	
		[(PitWindowView *)gestureView RequestRedraw];
	}
}

- (IBAction) trackMapSizeChanged
{
	// Make sure we don't animate twice
	if([trackMapView isAnimating])
		return;
	
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	CGRect telemetry_frame = [telemetryView frame];
	
	trackMapExpanded = !trackMapExpanded;
	
	animationRectStart = [trackMapContainer frame];
	
	if(trackMapExpanded)
	{
		float mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		animationRectEnd = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth - 10, telemetry_frame.origin.y + 10, mapWidth, mapWidth);
	}
	else
	{
		float mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		animationRectEnd = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - mapWidth) / 2, mapWidth, mapWidth);
	}
	
	[trackMapSizeButton setHidden:true];
	[[RacePadCoordinator Instance] DisableViewRefresh:trackMapView];

	[trackMapView setAnimationAlpha:0.0];
	[trackMapView setIsAnimating:true];
	[trackMapView setIsZoomView:true];
	[trackMapView setAnimationScaleTarget:backupUserScale];
	
	animationTimer = [[AnimationTimer alloc] initWithDuration:0.5 Target:self LoopSelector:@selector(trackMapSizeAnimationDidFire:) FinishSelector:@selector(trackMapSizeAnimationDidStop)];
}

- (void) trackMapSizeAnimationDidFire:(id)alphaPtr
{
	float alpha = * (float *)alphaPtr;
	
	float x = (1.0 - alpha) * animationRectStart.origin.x + alpha * animationRectEnd.origin.x;
	float y = (1.0 - alpha) * animationRectStart.origin.y + alpha * animationRectEnd.origin.y;
	float w = (1.0 - alpha) * animationRectStart.size.width + alpha * animationRectEnd.size.width;
	float h = (1.0 - alpha) * animationRectStart.size.height + alpha * animationRectEnd.size.height;
	
	[trackMapContainer setFrame:CGRectMake(x, y, w, h)];
	[trackMapView setFrame:CGRectMake(0, 0, w, h)];
	[trackMapView setAnimationAlpha:(trackMapExpanded ? sqrt (alpha) : alpha * alpha)];
	[trackMapView setAnimationDirection:(trackMapExpanded ? 1 : -1)];
	[trackMapContainer RequestRedraw];
}

- (void) trackMapSizeAnimationDidStop
{
	[trackMapContainer setFrame:animationRectEnd];
	[trackMapView setFrame:CGRectMake(0, 0, animationRectEnd.size.width, animationRectEnd.size.height)];

	[trackMapView setIsAnimating:false];
	float tempUserScale = [trackMapView userScale];
	[trackMapView setUserScale:backupUserScale];
	backupUserScale = tempUserScale;
	
	[animationTimer release];
	animationTimer = nil;
	
	if(trackMapExpanded)
	{
		[trackMapView setIsZoomView:false];
		[trackMapSizeButton setImage:[UIImage imageNamed:@"SmallScreen.png"] forState:UIControlStateNormal];
	}
	else
	{
		[trackMapView setIsZoomView:true];
		[trackMapSizeButton setImage:[UIImage imageNamed:@"FullScreen.png"] forState:UIControlStateNormal];
	}
	
	[trackMapSizeButton setFrame:CGRectMake(4, [trackMapContainer bounds].size.height - 24, 20, 20)];
	[trackMapSizeButton setHidden:false];

	[trackMapContainer RequestRedraw];
	[[RacePadCoordinator Instance] EnableViewRefresh:trackMapView];
}

@end

@implementation BlueCarViewController

- (void)viewDidLoad
{
	[self setCar:RPD_BLUE_CAR_];
	[super viewDidLoad];
}

@end

@implementation RedCarViewController

- (void)viewDidLoad
{
	[self setCar:RPD_RED_CAR_];
	[super viewDidLoad];
}

@end


