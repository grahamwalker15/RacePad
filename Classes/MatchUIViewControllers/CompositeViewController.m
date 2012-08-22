//
//  CompositeViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CompositeViewController.h"
#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"
#import "MatchPadTitleBarController.h"
#import "BasePadTimeController.h"
#import "ElapsedTime.h"
#import "BasePadPrefs.h"

#import "MatchPadDatabase.h"
#import "TableDataView.h"
#import "PitchView.h"
#import "Pitch.h"


@implementation CompositeViewController

@synthesize displayVideo;
@synthesize displayPitch;

- (void)viewDidLoad
{	
	// Initialise display options
	displayPitch = true;
	displayVideo = true;
	
	moviePlayerLayerAdded = false;
	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	[movieView setStyle:BG_STYLE_FULL_SCREEN_GREY_];

	// Remove the optionsSwitches from the view - they will get re-added when the timecontroller is displayed
	// Retain them so that they are always available to be displayed
	[optionContainer retain];
	[optionContainer removeFromSuperview];
	
	// Set the types on the two map views
	[pitchView setIsZoomView:false];
	
	[pitchView setIsOverlayView:false];
	[pitchView setShowWholeMove:false];
	
	// Tap,pan and pinch recognizers for map
	[self addTapRecognizerToView:pitchView];
	[self addLongPressRecognizerToView:pitchView];
	[self addDoubleTapRecognizerToView:pitchView];
	[self addPanRecognizerToView:pitchView];
	[self addPinchRecognizerToView:pitchView];
	
	// Add tap and long press recognizers to overlay in order to catch taps outside map
	[self addTapRecognizerToView:overlayView];
	[self addLongPressRecognizerToView:overlayView];

	// Tell the MatchPadCoordinator that we will be interested in data for this view
	[[MatchPadCoordinator Instance] AddView:movieView WithType:MPC_VIDEO_VIEW_];
	[[MatchPadCoordinator Instance] AddView:pitchView WithType:MPC_PITCH_VIEW_];
	
	[[MatchPadCoordinator Instance] setVideoViewController:self];
	
	[super viewDidLoad];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[MatchPadTitleBarController Instance] displayInViewController:self];
	
	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:(MPC_VIDEO_VIEW_ | MPC_PITCH_VIEW_)];

	// We'll get notification when we know the movie size - set it to a default for now
	movieSize = CGSizeMake(768, 576);
	movieRect = CGRectMake(0, 0, 768, 576);
	[self positionViews];
	
	[movieView bringSubviewToFront:overlayView];
	[movieView bringSubviewToFront:videoDelayLabel];
	
	if(displayVideo)
	{
		// Check that we have the right movie loaded
		[[BasePadMedia Instance] verifyMovieLoaded];
	
		// and register us to play it
		[[BasePadMedia Instance] RegisterViewController:self];
		[[MatchPadCoordinator Instance] SetViewDisplayed:movieView];
	}
	
	if(displayPitch)
	{
		[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];
	}
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(displayVideo)
	{
		[[MatchPadCoordinator Instance] SetViewHidden:movieView];
		[[BasePadMedia Instance] ReleaseViewController:self];
	}

	if(displayPitch)
	{
		[[MatchPadCoordinator Instance] SetViewHidden:pitchView];
	}
	
	[[MatchPadCoordinator Instance] ReleaseViewController:self];

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
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self positionViews];
	
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
	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
    [super dealloc];
}

- (HelpViewController *) helpController
{
	/*
	if(!helpController)
		helpController = [[VideoHelpController alloc] initWithNibName:@"VideoHelp" bundle:nil];
	*/
	
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
		[movieView bringSubviewToFront:videoDelayLabel];
		[movieView bringSubviewToFront:loadingLabel];
		[movieView bringSubviewToFront:loadingTwirl];
		
		// [self positionOverlays];
	}
}

