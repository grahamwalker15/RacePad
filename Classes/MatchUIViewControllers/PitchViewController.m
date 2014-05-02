//
//  PitchViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PitchViewController.h"

#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadTitleBarController.h"
#import "MatchPadDatabase.h"
#import "TableDataView.h"
#import "PitchView.h"
#import "BackgroundView.h"
#import "Pitch.h"
#import "BasePadPrefs.h"

@implementation PitchViewController

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
	// Set the types on the two map views
	[pitchView setIsZoomView:false];
	[pitchView setPitchBackground:false];
	[pitchZoomView setIsZoomView:true];
	
	[pitchZoomContainer setStyle:BG_STYLE_TRANSPARENT_];
	[pitchZoomContainer setHidden:true];
	pitchZoomOffsetX = 0;
	pitchZoomOffsetY = 0;
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GRASS_];

	// Add gesture recognizers
 	[self addTapRecognizerToView:pitchView];
	[self addDoubleTapRecognizerToView:pitchView];
	[self addLongPressRecognizerToView:pitchView];
	
	//	Tap recognizer for background
	[self addTapRecognizerToView:backgroundView];
	[self addLongPressRecognizerToView:backgroundView];
	
    //	Pinch, long press and pan recognizers for map
	[self addPinchRecognizerToView:pitchView];
	[self addPanRecognizerToView:pitchView];
	// Don't zoom on corner for now - it's too confusing if you tap in the wrong place
	//[self addLongPressRecognizerToView:pitchView];

	// And  for the zoom map
	[self addTapRecognizerToView:pitchZoomView];
	[self addDoubleTapRecognizerToView:pitchZoomView];
	[self addPinchRecognizerToView:pitchZoomView];
	
	// And add pan view to the pitchZoomView to allow dragging the container
	[self addPanRecognizerToView:pitchZoomView];

	[super viewDidLoad];
	
	[[MatchPadCoordinator Instance] AddView:pitchView WithType:MPC_PITCH_VIEW_];
	[[MatchPadCoordinator Instance] AddView:pitchView WithType:MPC_POSITIONS_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	//[[MatchPadTitleBarController Instance] displayInViewController:self];
	
	// Register the views
	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:(MPC_PITCH_VIEW_ | MPC_POSITIONS_VIEW_)];
	
	// Resize overlay views
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	[pitchZoomContainer setHidden:true];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];

	NSNumber *v = [[BasePadPrefs Instance]getPref:@"playerTrails"];
	if ( v )
		pitchView.playerTrails = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"playerPos"];
	if ( v )
		pitchView.playerPos = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"passes"];
	if ( v )
		pitchView.passes = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"passNames"];
	if ( v )
		pitchView.passNames = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"ballTrail"];
	if ( v )
		pitchView.ballTrail = [v boolValue];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] SetViewHidden:pitchView];
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
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
	bool showZoomMap = ([pitchZoomView playerToFollow] != nil);
	
	if(showZoomMap)
	{
		[pitchZoomContainer setAlpha:0.0];
		[pitchZoomContainer setHidden:false];
	}
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	
	if(showZoomMap)
	{
		[pitchZoomContainer setAlpha:1.0];
	}
	
	[UIView commitAnimations];
}

- (void) hideOverlays
{
	[pitchZoomContainer setHidden:true];
}
- (void) showZoomMap
{
	[pitchZoomContainer setAlpha:0.0];
	[pitchZoomContainer setHidden:false];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[pitchZoomContainer setAlpha:1.0];
	[UIView commitAnimations];
}

- (void) hideZoomMap
{
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[pitchZoomContainer setAlpha:0.0];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideZoomMapAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void) hideZoomMapAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
	if([finished intValue] == 1)
	{
		[pitchZoomContainer setHidden:true];
		[pitchZoomContainer setAlpha:1.0];
		[pitchZoomView setPlayerToFollow:nil];
	}
}

