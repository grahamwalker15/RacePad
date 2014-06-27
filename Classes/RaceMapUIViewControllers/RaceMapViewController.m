//
//  RaceMapViewController.m
//  RaceMap
//
//  Created by Simon Cuff 17th June 2014
//  Copyright 2014 SBG Sports Software Ltd. All rights reserved.
//

#import "RaceMapViewController.h"

#import "RaceMapCoordinator.h"
#import "BasePadTimeController.h"
#import "RaceMapTitleBarController.h"
#import "RaceMapData.h"
#import "TableDataView.h"
#import "TrackMapView.h"
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
	[super viewDidLoad];

	// Set the types on the two map views
	[trackMapView setIsZoomView:false];
	[trackZoomView setIsZoomView:true];
	
	[trackZoomContainer setStyle:BG_STYLE_TRANSPARENT_];
	[trackZoomContainer setHidden:true];
	trackZoomOffsetX = 0;
	trackZoomOffsetY = 0;
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_CARBON_];

	// Add gesture recognizers
 	[self addTapRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	[self addLongPressRecognizerToView:trackMapView];
	
	//	Tap recognizer for background
	[self addTapRecognizerToView:backgroundView];
	[self addLongPressRecognizerToView:backgroundView];
	
	// Add tap and long press recognizers to the leaderboard
    //	Pinch, long press and pan recognizers for map
	[self addPinchRecognizerToView:trackMapView];
	[self addPanRecognizerToView:trackMapView];
	// Don't zoom on corner for now - it's too confusing if you tap in the wrong place
	//[self addLongPressRecognizerToView:trackMapView];

	// And  for the zoom map
	[self addTapRecognizerToView:trackZoomView];
	[self addDoubleTapRecognizerToView:trackZoomView];
	[self addPinchRecognizerToView:trackZoomView];
	
	// And add pan view to the trackZoomView to allow dragging the container
	[self addPanRecognizerToView:trackZoomView];
	
	[[RaceMapCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RaceMapCoordinator Instance] AddView:trackZoomView WithType:RPC_TRACK_MAP_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RaceMapTitleBarController Instance] displayInViewController:self SupportCommentary: true];
	
	// Register the views
	[[RaceMapCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	
	// Resize overlay views
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	// Set up zoom mapif necessary
	NSString *carToFollow = [[BasePadCoordinator Instance] nameToFollow];
	
	if(carToFollow == nil)
	{
		[trackZoomView setCarToFollow:nil];
		[trackZoomContainer setHidden:true];
	}
	else
	{
		[trackZoomView setUserScale:10.0];
		[trackZoomView followCar:carToFollow];
		[trackZoomContainer setHidden:false];
	}
	
	[[RaceMapCoordinator Instance] SetViewDisplayed:trackMapView];
	[[RaceMapCoordinator Instance] SetViewDisplayed:trackZoomView];
	[[RaceMapCoordinator Instance] SetViewDisplayed:leaderboardView];
    [trackMapView RequestRedraw];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[RaceMapCoordinator Instance] SetViewHidden:trackMapView];
	[[RaceMapCoordinator Instance] SetViewHidden:trackZoomView];
	[[RaceMapCoordinator Instance] SetViewHidden:leaderboardView];
	[[RaceMapCoordinator Instance] ReleaseViewController:self];
	
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

- (void) showOverlays
{
	bool showZoomMap = ([trackZoomView carToFollow] != nil);
	
 	[leaderboardView setAlpha:0.0];
 	[leaderboardView setHidden:false];
	
	if(showZoomMap)
	{
		[trackZoomContainer setAlpha:0.0];
		[trackZoomContainer setHidden:false];
	}
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
  	[leaderboardView setAlpha:1.0];
	
	if(showZoomMap)
	{
		[trackZoomContainer setAlpha:1.0];
	}
	
	[UIView commitAnimations];
}

- (void) hideOverlays
{
	[leaderboardView setHidden:true];
	[trackZoomContainer setHidden:true];
}
- (void) showZoomMap
{
	[trackZoomContainer setAlpha:0.0];
	[trackZoomContainer setHidden:false];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[trackZoomContainer setAlpha:1.0];
	[UIView commitAnimations];
}

- (void) hideZoomMap
{
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[trackZoomContainer setAlpha:0.0];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideZoomMapAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[trackZoomContainer setHidden:true];
		[trackZoomContainer setAlpha:1.0];
		[trackZoomView setCarToFollow:nil];
		[leaderboardView RequestRedraw];
	}
}

