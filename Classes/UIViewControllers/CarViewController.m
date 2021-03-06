//
//  CarViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 12/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CarViewController.h"

#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadTitleBarController.h"

#import "TelemetryHelpController.h"

#import "RacePadDatabase.h"
#import "Telemetry.h"

#import "TrackMapView.h"
#import "TelemetryView.h"
#import "CommentaryView.h"
#import "TrackProfileView.h"
#import "BackgroundView.h"
#import "ShinyButton.h"
#import "CommentaryBubble.h"
#import "DriverViewController.h"

#import "AnimationTimer.h"

#import "UIConstants.h"

@implementation CarViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	grabTitle = true;
	
	// Set parameters for views
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_CARBON_];
	
	trackMapExpanded = false;
	trackMapPinched = false;
	backupUserScale = 1.0;	// Used for switching track map mode between zoom and full
	[trackMapView setIsZoomView:true];
	[trackMapView setSmallSized:true];
	
	[trackMapView setUserScale:10.0];
	[trackMapContainer setStyle:BG_STYLE_TRANSPARENT_];
	
	[trackProfileView setUserScale:5.0];
	
	commentaryExpanded = false;
	commentaryAnimating = false;
	
	//  Add extra gesture recognizers
	
	//	Tap recognizer for background,pit window and telemetry views
	[self addTapRecognizerToView:backgroundView];
	[self addTapRecognizerToView:commentaryView];
	[self addTapRecognizerToView:trackProfileView];
	
    //	Tap, pinch, and double tap recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	[self addTapRecognizerToView:trackMapSizeButton];
	
	// Double tap, pan and pinch for pit window
	[self addDoubleTapRecognizerToView:trackProfileView];
	[self addPanRecognizerToView:trackProfileView];
	[self addPinchRecognizerToView:trackProfileView];
	
	// Double tap recognizer for expanding commentary view
	[self addDoubleTapRecognizerToView:commentaryView];
	
	[[RacePadCoordinator Instance] AddView:commentaryView WithType:RPC_COMMENTARY_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackProfileView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	
	// Set paramters for views
	[trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.3]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}


- (void)viewWillAppear:(BOOL)animated
{
	if ( grabTitle )
	{
		// Grab the title bar
		[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary: false];
	}
	
	[commentaryView SetBackgroundAlpha:0.5];
	
	animationTimer = nil;
	
	// Resize overlay views to match background
	[self showOverlays];
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	[[[RacePadDatabase Instance] commentary] setCommentaryFor:trackMapView.carToFollow];
	
	[commentaryView ResetScroll];
	[[RacePadCoordinator Instance] SetViewDisplayed:commentaryView];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackProfileView];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
	
	[[CommentaryBubble Instance] noBubbles];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	if(animationTimer)
		[animationTimer kill];
	
	[[RacePadCoordinator Instance] SetViewHidden:commentaryView];
	[[RacePadCoordinator Instance] SetViewHidden:trackProfileView];
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
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
	
	commentaryAnimating = true;
	
	[self prePositionOverlays];
	[trackProfileView setAlpha:0.0];
	[commentaryView setHidden:false];
	[trackProfileView setHidden:commentaryExpanded]; // Hidden if commentary expanded
	
	[self positionOverlays];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(viewAnimationDidStop:finished:context:)];
	[self postPositionOverlays];
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

- (HelpViewController *) helpController
{
	if(!helpController)
		helpController = [[TelemetryHelpController alloc] initWithNibName:@"TelemetryHelp" bundle:nil];
	
	return (HelpViewController *)helpController;
}

- (void) prePositionOverlays
{
	// Do this in the super class
}

- (void) postPositionOverlays
{
	// Do this in the super class
}

- (void)positionOverlays
{
	// Do this in the super class
}

- (void)addBackgroundFrames
{
	[backgroundView clearFrames];
	[backgroundView addFrame:[commentaryView frame]];
	
	if(!commentaryExpanded)
		[backgroundView addFrame:[trackProfileView frame]];
}