- (void)notifyMovieReadyToPlayInView:(MovieView *)notifyingView	// MovieViewDelegate method
{
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
	if([[MatchPadCoordinator Instance] diagnostics] && [[MatchPadCoordinator Instance] liveMode])
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

/// Older

/*

- (void) displayMovieInView
{	
	// Position the movie and order the overlays
	AVPlayerLayer * moviePlayerLayer = [[[BasePadMedia Instance] movieSource:0] moviePlayerLayer];	
	
	if(moviePlayerLayer && !moviePlayerLayerAdded)
	{
		CALayer *superlayer = movieView.layer;
		
		[moviePlayerLayer setFrame:[movieView bounds]];
		[superlayer addSublayer:moviePlayerLayer];
		
		moviePlayerLayerAdded = true;
	}
	
	[movieView bringSubviewToFront:overlayView];
	[movieView bringSubviewToFront:videoDelayLabel];
	
	// [self positionOverlays];	
}

- (void) removeMovieFromView
{
	AVPlayerLayer * moviePlayerLayer = [[[BasePadMedia Instance] movieSource:0] moviePlayerLayer];	
	if(moviePlayerLayer && moviePlayerLayerAdded)
	{
		[moviePlayerLayer removeFromSuperlayer];
		moviePlayerLayerAdded = false;
	}	
}

- (void) notifyMovieInformation
{
	 if([[MatchPadCoordinator Instance] liveMode])
	{
		NSString * videoDelayString = [NSString stringWithFormat:@"Live video delay : %.1f", [[BasePadMedia Instance] liveVideoDelay]];
		[videoDelayLabel setText:videoDelayString];
		[videoDelayLabel setHidden:false];
	}
	else
	{
		[videoDelayLabel setHidden:true];
	}
}
 
 */

/////////////////////////////////////////////////////////////////////
// Overlay Controls

- (UIView *) timeControllerAddOnOptionsView
{
	return optionContainer;
}

- (void) showOverlays
{
	if(displayPitch)
	{
		[pitchView setAlpha:0.0];
		[pitchView setHidden:false];
	}
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	if(displayPitch)
	{
		[pitchView setAlpha:1.0];
	}
	
	[UIView commitAnimations];
}

- (void) hideOverlays
{
	[pitchView setHidden:true];
}

- (void) positionViews
{	
	CGRect bg_frame = [backgroundView frame];
	if ( displayPitch )
		if ( displayVideo )
		{
			CGRect viewRect = CGRectMake(0, 0, bg_frame.size.width, bg_frame.size.height / 4 * 3 );
			CGRect pitchRect = CGRectMake(0, viewRect.size.height, bg_frame.size.width, bg_frame.size.height / 4);
			[movieView setFrame:viewRect];
			[pitchView setFrame:pitchRect];
		}
		else
			[pitchView setFrame:bg_frame];
	else
		[movieView setFrame:bg_frame];

		
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
	
	// [pitchView setFrame:];
}

- (void) RequestRedrawForType:(int)type
{
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	[self handleTimeControllerGestureInView:gestureView AtX:x Y:y];
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Zooms on point in map, or chosen car in leader board
	if(!gestureView)
		return;
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[PitchView class]])
	{
		return;
	}
	
	[(PitchView *)gestureView setUserXOffset:0.0];
	[(PitchView *)gestureView setUserYOffset:0.0];
	[(PitchView *)gestureView setUserScale:1.0];	
	
	[pitchView RequestRedraw];
}


- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[PitchView class]])
	{
		return;
	}
			
	MatchPadDatabase *database = [MatchPadDatabase Instance];
	Pitch *pitch = [database pitch];
	
	[pitch adjustScaleInView:(PitchView *)gestureView Scale:scale X:x Y:y];

	[pitchView RequestRedraw];
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
		
	// If we're on the track map, pan the map
	if(gestureView == pitchView)
	{
		MatchPadDatabase *database = [MatchPadDatabase Instance];
		Pitch *pitch = [database pitch];
		[pitch adjustPanInView:(PitchView *)gestureView X:x Y:y];	
		[pitchView RequestRedraw];
	}
}


////////////////////////////////////////////////////////////////////////
//  Callback functions

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([finished intValue] == 1)
	{
		// [self positionOverlays];
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
		if(displayPitch)
		{
			displayPitch = false;
			[pitchView setHidden:true];
			[[MatchPadCoordinator Instance] SetViewHidden:pitchView];
		}
		
		if(!displayVideo)
		{
			// Check that we have the right movie loaded
			[[BasePadMedia Instance] verifyMovieLoaded];
			
			// and register us to play it
			[[BasePadMedia Instance] RegisterViewController:self];

			// Make sure to do this last, as this will force a start of play or seek
			[[MatchPadCoordinator Instance] SetViewDisplayed:movieView];		
			displayVideo = true;
		}
	}
	else if(selectedSegment == 2)	// Map only
	{
		if(!displayPitch)
		{
			displayPitch = true;
			[pitchView setHidden:false];
			
			[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];
			
			[pitchView RequestRedraw];
		}
		
		if(displayVideo)
		{
			[[BasePadMedia Instance] ReleaseViewController:self];
			[[MatchPadCoordinator Instance] SetViewHidden:movieView];		
			displayVideo = false;
		}
	}
	else	// Video and map
	{
		if(!displayPitch)
		{
			displayPitch = true;
			[pitchView setHidden:false];
			
			[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];
			
			[pitchView RequestRedraw];
		}
				
		if(!displayVideo)
		{
			// Check that we have the right movie loaded
			[[BasePadMedia Instance] verifyMovieLoaded];
			
			// and register us to play it
			[[BasePadMedia Instance] RegisterViewController:self];

			displayVideo = true;
			
			// Make sure to do this last, as this will force a start of play or seek
			[[MatchPadCoordinator Instance] SetViewDisplayed:movieView];		
		}
	}
	[self positionViews];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	// [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	AVPlayerLayer * moviePlayerLayer = [[[BasePadMedia Instance] movieSource:0] moviePlayerLayer];	
	if(moviePlayerLayer)
	{
		[moviePlayerLayer setFrame:[movieView bounds]];
	}
	
	[UIView commitAnimations];
}

@end
