//
//  CompositeViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CompositeViewController.h"
#import "RacePadCoordinator.h"
#import "BasePadMedia.h"
#import "RacePadTitleBarController.h"
#import "BasePadTimeController.h"
#import "ElapsedTime.h"
#import "BasePadPrefs.h"

#import "VideoHelpController.h"

#import "RacePadDatabase.h"
#import "TableDataView.h"
#import "TrackMapView.h"
#import "TrackMap.h"
#import "CommentaryBubble.h"


@implementation CompositeViewController

@synthesize displayVideo;
@synthesize displayMap;
@synthesize displayLeaderboard;

- (void)viewDidLoad
{	
	
	[super viewDidLoad];

	// Initialise display options
	displayMap = true;
	displayLeaderboard = true;
	displayVideo = true;
	
	// Remove the optionsSwitches from the view - they will get re-added when the timecontroller is displayed
	// Retain them so that they are always available to be displayed
	[optionContainer retain];
	[optionContainer removeFromSuperview];
	
	// Set the types on the two map views
	[trackMapView setIsZoomView:false];
	[trackZoomView setIsZoomView:true];
	
	[trackMapView setIsOverlayView:true];
	
	[trackZoomContainer setStyle:BG_STYLE_TRANSPARENT_];
	[trackZoomContainer setHidden:true];
	trackZoomOffsetX = 0;
	trackZoomOffsetY = 0;

	// Set leaderboard data source and associate  with zoom map
 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	[leaderboardView setAssociatedTrackMapView:trackZoomView];
		
	// Tap,pan and pinch recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addLongPressRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	[self addPanRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	
	// And  for the zoom map
	[self addTapRecognizerToView:trackZoomView];
	[self addLongPressRecognizerToView:trackZoomView];
	[self addDoubleTapRecognizerToView:trackZoomView];
	[self addPinchRecognizerToView:trackZoomView];
	
	// And add pan view to the trackZoomView to allow dragging the container
	[self addPanRecognizerToView:trackZoomView];
	
	// Add tap and long press recognizers to overlay in order to catch taps outside map
	[self addTapRecognizerToView:overlayView];
	[self addLongPressRecognizerToView:overlayView];

	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];

	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:movieView WithType:RPC_VIDEO_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackZoomView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	
	[[RacePadCoordinator Instance] setVideoViewController:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary: true];
	
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_VIDEO_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];

	// We'll get notification when we know the movie size - set it to a default for now
	movieSize = CGSizeMake(768, 576);
	movieRect = CGRectMake(0, 0, 768, 576);
	[self positionOverlays];
	
	[movieView bringSubviewToFront:overlayView];
	[movieView bringSubviewToFront:trackMapView];
	[movieView bringSubviewToFront:leaderboardView];
	[movieView bringSubviewToFront:trackZoomContainer];
	[movieView bringSubviewToFront:trackZoomView];
	[movieView bringSubviewToFront:videoDelayLabel];
	[movieView bringSubviewToFront:loadingLabel];
	[movieView bringSubviewToFront:loadingTwirl];
	
	NSString *currentCarToFollow = [trackZoomView carToFollow];
	NSString *carToFollow = [[BasePadCoordinator Instance] nameToFollow];
	
	if(carToFollow == nil)
	{
		[trackZoomView setCarToFollow:nil];
		[trackZoomContainer setHidden:true];
	}
	else if(currentCarToFollow) // Only follow global car if we were already following someone
	{
		[trackZoomView setUserScale:10.0];
		[trackZoomView followCar:carToFollow];
		if(displayMap)
		{
			[trackZoomContainer setHidden:false];
		}
		else
		{
			[trackZoomContainer setHidden:true];
		}
	}
	
	if(displayVideo)
	{
		// Check that we have the right movie loaded
		[[BasePadMedia Instance] verifyMovieLoaded];
	
		// and register us to play it
		[[BasePadMedia Instance] RegisterViewController:self];
		[[RacePadCoordinator Instance] SetViewDisplayed:movieView];
	}
	
	if(displayMap)
	{
		[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
		[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
	}
	
	if(displayLeaderboard)
	{
		[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
	}
	
	[[CommentaryBubble Instance] allowBubbles:[self view] BottomRight: false];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(displayVideo)
	{
		[[RacePadCoordinator Instance] SetViewHidden:movieView];
		[[BasePadMedia Instance] ReleaseViewController:self];
	}

	if(displayMap)
	{
		[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
		[[RacePadCoordinator Instance] SetViewHidden:trackZoomView];
	}
	
	if(displayLeaderboard)
	{
		[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
	}
	
	[[RacePadCoordinator Instance] ReleaseViewController:self];

	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    //[super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload
{	
	[optionContainer release];
	optionContainer = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideOverlays];
	[[CommentaryBubble Instance] willRotateInterface];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];

	if(movieView && [movieView moviePlayerLayerAdded])
	{
		AVPlayerLayer * moviePlayerLayer = [[movieView movieSource] moviePlayerLayer];	
		if(moviePlayerLayer)
		{
			[moviePlayerLayer setFrame:[movieView bounds]];
		}
	}
	
	[UIView commitAnimations];
	
	[[CommentaryBubble Instance] didRotateInterface];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
    [super dealloc];
}

- (HelpViewController *) helpController
{
	if(!helpController)
		helpController = [[VideoHelpController alloc] initWithNibName:@"VideoHelp" bundle:nil];
	
	return (HelpViewController *)helpController;
}


////////////////////////////////////////////////////////////////////////////
// Movie routines
////////////////////////////////////////////////////////////////////////////

- (void) displayMovieSource:(BasePadVideoSource *)source
{	
	if(!source)
		return;
	
	[movieView setMovieViewDelegate:self];
	[movieView displayMovieSource:source]; // Will get notification below when it's done
}

- (void)notifyMovieAttachedToView:(MovieView *)notifyingView	// MovieViewDelegate method
{
	if(notifyingView == movieView)
	{
		[movieView bringSubviewToFront:overlayView];
		[movieView bringSubviewToFront:trackMapView];
		[movieView bringSubviewToFront:leaderboardView];
		[movieView bringSubviewToFront:trackZoomContainer];
		[movieView bringSubviewToFront:trackZoomView];
		[movieView bringSubviewToFront:videoDelayLabel];
		[movieView bringSubviewToFront:loadingLabel];
		[movieView bringSubviewToFront:loadingTwirl];
		
		[self positionOverlays];
	}
}

- (void) removeMovieFromView:(BasePadVideoSource *)source
{
	if([movieView movieSource] == source)
		[movieView removeMovieFromView];
}

- (void) removeMoviesFromView
{
	[movieView removeMovieFromView];
}

- (void) notifyMovieInformation
{
	if([[RacePadCoordinator Instance] liveMode])
	{
		NSString * videoDelayString = [NSString stringWithFormat:@"Live video delay (%d / %d) : %.1f", [[BasePadMedia Instance] resyncCount], [[BasePadMedia Instance] restartCount], [[BasePadMedia Instance] liveVideoDelay]];
		[videoDelayLabel setText:videoDelayString];
		[videoDelayLabel setHidden:false];
	}
	else
	{
		[videoDelayLabel setHidden:true];
	}
}

/////////////////////////////////////////////////////////////////////
// Overlay Controls

- (UIView *) timeControllerAddOnOptionsView
{
	return optionContainer;
}

- (void) showOverlays
{
	bool showZoomMap = ([trackZoomView carToFollow] != nil);
	
	if(displayMap)
	{
		[trackMapView setAlpha:0.0];
		[trackMapView setHidden:false];
		
		if(showZoomMap)
		{
			[trackZoomContainer setAlpha:0.0];
			[trackZoomContainer setHidden:false];
		}
	}
	
	if(displayLeaderboard)
	{
		[leaderboardView setAlpha:0.0];
		[leaderboardView setHidden:false];
	}

	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	if(displayMap)
	{
		[trackMapView setAlpha:1.0];
		
		if(showZoomMap)
		{
			[trackZoomContainer setAlpha:1.0];
		}
	}
	
	if(displayLeaderboard)
	{
		[leaderboardView setAlpha:1.0];
	}
	
	[UIView commitAnimations];
}

- (void) hideOverlays
{
	[trackMapView setHidden:true];
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
	// Work out movie position
	CGRect movieViewBounds = [movieView bounds];
	CGSize  movieViewSize = movieViewBounds.size;
	
	if(movieViewSize.width < 1 || movieViewSize.height < 1 || movieSize.width < 1 || movieSize.height < 1)
		return;
	
	float wScale = movieViewSize.width / movieSize.width;
	float hScale = movieViewSize.height / movieSize.height;
	
	if(wScale < hScale)
	{
		// It's width limited - work out height centred on view
		float newHeight = movieSize.height * wScale;
		float yOrigin = (movieViewSize.height - newHeight) / 2 + movieViewBounds.origin.y;
		movieRect = CGRectMake(movieViewBounds.origin.x, yOrigin, movieViewSize.width, newHeight);
	}
	else
	{
		// It's height limited - work out height centred on view
		float newWidth = movieSize.width * hScale;
		float xOrigin = (movieViewSize.width - newWidth) / 2 + movieViewBounds.origin.x;
		movieRect = CGRectMake(xOrigin, movieViewBounds.origin.y, newWidth, movieViewSize.height);
	}
	
	[trackMapView setFrame:movieRect];
	
	CGRect lb_frame = CGRectMake(movieRect.origin.x + 5, movieRect.origin.y, 60, movieRect.size.height);
	[leaderboardView setFrame:lb_frame];

	//CGRect zoom_frame = CGRectMake(movieViewSize.width - 320, movieViewSize.height - 320, 300, 300);
	CGRect zoom_frame = CGRectMake(movieRect.origin.x + 80, movieViewSize.height - 320, 300, 300);
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

- (void) RequestRedrawForType:(int)type
{
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if([gestureView isKindOfClass:[leaderboardView class]] && displayMap)
	{
		bool zoomMapVisible = ([trackZoomView carToFollow] != nil);
		
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		
		if(name && [name length] > 0)
		{
			if([[trackZoomView carToFollow] isEqualToString:name])
			{
				[[RacePadCoordinator Instance] setNameToFollow:nil];
				[self hideZoomMap];
				[leaderboardView RequestRedraw];
				[[[RacePadDatabase Instance] commentary] setCommentaryFor:nil];
				[[RacePadCoordinator Instance] restartCommentary];
			}
			else
			{
				[[RacePadCoordinator Instance] setNameToFollow:name];
				[trackZoomView followCar:name];
				
				if(!zoomMapVisible)
					[self showZoomMap];
				
				[trackZoomView setUserScale:10.0];
				[trackZoomView RequestRedraw];
				[leaderboardView RequestRedraw];
				[[[RacePadDatabase Instance] commentary] setCommentaryFor:name];
				[[RacePadCoordinator Instance] restartCommentary];
			}
			
			return;
		}
		
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Zooms on point in map, or chosen car in leader board
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[LeaderboardView class]])
	{
		bool zoomMapVisible = ([trackZoomView carToFollow] != nil);

		NSString * name = [leaderboardView carNameAtX:x Y:y];
		[[RacePadCoordinator Instance] setNameToFollow:name];
		[trackZoomView followCar:name];

		if(!zoomMapVisible)
			[self showZoomMap];
		
		[trackZoomView setUserScale:10.0];
		[trackZoomView RequestRedraw];
		[leaderboardView RequestRedraw];
	}
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
		[[RacePadCoordinator Instance] setNameToFollow:nil];
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


- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
			
	RacePadDatabase *database = [RacePadDatabase Instance];
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
		RacePadDatabase *database = [RacePadDatabase Instance];
		TrackMap *trackMap = [database trackMap];
		[trackMap adjustPanInView:(TrackMapView *)gestureView X:x Y:y];	
		[trackMapView RequestRedraw];
	}
}


////////////////////////////////////////////////////////////////////////
//  Callback functions

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([finished intValue] == 1)
	{
		[self positionOverlays];
		[self showOverlays];
	}
}

- (IBAction) optionSwitchesHit:(id)sender
{
	// Switches are displayed via the time controller
	// Reset the hide timer on this
	[[BasePadTimeController Instance] setHideTimer];
	
	int selectedSegment = [optionSwitches selectedSegmentIndex];
	
	if(selectedSegment == 0)	// Video only
	{
		if(displayMap)
		{
			displayMap = false;
			displayLeaderboard = false;
			[trackMapView setHidden:true];
			[trackZoomContainer setHidden:true];
			[leaderboardView setHidden:true];
			[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
			[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
			[[RacePadCoordinator Instance] SetViewHidden:trackZoomView];
		}
		
		if(!displayVideo)
		{
			// Check that we have the right movie loaded
			[[BasePadMedia Instance] verifyMovieLoaded];
			
			// and register us to play it
			[[BasePadMedia Instance] RegisterViewController:self];

			// Make sure to do this last, as this will force a start of play or seek
			[[RacePadCoordinator Instance] SetViewDisplayed:movieView];		
			displayVideo = true;
		}
	}
	else if(selectedSegment == 2)	// Map only
	{
		if(!displayMap)
		{
			bool zoomMapVisible = ([trackZoomView carToFollow] != nil);
			displayMap = true;
			displayLeaderboard = true;
			[trackMapView setHidden:false];
			[leaderboardView setHidden:false];
			
			[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
			[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
			[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
			
			[trackMapView RequestRedraw];
			[leaderboardView RequestRedraw];
			
			if(zoomMapVisible)
			{
				[trackZoomContainer setHidden:false];
				[trackZoomView RequestRedraw];
			}
		}
		
		if(displayVideo)
		{
			[[BasePadMedia Instance] ReleaseViewController:self];
			[[RacePadCoordinator Instance] SetViewHidden:movieView];		
			displayVideo = false;
		}
	}
	else	// Video and map
	{
		if(!displayMap)
		{
			bool zoomMapVisible = ([trackZoomView carToFollow] != nil);
			displayMap = true;
			displayLeaderboard = true;
			[trackMapView setHidden:false];
			[leaderboardView setHidden:false];
			
			[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
			[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
			[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
			
			[trackMapView RequestRedraw];
			[leaderboardView RequestRedraw];
			
			if(zoomMapVisible)
			{
				[trackZoomContainer setHidden:false];
				[trackZoomView RequestRedraw];
			}
		}
				
		if(!displayVideo)
		{
			// Check that we have the right movie loaded
			[[BasePadMedia Instance] verifyMovieLoaded];
			
			// and register us to play it
			[[BasePadMedia Instance] RegisterViewController:self];

			displayVideo = true;
			
			// Make sure to do this last, as this will force a start of play or seek
			[[RacePadCoordinator Instance] SetViewDisplayed:movieView];		
		}
	}	

}

- (IBAction) closeButtonHit:(id)sender
{
	[[RacePadCoordinator Instance] setNameToFollow:nil];
	[self hideZoomMap];
}

@end