- (void)showOverlays
{
	[commentaryView setHidden:false];
	[trackMapContainer setHidden:false];
	[trackMapContainer setAlpha:1.0];
	[commentaryView setAlpha:1.0];
	
	if(!commentaryExpanded)
	{
		[trackProfileView setHidden:false];
		[trackProfileView setAlpha:1.0];
	}
}

- (void)hideOverlays
{
	[commentaryView setHidden:true];
	[trackProfileView setHidden:true];
	[trackMapContainer setHidden:true];
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[TrackMapView class]] || [gestureView isKindOfClass:[UIButton class]])
		return;
	
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
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
	else if([gestureView isKindOfClass:[TrackProfileView class]])
	{
		[(TrackProfileView *)gestureView adjustScale:scale X:x Y:y];	
		[(TrackProfileView *)gestureView RequestRedraw];
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
	else if([gestureView isKindOfClass:[TrackProfileView class]])
	{
		[(TrackProfileView *)gestureView setUserOffset:0.0];
		[(TrackProfileView *)gestureView setUserScale:5.0];
		[(TrackProfileView *)gestureView RequestRedraw];
	}
	else if([gestureView isKindOfClass:[commentaryView class]])
	{
		if(commentaryExpanded)
		{
			[self restoreCommentaryView];
		}
		else
		{
			[self expandCommentaryView];
		}
	}
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	if([gestureView isKindOfClass:[TrackProfileView class]])
	{
		[(TrackProfileView *)gestureView adjustPanX:x Y:y];	
		[(TrackProfileView *)gestureView RequestRedraw];
	}
}

- (IBAction) trackMapSizeChanged
{
	// do it in super class
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

- (void) expandCommentaryView
{
	if(commentaryAnimating)
		return;
	
	commentaryAnimating = true;
	
	CGRect commentaryFrame = [commentaryView frame];
	CGRect trackProfileFrame = [trackProfileView frame];
	
	float newHeight = trackProfileFrame.origin.y + trackProfileFrame.size.height - commentaryFrame.origin.y;
	
	CGRect newFrame = CGRectMake(commentaryFrame.origin.x, commentaryFrame.origin.y, commentaryFrame.size.width, newHeight);
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(commentaryExpansionDidStop:finished:context:)];
	[trackProfileView setAlpha:0.0];
	[commentaryView setFrame:newFrame];
	[UIView commitAnimations];
	
	commentaryExpanded = true;
}

- (void) restoreCommentaryView
{
	if(commentaryAnimating)
		return;
	
	commentaryAnimating = true;
	
	CGRect commentaryFrame = [commentaryView frame];
	CGRect trackProfileFrame = [trackProfileView frame];
	
	int inset = [backgroundView inset] + 10;
	float newHeight = trackProfileFrame.origin.y - inset * 2 - commentaryFrame.origin.y;
	
	CGRect newFrame = CGRectMake(commentaryFrame.origin.x, commentaryFrame.origin.y, commentaryFrame.size.width, newHeight);
	
	[trackProfileView setAlpha:0.0];
	[trackProfileView setHidden:false];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(commentaryRestorationDidStop:finished:context:)];
	[trackProfileView setAlpha:1.0];
	[commentaryView setFrame:newFrame];
	[UIView commitAnimations];
	
}

- (void) viewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	commentaryAnimating = false;		
}

- (void) commentaryExpansionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[trackProfileView setHidden:true];
		
		commentaryExpanded = true;
		commentaryAnimating = false;		
		
		[commentaryView RequestScrollToEnd];
		[commentaryView RequestRedraw];
		
		[self addBackgroundFrames];
		[backgroundView RequestRedraw];
	}
}

- (void) commentaryRestorationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		commentaryExpanded = false;
		commentaryAnimating = false;
		
		[commentaryView RequestScrollToEnd];
		[commentaryView RequestRedraw];
		
		[self addBackgroundFrames];
		[backgroundView RequestRedraw];
	}
}

@end