- (void) positionOverlays
{
	int inset = [backgroundView inset];
	CGRect bg_frame = [backgroundView frame];
	CGRect map_frame = CGRectInset(bg_frame, inset, inset);
	[trackMapView setFrame:map_frame];
	
	CGRect lb_frame = CGRectMake(map_frame.origin.x + 5, map_frame.origin.y, 60, map_frame.size.height);
	[leaderboardView setFrame:lb_frame];
	
	// CGRect zoom_frame = CGRectMake(map_frame.origin.x + 80, map_frame.origin.y + map_frame.size.height - 320, 300, 300);
	CGRect zoom_frame = CGRectMake(map_frame.origin.x + 80, map_frame.origin.y + map_frame.size.height - 320, 300, 300);
	CGRect offsetFrame = CGRectOffset(zoom_frame, trackZoomOffsetX, trackZoomOffsetY);
	CGRect bgRect = [[self view] frame];
	if ( offsetFrame.origin.x < 0 )
		offsetFrame = CGRectOffset(offsetFrame, -offsetFrame.origin.x, 0);
	if ( offsetFrame.origin.y < 0 )
		offsetFrame = CGRectOffset(offsetFrame, 0, -offsetFrame.origin.y);
	if ( offsetFrame.origin.x + offsetFrame.size.width > bgRect.origin.x + bgRect.size.width )
		offsetFrame = CGRectOffset(offsetFrame, (bgRect.origin.x + bgRect.size.width) - (offsetFrame.origin.x + offsetFrame.size.width), 0);
	if ( offsetFrame.origin.y + offsetFrame.size.height > bgRect.origin.y + bgRect.size.height )
		offsetFrame = CGRectOffset(offsetFrame, 0, (bgRect.origin.y + bgRect.size.height) - (offsetFrame.origin.y + offsetFrame.size.height));
	
	[trackZoomContainer setFrame:offsetFrame];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[leaderboardView class]])
	{
		bool zoomMapVisible = ([trackZoomView carToFollow] != nil);
		
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		
		if(name && [name length] > 0)
		{
			if([[trackZoomView carToFollow] isEqualToString:name])
			{
				[[RaceMapCoordinator Instance] setNameToFollow:nil];
				[self hideZoomMap];
				[leaderboardView RequestRedraw];
				[[RaceMapCoordinator Instance] restartCommentary];
			}
			else
			{
				[[RaceMapCoordinator Instance] setNameToFollow:name];
				[trackZoomView followCar:name];
				
				if(!zoomMapVisible)
					[self showZoomMap];
				
				[trackZoomView setUserScale:10.0];
				[trackZoomView RequestRedraw];
				[leaderboardView RequestRedraw];
				[[RaceMapCoordinator Instance] restartCommentary];
			}
			
			return;
			
		}
		
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];

}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
		
	if([(TrackMapView *)gestureView isZoomView])
	{
		[[RaceMapCoordinator Instance] setNameToFollow:nil];
		[self hideZoomMap];
	}
	else
	{
		{
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
	// Zooms on point in map, or chosen car in leader board
	if(!gestureView)
		return;
	
	/*if([gestureView isKindOfClass:[LeaderboardView class]])
	{
		bool zoomMapVisible = ([trackZoomView carToFollow] != nil);
		
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		[[RaceMapCoordinator Instance] setNameToFollow:name];
		[trackZoomView followCar:name];
		
		if(!zoomMapVisible)
			[self showZoomMap];
		
		[trackZoomView setUserScale:10.0];
		[trackZoomView RequestRedraw];
		[leaderboardView RequestRedraw];
	}*/
}

- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
	
	RaceMapData *database = [RaceMapData Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:scale X:x Y:y];
	
	[trackMapView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	// If we're on the track zoom, drag the container
	if(gestureView == trackZoomView)
	{
		CGRect frame = [trackZoomContainer frame];
		trackZoomOffsetX += x;
		trackZoomOffsetY += y;
		CGRect newFrame = CGRectOffset(frame, x, y);
		[trackZoomContainer setFrame:newFrame];
	}
		
	// If we're on the track map, pan the map
	if(gestureView == trackMapView)
	{
		RaceMapData *database = [RaceMapData Instance];
		TrackMap *trackMap = [database trackMap];
		[trackMap adjustPanInView:(TrackMapView *)gestureView X:x Y:y];	
		[trackMapView RequestRedraw];
	}
}

- (IBAction) closeButtonHit:(id)sender
{
	[[RaceMapCoordinator Instance] setNameToFollow:nil];
	[self hideZoomMap];
}

@end