- (void) positionOverlays
{
	CGRect bg_frame = [backgroundView frame];
	CGRect map_frame = CGRectInset(bg_frame, 20, 20); // The grass is drawn 20 pixels inside the BGView
	[pitchView setFrame:map_frame];
	
	// CGRect zoom_frame = CGRectMake(map_frame.origin.x + 80, map_frame.origin.y + map_frame.size.height - 320, 300, 300);
	CGRect zoom_frame = CGRectMake(map_frame.origin.x + 80, map_frame.origin.y + map_frame.size.height - 320, 300, 300);
	CGRect offsetFrame = CGRectOffset(zoom_frame, pitchZoomOffsetX, pitchZoomOffsetY);
	CGRect bgRect = [[self view] frame];
	if ( offsetFrame.origin.x < 0 )
		offsetFrame = CGRectOffset(offsetFrame, -offsetFrame.origin.x, 0);
	if ( offsetFrame.origin.y < 0 )
		offsetFrame = CGRectOffset(offsetFrame, 0, -offsetFrame.origin.y);
	if ( offsetFrame.origin.x + offsetFrame.size.width > bgRect.origin.x + bgRect.size.width )
		offsetFrame = CGRectOffset(offsetFrame, (bgRect.origin.x + bgRect.size.width) - (offsetFrame.origin.x + offsetFrame.size.width), 0);
	if ( offsetFrame.origin.y + offsetFrame.size.height > bgRect.origin.y + bgRect.size.height )
		offsetFrame = CGRectOffset(offsetFrame, 0, (bgRect.origin.y + bgRect.size.height) - (offsetFrame.origin.y + offsetFrame.size.height));
	
	[pitchZoomContainer setFrame:offsetFrame];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	[super OnTapGestureInView:gestureView AtX:x Y:y];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[PitchView class]])
	{
		return;
	}
		
	if([(PitchView *)gestureView isZoomView])
	{
		[[MatchPadCoordinator Instance] setNameToFollow:nil];
		[self hideZoomMap];
	}
	else
	{
		{
			[(PitchView *)gestureView setUserXOffset:0.0];
			[(PitchView *)gestureView setUserYOffset:0.0];
			[(PitchView *)gestureView setUserScale:1.0];	
		}
	}
	
	[pitchView RequestRedraw];
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
	if(!gestureView || ![gestureView isKindOfClass:[PitchView class]])
	{
		return;
	}
	
	[pitchView adjustScale:scale X:x Y:y];
	
	[pitchView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
	
	// If we're on the track zoom, drag the container
	if(gestureView == pitchZoomView)
	{
		CGRect frame = [pitchZoomContainer frame];
		pitchZoomOffsetX += x;
		pitchZoomOffsetY += y;
		CGRect newFrame = CGRectOffset(frame, x, y);
		[pitchZoomContainer setFrame:newFrame];
	}
		
	// If we're on the track map, pan the map
	if(gestureView == pitchView)
	{
		[pitchView adjustPan:x Y:y];	
		[pitchView RequestRedraw];
	}
}


////////////////////////////////////////////////////
// Popup methods


- (void) willDisplay
{
	// Resize overlay views
	[self positionOverlays];
	
	// Force background refresh
	[backgroundView RequestRedraw];
	
	[pitchZoomContainer setHidden:true];
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];
	
	NSNumber *v = [[BasePadPrefs Instance]getPref:@"playerTrails"];
	if ( v )
		pitchView.playerTrails = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"playerPos"];
	if ( v )
		pitchView.playerPos = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"passes"];
	if ( v )
		pitchView.passes = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"passNames"];
	if ( v )
		pitchView.passNames = [v boolValue];
	v = [[BasePadPrefs Instance]getPref:@"ballTrail"];
	if ( v )
		pitchView.ballTrail = [v boolValue];
}

- (void) willHide
{
}

- (void) didDisplay
{
}

- (void) didHide
{
	[[MatchPadCoordinator Instance] SetViewHidden:pitchView];
}


@end