@implementation TelemetryCarViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//[mscButton setButtonColour:[UIColor colorWithRed:0.4 green:0.4 blue:0.8 alpha:1.0]];
	//[mscButton setSelectedButtonColour:[mscButton buttonColour]];
	//[mscButton setSelectedTextColour:[mscButton textColour]];
	
	//[rosButton setButtonColour:[UIColor colorWithRed:0.8 green:0.4 blue:0.4 alpha:1.0]];
	//[rosButton setSelectedButtonColour:[rosButton buttonColour]];
	//[rosButton setSelectedTextColour:[rosButton textColour]];
	
	/*
	 [[[RacePadDatabase Instance] commentary] setCommentaryFor:@"MSC"];
	 [trackMapView followCar:@"MSC"];
	 [trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.3]];
	 [telemetryView setCar:RPD_BLUE_CAR_];
	 [trackProfileView followCar:@"MSC"];
	 */
	
	grabTitle = false;
	
	[self chooseCar:[[RacePadCoordinator Instance] nameToFollow]];
	
	[self addTapRecognizerToView:telemetryView];
	[self addTapRecognizerToView:mscButton];
	[self addTapRecognizerToView:rosButton];
	
	[[RacePadCoordinator Instance] AddView:telemetryView WithType:RPC_TELEMETRY_VIEW_];	
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TELEMETRY_VIEW_ | RPC_PIT_WINDOW_VIEW_ | RPC_COMMENTARY_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	
	[[RacePadCoordinator Instance] SetViewDisplayed:telemetryView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	
	[[RacePadCoordinator Instance] SetViewHidden:telemetryView];
}

- (void)prePositionOverlays
{
	[telemetryView setAlpha:0.0];
	[telemetryView setHidden:false];
	
	[trackMapContainer setAlpha:0.0];
	[trackMapContainer setHidden:false];
	
	[trackProfileView setAlpha:0.0];
	[trackProfileView setHidden:false];
	
	[commentaryView setAlpha:0.0];
	[commentaryView setHidden:false];
}

- (void) postPositionOverlays
{
	[trackProfileView setAlpha:1.0];
	[commentaryView setAlpha:1.0];
	
	[trackMapContainer setAlpha:1.0];
	[telemetryView setAlpha:1.0];
}

- (void)positionOverlays
{
	// Get the device orientation and set things up accordingly
	int orientation = [[RacePadCoordinator Instance] deviceOrientation];
	
	int inset = [backgroundView inset] + 10;
	CGRect bg_frame = [backgroundView frame];
	
	int commentaryHeight = (orientation == UI_ORIENTATION_PORTRAIT_) ? 200 : 120;
	
	[telemetryView setFrame:CGRectMake(inset, inset, bg_frame.size.width - inset * 2, bg_frame.size.height / 2 - 20 - inset * 3)];
	
	if(commentaryExpanded)
		[commentaryView setFrame:CGRectMake(inset, bg_frame.size.height / 2 - 20, bg_frame.size.width - inset * 2, bg_frame.size.height / 2 + 20 - inset)];
	else
		[commentaryView setFrame:CGRectMake(inset, bg_frame.size.height / 2 - 20, bg_frame.size.width - inset * 2, commentaryHeight)];
	
	[trackProfileView setFrame:CGRectMake(inset, bg_frame.size.height / 2 + commentaryHeight - 20 + inset * 2, bg_frame.size.width - inset * 2, bg_frame.size.height / 2  - (commentaryHeight - 20) - inset * 3)];
	
	CGRect telemetry_frame = [telemetryView frame];
	
	float buttonOffset = (orientation == UI_ORIENTATION_PORTRAIT_) ? 140 : 160;
	[rosButton setCenter:CGPointMake(CGRectGetMidX(telemetry_frame) - buttonOffset - 20, 40) ];
	[mscButton setCenter:CGPointMake(CGRectGetMidX(telemetry_frame) + buttonOffset, 40) ];
	
	CGRect mapRect;
	CGRect normalMapRect;
	float mapWidth;
	float mapHeight;
	
	if(trackMapExpanded)
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 600 : 500;
		mapHeight = mapWidth / 2;
		mapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth - 10, telemetry_frame.origin.y + 10, mapWidth, mapHeight);
		float normalMapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		normalMapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - normalMapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - normalMapWidth) / 2, normalMapWidth, normalMapWidth);
	}
	else
	{
		mapWidth = (orientation == UI_ORIENTATION_PORTRAIT_) ? 240 : 220;
		mapHeight = mapWidth;
		mapRect = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth -10, telemetry_frame.origin.y + (telemetry_frame.size.height - mapWidth) / 2, mapWidth, mapWidth);
		normalMapRect = mapRect;
	}
	
	[trackMapContainer setFrame:mapRect];
	[telemetryView setMapRect:CGRectOffset(normalMapRect, -telemetry_frame.origin.x, -telemetry_frame.origin.y)];
	
	[trackMapView setFrame:CGRectMake(0,0, mapWidth, mapHeight)];
	[trackMapSizeButton setFrame:CGRectMake(4, mapHeight - 24, 20, 20)];
	
	[self addBackgroundFrames];
}

- (IBAction) chooseMSC:(id)sender
{
	[[RacePadCoordinator Instance] setNameToFollow:@"MSC"];
	[[[RacePadDatabase Instance] commentary] setCommentaryFor:@"MSC"];
	[trackMapView followCar:@"MSC"];
	[trackMapContainer setBackgroundColor:[UIColor colorWithRed:0.3 green:0.3 blue:1.0 alpha:0.3]];
	[telemetryView setCar:RPD_BLUE_CAR_];
	[trackProfileView setUserOffset:0.0];
	[trackProfileView setUserScale:5.0];
	[trackProfileView RequestRedraw];
	[trackProfileView followCar:@"MSC"];
	
	[commentaryView ResetScroll];
	[[RacePadCoordinator Instance] restartCommentary];
	[trackMapView RequestRedraw];
	[telemetryView RequestRedraw];
	[trackProfileView RequestRedraw];
	
	[mscButton setAlpha:1.0];
	[rosButton setAlpha:0.25];
	
	[title_ setTitle:@"MSC Telemetry"];
}

- (IBAction) chooseROS:(id)sender
{
	[[RacePadCoordinator Instance] setNameToFollow:@"ROS"];
	[[[RacePadDatabase Instance] commentary] setCommentaryFor:@"ROS"];
	[trackMapView followCar:@"ROS"];
	[trackMapContainer setBackgroundColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.3 alpha:0.3]];
	[telemetryView setCar:RPD_RED_CAR_];
	[trackProfileView setUserOffset:0.0];
	[trackProfileView setUserScale:5.0];
	[trackProfileView RequestRedraw];
	[trackProfileView followCar:@"ROS"];
	
	[commentaryView ResetScroll];
	[[RacePadCoordinator Instance] restartCommentary];
	[trackMapView RequestRedraw];
	[telemetryView RequestRedraw];
	[trackProfileView RequestRedraw];
	
	[mscButton setAlpha:0.25];
	[rosButton setAlpha:1.0];
	
	[title_ setTitle:@"ROS Telemetry"];
}

- (bool) supportsCar:(NSString *)name
{
	if ( [name isEqualToString: @"ROS"]
		|| [name isEqualToString: @"MSC"] )
		return true;
	
	return false;
}

- (void) chooseCar:(NSString *)name
{
	if ( [name isEqualToString: @"ROS"] )
		[self chooseROS:nil];
	else if ( [name isEqualToString: @"MSC"] )
		[self chooseMSC:nil];
}

- (void)addBackgroundFrames
{
	[super addBackgroundFrames];
	[backgroundView addFrame:[telemetryView frame]];
}

- (void)showOverlays
{
	[super showOverlays];
	[telemetryView setHidden:false];
}

- (void)hideOverlays
{
	[super hideOverlays];
	[telemetryView setHidden:true];
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
		animationRectEnd = CGRectMake(telemetry_frame.origin.x + telemetry_frame.size.width - mapWidth - 10, telemetry_frame.origin.y + 10, mapWidth, mapWidth/2);
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

- (IBAction)BackButton:(id)sender
{
	DriverViewController *parent = (DriverViewController *) [self parentViewController];
	[parent HideTelemetryAnimated:true];
}

@end

