//
//  MatchPadVideoViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadVideoViewController.h"

#import "MatchPadDatabase.h"
#import "BasePadMedia.h"
#import "BasePadTimeController.h"
#import "ElapsedTime.h"
#import "BasePadPrefs.h"

//#import "CommentaryBubble.h"


@implementation MatchPadVideoViewController

@synthesize mainMovieView;
@synthesize auxMovieView1;
@synthesize auxMovieView2;

@synthesize displayVideo;
@synthesize displayPitch;
@synthesize displayLogos;

@synthesize allowBubbleCommentary;

@synthesize mainMenuButtonOpen;
@synthesize helpButtonOpen;
@synthesize settingsButtonOpen;
@synthesize statsButtonOpen;
@synthesize highlightsButtonOpen;	
@synthesize replaysButtonOpen;
@synthesize codingButtonOpen;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// This view is always displayed as a subview
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
	}
    return self;
}

- (void)viewDidLoad
{	
	
	[super viewDidLoad];
		
	// Initialise display options
	
	menuButtonsDisplayed = true;
	menuButtonsAnimating = false;
	moviesAnimating = false;
	
	mainMenuButtonOpen = false;
	
	helpButtonOpen = false;
	settingsButtonOpen = false;
	statsButtonOpen = false;
	highlightsButtonOpen = false;	
	replaysButtonOpen = false;
	codingButtonOpen = false;
	
    timeControllerPending = false;
    
	firstDisplay = true;
	autoHideButtons = false;
	
    popupNotificationPending = false;
	
	displayVideo = true;
    displayLogos = true;
	
	allowBubbleCommentary = false;
	
	priorityAuxMovie = 1;
	
	[mainMovieView setStyle:BG_STYLE_INVISIBLE_];
	[auxMovieView1 setStyle:BG_STYLE_INVISIBLE_];
	[auxMovieView2 setStyle:BG_STYLE_INVISIBLE_];
	
	[mainMovieView setTitleView:mainMovieViewTitleView];
	[mainMovieView setTitleBackgroundImage:mainMovieViewTitleBackgroundImage];
	
	[auxMovieView1 setTitleView:auxMovieView1TitleView];
	[auxMovieView1 setTitleBackgroundImage:auxMovieView1TitleBackgroundImage];
	
	[auxMovieView2 setTitleView:auxMovieView2TitleView];
	[auxMovieView2 setTitleBackgroundImage:auxMovieView2TitleBackgroundImage];
		
	[mainMovieView setCloseButton:mainMovieViewCloseButton];
	[auxMovieView1 setCloseButton:auxMovieView1CloseButton];
	[auxMovieView2 setCloseButton:auxMovieView2CloseButton];
	
	[mainMovieView setMovieTypeButton:mainMovieViewMovieType];
	[auxMovieView1 setMovieTypeButton:auxMovieView1MovieType];
	[auxMovieView2 setMovieTypeButton:auxMovieView2MovieType];
	
	[mainMovieView setLoadingTwirl:loadingTwirl];
	[mainMovieView setLoadingLabel:loadingLabel];
	[mainMovieView setLoadingScreen:mainMovieViewLoadingScreen];

	[auxMovieView1 setLoadingTwirl:auxMovieView1LoadingTwirl];
	[auxMovieView1 setLoadingLabel:auxMovieView1LoadingLabel];
	[auxMovieView1 setErrorLabel:auxMovieView1ErrorLabel];
	[auxMovieView1 setLoadingScreen:auxMovieView1LoadingScreen];
	
	[auxMovieView2 setLoadingTwirl:auxMovieView2LoadingTwirl];
	[auxMovieView2 setLoadingLabel:auxMovieView2LoadingLabel];
	[auxMovieView2 setErrorLabel:auxMovieView2ErrorLabel];
	[auxMovieView2 setLoadingScreen:auxMovieView2LoadingScreen];
	
	[mainMovieView hideMovieLabels];
	[auxMovieView1 hideMovieLabels];
	[auxMovieView2 hideMovieLabels];
	
	[mainMovieView hideMovieLoading];
	[auxMovieView1 hideMovieLoading];
	[auxMovieView2 hideMovieLoading];
	
	[mainMovieView hideMovieError];
	[auxMovieView1 hideMovieError];
	[auxMovieView2 hideMovieError];
	
	[mainMovieView setLive:true];
	
	[auxMovieView1 setHidden:true];
	[auxMovieView2 setHidden:true];
	
	// Position the menu buttons
	[self positionMenuButtons];
				
	// Set the types on the pitch view
	displayPitch = false;
	[pitchView setHidden:true];
	[pitchView setIsZoomView:false];
	
	[pitchView setIsOverlayView:false];
	[pitchView setShowWholeMove:false];
	
	// Tap,pan and pinch recognizers for pitch
	[self addTapRecognizerToView:pitchView];
	[self addLongPressRecognizerToView:pitchView];
	[self addDoubleTapRecognizerToView:pitchView];
	[self addPanRecognizerToView:pitchView];
	[self addPinchRecognizerToView:pitchView];
	
	// Add tap and long press recognizers to overlay and movie views in order to catch taps outside the pitch
	[self addTapRecognizerToView:overlayView];
	[self addTapRecognizerToView:mainMovieView];
	[self addTapRecognizerToView:auxMovieView1];
	[self addTapRecognizerToView:auxMovieView2];
	
	[self addPinchRecognizerToView:mainMovieView];
	[self addPinchRecognizerToView:auxMovieView1];
	[self addPinchRecognizerToView:auxMovieView2];
	
	// Add double taps to the movie views in order to reload
	[self addDoubleTapRecognizerToView:mainMovieView];
	[self addDoubleTapRecognizerToView:auxMovieView1];
	[self addDoubleTapRecognizerToView:auxMovieView2];
	
	// Add long press and pinch recognizers to the overlay to reset video windows (TEMPORARY)
	[self addLongPressRecognizerToView:overlayView];
	[self addLongPressRecognizerToView:mainMovieView];
	[self addLongPressRecognizerToView:auxMovieView1];
	[self addLongPressRecognizerToView:auxMovieView2];
	
	// Tell the MatchPadCoordinator that we will be interested in data for this view
	[[MatchPadCoordinator Instance] AddView:self WithType:MPC_SCORE_VIEW_];
	[[MatchPadCoordinator Instance] AddView:mainMovieView WithType:MPC_VIDEO_VIEW_];
	[[MatchPadCoordinator Instance] AddView:pitchView WithType:MPC_PITCH_VIEW_];
	[[MatchPadCoordinator Instance] AddView:pitchView WithType:MPC_POSITIONS_VIEW_];
	// FIXME - we're using the background view here to fool the coordinator
	// because we have two data sources, but only one view
	
	[[MatchPadCoordinator Instance] setVideoViewController:self];
    
    logoAnimationTimer = nil;
    currentLogoIndex = 0;
    currentLogoImageView = 0;

    [self initialiseLogoImages];
    [logoImageBase setHidden:true];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:(MPC_VIDEO_VIEW_ | MPC_PITCH_VIEW_ | MPC_POSITIONS_VIEW_)];
	
	// We'll get notification when we know the movie size - set it to a default for now
	movieSize = CGSizeMake(768, 576);
	movieRect = CGRectMake(0, 0, 768, 576);
	[self positionOverlays];
	
	[mainMovieView bringSubviewToFront:overlayView];

	[mainMovieView bringSubviewToFront:videoDelayLabel];
	[mainMovieView bringSubviewToFront:loadingLabel];
	[mainMovieView bringSubviewToFront:loadingTwirl];
		
	if(displayVideo)
	{
		// Register us to play video
		[[BasePadMedia Instance] RegisterViewController:self];
		[[MatchPadCoordinator Instance] SetViewDisplayed:mainMovieView];
		
		// Then check that we have the right movie loaded
		[mainMovieView setMovieViewDelegate:self];
		[[BasePadMedia Instance] verifyMovieLoaded];
	}
	
	if(displayPitch)
	{
		[pitchView setHidden:false];
		[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];
	}
	else
	{
		[pitchView setHidden:true];
	}

	
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
	
	[[MatchPadCoordinator Instance] SetViewDisplayed:self];
	
	//[[CommentaryBubble Instance] setMidasStyle:true];
	/*
	if(allowBubbleCommentary)
		[[CommentaryBubble Instance] allowBubbles:[self view] BottomRight: false];
	else
		[[CommentaryBubble Instance] noBubbles];
	*/
	
	if(firstDisplay)
	{
		if(autoHideButtons)
			[self performSelector:@selector(hideMenuButtons) withObject:nil afterDelay: 2.0];
		
		firstDisplay = false;
	}
	
	// We don't want the time controls to auto hide - so tell them
	[[BasePadTimeController Instance] setAutoHide:false];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	if(displayVideo)
	{
		[[MatchPadCoordinator Instance] SetViewHidden:mainMovieView];
		[[BasePadMedia Instance] ReleaseViewController:self];
	}
	
	if(displayPitch)
	{
		[[MatchPadCoordinator Instance] SetViewHidden:pitchView];
	}
		
	[[MatchPadCoordinator Instance] SetViewHidden:self];
	
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
	// Reset the time controls to auto hide so that other view controllers are OK
	[[BasePadTimeController Instance] setAutoHide:true];

	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overridden to allow only landscape orientation.
	if(interfaceOrientation == UIInterfaceOrientationPortrait)
		return NO;
	
	if(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown)
		return NO;
	
	if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft)
		return YES;
	
	if(interfaceOrientation == UIInterfaceOrientationLandscapeRight)
		return YES;
	
    return NO;
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
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[self hideOverlays];
	//[[CommentaryBubble Instance] willRotateInterface];
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	
	if(mainMovieView && [mainMovieView moviePlayerLayerAdded])
	{
		AVPlayerLayer * moviePlayerLayer = [[mainMovieView movieSource] moviePlayerLayer];	
		if(moviePlayerLayer)
		{
			[moviePlayerLayer setFrame:[mainMovieView bounds]];
		}
	}
	
	[UIView commitAnimations];
	
	//[[CommentaryBubble Instance] didRotateInterface];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
    [super dealloc];
}

- (HelpViewController *) helpController
{
	return nil;
}

////////////////////////////////////////////////////////////////////////////
// Movie routines
////////////////////////////////////////////////////////////////////////////

- (MovieView *) firstMovieView
{
	return mainMovieView;
}

- (void) displayMovieSource:(BasePadVideoSource *)source 
{	
	if(!source)
		return;
	
	if(![mainMovieView movieSourceAssociated])
		[self displayMovieSource:source InView:mainMovieView];
	else if(![auxMovieView1 movieSourceAssociated])
		[self displayMovieSource:source InView:auxMovieView1];
	else if(![auxMovieView2 movieSourceAssociated])
		[self displayMovieSource:source InView:auxMovieView2];
}

- (bool) displayMovieSource:(BasePadVideoSource *)source InView:(MovieView *)movieView
{	
	// Do nothing if source is already displayed
	if([source movieDisplayed])
		return false;

	[movieView setMovieViewDelegate:self];
	
	if([movieView displayMovieSource:source])
		return true; // Will get notification below when it's done
	
	return false;
}

- (void)notifyMovieAttachedToView:(MovieView *)movieView	// MovieViewDelegate method
{
    if(movieView && movieView == mainMovieView)
    {
        [movieView bringSubviewToFront:overlayView];

        [movieView bringSubviewToFront:videoDelayLabel];
        [movieView bringSubviewToFront:loadingLabel];
        [movieView bringSubviewToFront:loadingTwirl];

        [self positionOverlays];
    }
}

- (void)notifyMovieReadyToPlayInView:(MovieView *)movieView	// MovieViewDelegate method
{
}

- (void) removeMovieFromView:(BasePadVideoSource *)source
{
	if([mainMovieView movieSource] == source)
		[mainMovieView removeMovieFromView];
	if([auxMovieView1 movieSource] == source)
		[auxMovieView1 removeMovieFromView];
	if([auxMovieView2 movieSource] == source)
		[auxMovieView2 removeMovieFromView];
}

- (void) removeMoviesFromView
{
	[mainMovieView removeMovieFromView];
	[auxMovieView1 removeMovieFromView];
	[auxMovieView2 removeMovieFromView];
}

- (void) prePositionMovieView:(MovieView *)newView From:(int)movieDirection
{
	CGRect centreViewRect = CGRectMake(0,0,700,394);
	CGRect superBounds = [self.view bounds];

	switch(movieDirection)
	{
		case MV_MOVIE_FROM_LEFT:
			[newView setFrame:CGRectOffset(centreViewRect, -centreViewRect.size.width, 244)];
			break;
			
		case MV_MOVIE_FROM_RIGHT:
			[newView setFrame:CGRectOffset(centreViewRect, superBounds.size.width, 244)];
			break;
			
		case MV_MOVIE_FROM_TOP:
			[newView setFrame:CGRectOffset(centreViewRect, 324, -centreViewRect.size.height)];
			break;
			
		case MV_MOVIE_FROM_BOTTOM:
			[newView setFrame:CGRectOffset(centreViewRect, 324, superBounds.size.height)];
			break;
			
		default:
			break;
	}
	
	[newView resizeMovieSourceAnimated:false WithDuration:0.0];
}

- (void) positionMovieViews
{
	// Check how many videos are displayed - assume main one is
	
	int movieViewCount = [self countMovieViews];
	
	// Position displayed windows
	CGRect superBounds = [self.view bounds];
	
	CGRect centreViewRect = CGRectMake(324, 244,700,394);
	CGRect leftViewRect = CGRectMake(0, 464,308,174);
	CGRect topViewRect = CGRectMake(716, 54,308,174);
	
	CGRect soloViewRect = CGRectMake(0, (CGRectGetMaxY(superBounds) - 576) * 0.5, 1024,576);
	CGRect mainReplayRect = CGRectMake(0, 0, 1024,576);
	CGRect pInPRectLeft = CGRectMake(10, CGRectGetMaxY(superBounds) - 184, 308,174);
	//CGRect pInPRectRight = CGRectMake(CGRectGetMaxX(superBounds) - 318, CGRectGetMaxY(superBounds) - 184, 308,174);
	
	CGRect pitchRect = CGRectMake(400, CGRectGetMaxY(superBounds) - 172, 600, 162);
	
	CGRect auxMovieView1Rect = [auxMovieView1 frame];
	CGRect auxMovieView2Rect = [auxMovieView2 frame];
	
	if(movieViewCount == 1)
	{
        // Make sure the time controller won't come back if we're returning to a forced live view
        if(mainMovieView && [mainMovieView movieSourceAssociated] && [mainMovieView movieSource] && [[mainMovieView movieSource] movieForceLive])
        {
            timeControllerPending = false;
        }
        
        // Then setup the movie view parameters
		[self showOverlays];
		[mainMovieView setFrame:soloViewRect];
		[mainMovieView setShouldShowLabels:false];
		[auxMovieView1 setShouldShowLabels:false];
		[auxMovieView2 setShouldShowLabels:false];
        [mainMovieView setAudioMuted:false];
        [auxMovieView1 setAudioMuted:true];
        [auxMovieView2 setAudioMuted:true];
		priorityAuxMovie = 1;
	}
	else if(movieViewCount == 2)
	{
		[self showOverlays];
		[mainMovieView setFrame:pInPRectLeft];
		[mainMovieView setShouldShowLabels:true];
        [mainMovieView setAudioMuted:true];
		if([auxMovieView1 movieSourceAssociated] && ![auxMovieView1 movieScheduledForRemoval])
		{
			priorityAuxMovie = 1;
			[auxMovieView1 setFrame:mainReplayRect];
			[auxMovieView1 setShouldShowLabels:true];
			[auxMovieView2 setShouldShowLabels:false];
 		}
		else if([auxMovieView2 movieSourceAssociated] && ![auxMovieView2 movieScheduledForRemoval])
		{
			priorityAuxMovie = 2;
			[auxMovieView2 setFrame:mainReplayRect];
			[auxMovieView2 setShouldShowLabels:true];
			[auxMovieView1 setShouldShowLabels:false];
		}
        [auxMovieView1 setAudioMuted:priorityAuxMovie == 2];
        [auxMovieView2 setAudioMuted:priorityAuxMovie == 1];
		
		[pitchView setFrame:pitchRect];
	}
	else if(movieViewCount == 3)	// Won't happen at the moment, but leave code in in case we decide to allow it
	{
		[self showOverlays];
		[mainMovieView setFrame:leftViewRect];
        [mainMovieView setAudioMuted:true];
        [auxMovieView1 setAudioMuted:priorityAuxMovie == 2];
        [auxMovieView2 setAudioMuted:priorityAuxMovie == 1];
        [auxMovieView1 setShouldShowLabels:true];
        [auxMovieView2 setShouldShowLabels:true];
		if([auxMovieView1 movieSourceAssociated])
		{
			[auxMovieView1 setFrame:(priorityAuxMovie == 1 ? centreViewRect : topViewRect)];
		}
		if([auxMovieView2 movieSourceAssociated])
		{
			[auxMovieView2 setFrame:(priorityAuxMovie == 1 ? topViewRect : centreViewRect)];
		}
	}
	
	// and move out any assigned for removal
	if([auxMovieView1 movieScheduledForRemoval])
	{
		[auxMovieView1 setFrame:CGRectOffset(auxMovieView1Rect, superBounds.size.width - auxMovieView1Rect.origin.x + 1, 0)]; //Slide off right
	}
	
	if([auxMovieView2 movieScheduledForRemoval])
		[auxMovieView2 setFrame:CGRectOffset(auxMovieView2Rect, superBounds.size.width - auxMovieView2Rect.origin.x + 1, 0)]; //Slide off right
	
	// And move movie content to go with it
	[mainMovieView resizeMovieSourceAnimated:true WithDuration:1.0];
	[auxMovieView1 resizeMovieSourceAnimated:true WithDuration:1.0];
	[auxMovieView2 resizeMovieSourceAnimated:true WithDuration:1.0];
	
}

- (int) countMovieViews
{
	// Check how many videos are displayed - assume main one is
	
	int movieViewCount = 1;
	
	if([auxMovieView1 movieSourceAssociated] && ![auxMovieView1 movieScheduledForRemoval])
		movieViewCount++;
	
	if([auxMovieView2 movieSourceAssociated] && ![auxMovieView2 movieScheduledForRemoval])
		movieViewCount++;
	
	return movieViewCount;
	
}

- (void) prepareToAnimateMovieViews:(MovieView *)newView From:(int)movieDirection
{
	if(moviesAnimating)
		return;
	
	if(newView && movieDirection != MV_CURRENT_POSITION)
		[self prePositionMovieView:newView From:movieDirection];	
}

- (void) animateMovieViews:(MovieView *)newView From:(int)movieDirection
{
	if(moviesAnimating)
		return;
	
	moviesAnimating = true;
	
    // Remove the time controls if they are there
    // Switch off time controller if we're returning to a forced live view
    if([BasePadViewController timeControllerDisplayed])
    {
        [self toggleTimeControllerDisplay];
        timeControllerPending = true;
    }
    
	// Hide labels before animating
	[mainMovieView hideMovieLabels];
	[auxMovieView1 hideMovieLabels];
	[auxMovieView2 hideMovieLabels];
	
	// Put the movies in position and animate
	if(newView && movieDirection != MV_CURRENT_POSITION)
		[self prePositionMovieView:newView From:movieDirection];
	
	if([auxMovieView1 movieSourceAssociated] && ![auxMovieView1 movieScheduledForRemoval])
		[self showAuxMovieView:auxMovieView1];
	
	if([auxMovieView2 movieSourceAssociated] && ![auxMovieView2 movieScheduledForRemoval])
		[self showAuxMovieView:auxMovieView2];
	
	[auxMovieView1 hideMovieLabels];
	[auxMovieView2 hideMovieLabels];
	
	int movieViewCount = [self countMovieViews];
	
	if(movieViewCount > 1)
	{
		[self setPitchDisplayed:true];
		[pitchView setAlpha:0.0];
		[pitchView setHidden:false];
	}
	else
	{
		[self setPitchDisplayed:false];
	}
	
	[UIView beginAnimations:nil context:nil];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(movieViewAnimationDidStop:finished:context:)];
	
	[UIView setAnimationDuration:1.0];
	
	[self positionMovieViews];
	
	if(displayPitch)
		[pitchView setAlpha:1.0];
	else
		[pitchView setAlpha:0.0];
	
	[UIView commitAnimations];
}

- (void) movieViewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	moviesAnimating = false;
	
	if(![auxMovieView1 movieSourceAssociated] || [auxMovieView1 movieScheduledForRemoval])
	{
        if(![auxMovieView1 movieSourceCached])
            [auxMovieView1 removeMovieFromView];
        
		[self hideAuxMovieView:auxMovieView1];
	}
	
	if(![auxMovieView2 movieSourceAssociated] || [auxMovieView2 movieScheduledForRemoval])
	{
        if(![auxMovieView2 movieSourceCached])
            [auxMovieView2 removeMovieFromView];
        
		[self hideAuxMovieView:auxMovieView2];
	}
	
	// Show hide labels
	if([mainMovieView shouldShowLabels])
		[mainMovieView showMovieLabels:MV_CLOSE_NO_AUDIO];
	else
		[mainMovieView hideMovieLabels];
	
	if([auxMovieView1 shouldShowLabels])
		[auxMovieView1 showMovieLabels:MV_CLOSE_NO_AUDIO];
	else
		[auxMovieView1 hideMovieLabels];

	if([auxMovieView2 shouldShowLabels])
		[auxMovieView2 showMovieLabels:MV_CLOSE_NO_AUDIO];
	else
		[auxMovieView2 hideMovieLabels];
    
	// Deal with pitch if not displayed
	if(!displayPitch)
	{
		[pitchView setHidden:true];
		[pitchView setAlpha:1.0];
	}
	
    // Restore the time controls if needed
    if(timeControllerPending && ![BasePadViewController timeControllerDisplayed])
    {
        [self toggleTimeControllerDisplay];
    }
    
    timeControllerPending = false;

}

- (void) showAuxMovieView:(MovieView *)viewPtr
{
	[viewPtr setHidden:false];
}

- (void) hideAuxMovieView:(MovieView *)viewPtr
{
	[viewPtr setHidden:true];
}

- (void) showAuxMovieViewByIndex:(int)viewNumber
{
	switch(viewNumber)
	{
		case 1:
			[auxMovieView1 setHidden:false];
			break;
			
		case 2:
			[auxMovieView2 setHidden:false];
			break;
	}
}

- (void) hideAuxMovieViewByIndex:(int)viewNumber
{
	switch(viewNumber)
	{
		case 1:
			[auxMovieView1 setHidden:true];
			break;
			
		case 2:
			[auxMovieView2 setHidden:true];
			break;
	}
}

- (MovieView *) auxMovieView:(int)viewNumber
{
	switch(viewNumber)
	{
		case 1:
			return auxMovieView1;
			
		case 2:
			return auxMovieView2;
	}
	
	return nil;
}

- (MovieView *) findFreeMovieView
{
	if(auxMovieView1 && ![auxMovieView1 movieSourceAssociated])
	{
		priorityAuxMovie = 1;
		return auxMovieView1;
	}
	else if(auxMovieView2 && ![auxMovieView2 movieSourceAssociated])
	{
		priorityAuxMovie = 2;
		return auxMovieView2;
	}
	else if(priorityAuxMovie == 2)
	{
		priorityAuxMovie = 1;
		return auxMovieView1;
	}
	else
	{
		priorityAuxMovie = 2;
		return auxMovieView2;
	}
	
	return nil;
}

- (void) notifyMovieInformation
{
	/*
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
	*/
	
	[videoDelayLabel setHidden:true];
	
}

- (void) notifyChangeToLiveMode
{
    [mainMovieView updateMovieLabels];
    [auxMovieView1 updateMovieLabels];
	[auxMovieView2 updateMovieLabels];
}

/////////////////////////////////////////////////////////////////////
// Overlay Controls

- (UIView *) timeControllerAddOnOptionsView
{
	return nil;
}

- (void) positionOverlays
{
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
	{
		if ( displayVideo )
		{
			CGRect viewRect = CGRectMake(0, 0, bg_frame.size.width, bg_frame.size.height / 4 * 3 );
			CGRect pitchRect = CGRectMake(0, viewRect.size.height, bg_frame.size.width, bg_frame.size.height / 4);
			[mainMovieView setFrame:viewRect];
			[pitchView setFrame:pitchRect];
		}
		else
		{
			[pitchView setFrame:bg_frame];
		}
	}
	else
	{
		[mainMovieView setFrame:bg_frame];
	}
	
	// Work out movie position
	CGRect movieViewBounds = [mainMovieView bounds];
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
	[self updateScore];
}

- (void) RequestRedraw
{
	[self updateScore];
}

- (void)setVideoDisplayed:(bool)state
{
	/*
	if(state)
	{
		if(!displayPitch)
		{
			displayPitch = true;
			[pitchView setHidden:false];
			
			[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];
			
			[pitchView RequestRedraw];
		}
	}
	else
	{
		if(displayPitch)
		{
			displayPitch = false;
			[pitchView setHidden:true];
			[[MatchPadCoordinator Instance] SetViewHidden:pitchView];
		}
	}
	*/
}

- (void)setPitchDisplayed:(bool)state
{
	// Change state and data streaming. Display of view itself will behandled by animation.
	if(state)
	{
		if(!displayPitch)
		{
			displayPitch = true;			
			[[MatchPadCoordinator Instance] SetViewDisplayed:pitchView];			
			[pitchView RequestRedraw];
		}
	}
	else
	{
		if(displayPitch)
		{
			displayPitch = false;
			[[MatchPadCoordinator Instance] SetViewHidden:pitchView];
		}
		
	}
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	// Reach here if either tap was outside any other sensitive area
	if([BasePadViewController timeControllerDisplayed] || !autoHideButtons)
		[self toggleTimeControllerDisplay];
	
	if(autoHideButtons)
	{
		// Either close popup views if there are any or pop menus up or down
		if(![self dismissPopupViews])
			[self handleMenuButtonDisplayGestureInView:gestureView AtX:x Y:y];
	}
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if(!gestureView)
		return;
	
	if([gestureView isKindOfClass:[MovieView class]])
	{	
		int movieCount = [self countMovieViews];
		
		if(!moviesAnimating)
		{
			if(gestureView == mainMovieView)
			{
				if(movieCount > 1)
				{
					[auxMovieView1 setMovieScheduledForRemoval:true];
					[auxMovieView2 setMovieScheduledForRemoval:true];
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
			}
			else if(gestureView == auxMovieView1)
			{
				if(priorityAuxMovie != 1)
				{
					priorityAuxMovie = 1;
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
				else
				{
					if([auxMovieView2 movieSourceAssociated] && priorityAuxMovie == 1)
					{
						priorityAuxMovie = 2;
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
					else
					{
						[auxMovieView1 setMovieScheduledForRemoval:true];
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
				}
			}
			else if(gestureView == auxMovieView2)
			{
				if(priorityAuxMovie != 2)
				{
					priorityAuxMovie = 2;
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
				else
				{
					if([auxMovieView1 movieSourceAssociated] && priorityAuxMovie == 2)
					{
						priorityAuxMovie = 1;
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
					else
					{
						[auxMovieView2 setMovieScheduledForRemoval:true];
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
				}
			}
		}
	}	
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// If it's a movie view, reload movie
	if(gestureView && [gestureView isKindOfClass:[MovieView class]])
	{
		[(MovieView *)gestureView redisplayMovieSource];
	}
	
	// Otherwise, temporarily display pitch view
	if(![[MatchPadPitchStatsManager Instance] viewDisplayed])
	{
		CGRect viewBounds = [self.view bounds];
		float xCentre = CGRectGetWidth(viewBounds) * 0.5;
		[[MatchPadPitchStatsManager Instance] displayInViewController:self AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
	}		
}


- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	if(!gestureView)
		return;
		
	if([gestureView isKindOfClass:[MovieView class]])
	{	
		if(!moviesAnimating)
		{
			if(gestureView == mainMovieView)
			{
				if(scale > 1)
				{
					[auxMovieView1 setMovieScheduledForRemoval:true];
					[auxMovieView2 setMovieScheduledForRemoval:true];
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
			}
			else if(gestureView == auxMovieView1)
			{
				if(scale > 1 && priorityAuxMovie != 1)
				{
					priorityAuxMovie = 1;
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
				else if(scale < 1)
				{
					if([auxMovieView2 movieSourceAssociated] && priorityAuxMovie == 1)
					{
						priorityAuxMovie = 2;
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
					else
					{
					   [auxMovieView1 setMovieScheduledForRemoval:true];
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
				}
			}
			else if(gestureView == auxMovieView2)
			{
				if(scale > 1 && priorityAuxMovie != 2)
				{
					priorityAuxMovie = 2;
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
				else if(scale < 1)
				{
					if([auxMovieView1 movieSourceAssociated] && priorityAuxMovie == 2)
					{
						priorityAuxMovie = 1;
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
					else
					{
						[auxMovieView2 setMovieScheduledForRemoval:true];
						[self animateMovieViews:nil From:MV_CURRENT_POSITION];
					}
				}
			}
		}
	}	
}

- (void) OnPanGestureInView:(UIView *)gestureView ByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy State:(int)state
{
	// Ignore lifting finger
	if(state == UIGestureRecognizerStateEnded)
		return;
}


////////////////////////////////////////////////////////////////////////
//  Callback functions

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[self positionOverlays];
	[self showOverlays];
}

- (IBAction) movieCloseButtonHit:(id)sender
{
	if(!moviesAnimating)
	{
		if(sender == mainMovieViewCloseButton)
		{
            int movieCount = [self countMovieViews];
			if(movieCount > 1)
			{
				[auxMovieView1 setMovieScheduledForRemoval:true];
				[auxMovieView2 setMovieScheduledForRemoval:true];
				[self animateMovieViews:nil From:MV_CURRENT_POSITION];
			}
		}
		else if(sender == auxMovieView1CloseButton)
		{
			[auxMovieView1 setMovieScheduledForRemoval:true];
			[self animateMovieViews:nil From:MV_CURRENT_POSITION];
		}
		else if(sender == auxMovieView2CloseButton)
		{
			[auxMovieView2 setMovieScheduledForRemoval:true];
			[self animateMovieViews:nil From:MV_CURRENT_POSITION];
		}
	}
}

- (IBAction) closeButtonHit:(id)sender
{
}

- (IBAction) menuButtonHit:(id)sender
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMenuButtons) object:nil];
		
	CGRect viewBounds = [self.view bounds];
	float xCentre = CGRectGetWidth(viewBounds) * 0.5;

	if(sender == mainMenuButton)
	{
		if(![[MatchPadMasterMenuManager Instance] viewDisplayed])
		{
			mainMenuButtonOpen = true;
			
			[[MatchPadMasterMenuManager Instance] grabExclusion:self];
			[[MatchPadMasterMenuManager Instance] displayInViewController:self AtX:0 Animated:true Direction:POPUP_DIRECTION_RIGHT_ XAlignment:POPUP_ALIGN_FULL_SCREEN_ YAlignment:POPUP_ALIGN_FULL_SCREEN_];
		}
		else
		{
			[[MatchPadMasterMenuManager Instance] hideAnimated:true Notify:true];
		}
		
		[self.view bringSubviewToFront:mainMenuButton];
	}
	
	if(sender == helpButton)
	{
		if(![[MatchPadHelpManager Instance] viewDisplayed])
		{
			helpButtonOpen = true;
			
			[[MatchPadHelpManager Instance] grabExclusion:self];
			[[MatchPadHelpManager Instance] displayInViewController:self AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_LEFT_ YAlignment:POPUP_ALIGN_TOP_];
		}
	}
	
	if(sender == settingsButton)
	{
		if(![[MatchPadSettingsManager Instance] viewDisplayed])
		{
			settingsButtonOpen = true;
			
			[[MatchPadSettingsManager Instance] grabExclusion:self];
			[[MatchPadSettingsManager Instance] displayInViewController:self AtX:xCentre Animated:true Direction:POPUP_DIRECTION_NONE_ XAlignment:POPUP_ALIGN_CENTRE_ YAlignment:POPUP_ALIGN_CENTRE_];
		}
	}
	
	if(sender == statsButton)
	{
		if(![[MatchPadStatsManager Instance] viewDisplayed])
		{
			statsButtonOpen = true;
			
			[[MatchPadStatsManager Instance] grabExclusion:self];
			[[MatchPadStatsManager Instance] displayInViewController:self AtX:CGRectGetMaxX(viewBounds) Animated:true Direction:POPUP_DIRECTION_LEFT_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == highlightsButton)
	{
		if(![[MatchPadHighlightsManager Instance] viewDisplayed])
		{
			highlightsButtonOpen = true;
			
			[[MatchPadHighlightsManager Instance] grabExclusion:self];
			[[MatchPadHighlightsManager Instance] displayInViewController:self AtX:CGRectGetMaxX(viewBounds) Animated:true Direction:POPUP_DIRECTION_LEFT_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}		
	}
	
	if(sender == replaysButton)
	{
		if(![[MatchPadReplaysManager Instance] viewDisplayed])
		{
			replaysButtonOpen = true;
			
			[[MatchPadReplaysManager Instance] grabExclusion:self];
			[[MatchPadReplaysManager Instance] displayInViewController:self AtX:CGRectGetMaxX(viewBounds) Animated:true Direction:POPUP_DIRECTION_LEFT_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}		
	}
    
    if(sender == codingButton)
	{
		if(![[MatchPadCodingManager Instance] viewDisplayed])
		{
			codingButtonOpen = true;
			
			[[MatchPadCodingManager Instance] grabExclusion:self];
			[[MatchPadCodingManager Instance] displayInViewController:self AtX:CGRectGetMaxX(viewBounds) Animated:true Direction:POPUP_DIRECTION_LEFT_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}
	}

	
}

- (void) notifyHidingTimeControls
{
	[self showMenuButtons];
}

- (void) toggleTimeControllerDisplay
{
    id timeControllerInstance = [BasePadViewController timeControllerInstance];
    
    bool delay = false;
    
	if ( timeControllerInstance && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
		if(![timeControllerInstance timeControllerDisplayed])
		{
            // If we only have a forced live video view displayed, add another one when the time controller is brought up
            int movieCount = [self countMovieViews];
			
            if(movieCount <= 1)
            {
                if(mainMovieView && [mainMovieView movieSourceAssociated] && [mainMovieView movieSource] && [[mainMovieView movieSource] movieForceLive])
                {
                    BasePadVideoSource * videoSource = [[BasePadMedia Instance] findNextMovieForReview];
                    
                    if(videoSource && ![videoSource movieDisplayed])
                    {
                        MovieView * auxMovieView = [self findFreeMovieView];
                        if(auxMovieView)
                        {
                            [self prepareToAnimateMovieViews:auxMovieView From:MV_MOVIE_FROM_BOTTOM];
                            [auxMovieView setMovieViewDelegate:self];
                            [auxMovieView displayMovieSource:videoSource]; // Will get notification when finished
                            
                            [self animateMovieViews:auxMovieView From:MV_MOVIE_FROM_BOTTOM];
                            
                            delay = true;
                            
                        }
                    }
                }
            }
			
            if(delay)
                [self performSelector:@selector(executeTimeControllerDisplay) withObject:nil afterDelay: 1.0];
            else
                [self executeTimeControllerDisplay];
		}
		else
		{
			[timeControllerInstance hideTimeController];
		}
	}
}

- (void) executeTimeControllerDisplay
{
    id timeControllerInstance = [BasePadViewController timeControllerInstance];
	CGRect playerRect = priorityAuxMovie == 1 ? [auxMovieView1 frame] : [auxMovieView2 frame];
	CGRect timerRect = CGRectInset (playerRect, 20, 0);

	if ( timeControllerInstance && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
        [timeControllerInstance displayTimeControllerInViewController:self InRect:timerRect Animated:true];
    }
    
    // Ensure that all displayed popups are in front
    if(statsButtonOpen)
        [[MatchPadStatsManager Instance] bringToFront];
    
	if(highlightsButtonOpen)
        [[MatchPadHighlightsManager Instance] bringToFront];
	
	if(replaysButtonOpen)
        [[MatchPadReplaysManager Instance] bringToFront];
	
	if(codingButtonOpen)
        [[MatchPadCodingManager Instance] bringToFront];
	
	if(settingsButtonOpen)
        [[MatchPadSettingsManager Instance] bringToFront];
		
	if(helpButtonOpen)
        [[MatchPadHelpManager Instance] bringToFront];
}

- (void) executeTimeControllerHide
{
    id timeControllerInstance = [BasePadViewController timeControllerInstance];
	if ( timeControllerInstance && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
        [timeControllerInstance hideTimeController];
    }
}

- (void) updateScore
{
	[homeTeamLabel setText:[[MatchPadDatabase Instance] homeTeam]];
	[awayTeamLabel setText:[[MatchPadDatabase Instance] awayTeam]];
	
	[homeScoreLabel setText:[NSString stringWithFormat:@"%d", [[MatchPadDatabase Instance] homeScore]]];
	[awayScoreLabel setText:[NSString stringWithFormat:@"%d", [[MatchPadDatabase Instance] awayScore]]];
}

///////////////////////////////////////////////////////////////////
// Button Animation Routines

// Button positions

-(void)positionMenuButtons
{
	if(mainMenuButtonOpen)
		[mainMenuButton setFrame:CGRectMake(0,332,91,61)];
	else
		[mainMenuButton setFrame:CGRectMake(-36,332,91,61)];
	
	// Get the bounds of the view controller
	//CGRect viewBounds = [[self view] bounds];
	
	// Menu buttons positioned in Nib now
	/*
	// And position the buttons
	CGRect buttonFrame;
	
	float topY = 148;
	
	// Stats button
	buttonFrame = [statsButton frame];
	[statsButton setFrame:CGRectMake(CGRectGetMaxX(viewBounds) - CGRectGetWidth(buttonFrame), topY, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	
	topY += CGRectGetHeight(buttonFrame);	
	topY += 2;
	
	// Replays button
	buttonFrame = [replaysButton frame];
	[replaysButton setFrame:CGRectMake(CGRectGetMaxX(viewBounds) - CGRectGetWidth(buttonFrame), topY, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	
	topY += CGRectGetHeight(buttonFrame);	
	topY += 2;
	 */
	
}

////////////////////////////////
// Button show and hide

-(void)hideMenuButtons
{
	if(!menuButtonsDisplayed || menuButtonsAnimating)
		return;
	
	menuButtonsAnimating = true;
	
	[UIView beginAnimations:nil context:NULL];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(menuAnimationDidStop:finished:context:)];
	
	[UIView setAnimationDuration:0.75];
		
	if(mainMenuButtonOpen)
		[mainMenuButton setFrame:CGRectMake(0,332,91,61)];
	else
		[mainMenuButton setFrame:CGRectMake(-91,332,91,61)];
	
	[codingButton setFrame:CGRectOffset([codingButton frame], CGRectGetWidth([codingButton frame]), 0)];
	[replaysButton setFrame:CGRectOffset([replaysButton frame], CGRectGetWidth([replaysButton frame]), 0)];
	[statsButton setFrame:CGRectOffset([statsButton frame], CGRectGetWidth([statsButton frame]), 0)];
	[highlightsButton setFrame:CGRectOffset([highlightsButton frame], CGRectGetWidth([highlightsButton frame]), 0)];
	
	[UIView commitAnimations];
}

-(void)showMenuButtons
{
	if(menuButtonsDisplayed || menuButtonsAnimating)
		return;
	
	menuButtonsAnimating = true;
	
	[UIView beginAnimations:nil context:NULL];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(menuAnimationDidStop:finished:context:)];
	
	[UIView setAnimationDuration:0.5];
	
	if(mainMenuButtonOpen)
		[mainMenuButton setFrame:CGRectMake(0,332,91,61)];
	else
		[mainMenuButton setFrame:CGRectMake(-36,332,91,61)];
	
	[codingButton setFrame:CGRectOffset([codingButton frame], -CGRectGetWidth([codingButton frame]), 0)];
	[replaysButton setFrame:CGRectOffset([replaysButton frame], -CGRectGetWidth([replaysButton frame]), 0)];
	[highlightsButton setFrame:CGRectOffset([highlightsButton frame], -CGRectGetWidth([highlightsButton frame]), 0)];
	[statsButton setFrame:CGRectOffset([statsButton frame], -CGRectGetWidth([statsButton frame]), 0)];
		
	[UIView commitAnimations];
}

- (void)menuAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if(menuButtonsAnimating)	// To make sure we don't get callback from animation ending AND backup
	{
		menuButtonsDisplayed = !menuButtonsDisplayed;
		menuButtonsAnimating = false;
	}
}


// Button opening for popup display

-(void)animateMenuButton:(UIButton *)button
{
	if(!menuButtonsDisplayed || menuButtonsAnimating)
		return;
	
	menuButtonsAnimating = true;
	
	[UIView beginAnimations:nil context:button];
		
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(menuButtonAnimationDidStop:finished:context:)];
		
	[UIView setAnimationDuration:0.5];
		
	[self positionMenuButtons];
		
	[UIView commitAnimations];
}

- (void)menuButtonAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	menuButtonsAnimating = false;
}

// Popup view management

- (bool) dismissPopupViews
{
	return [self dismissPopupViewsWithExclusion:MP_POPUP_NONE_ InZone:(int)MP_ZONE_ALL_ AnimateMenus:true];
}

- (bool) dismissPopupViewsWithExclusion:(int)excludedPopupType InZone:(int)popupZone AnimateMenus:(bool)animateMenus
{
    // We can arrive here out of sync with popup menu button presses
    // The tap will have waited for the double tap timer to expire, and we may
    // have pressed a menu button in the meantime, but not dealt with the display.
    // If this is so, we'll ignore this tap, but mark it as dealt with.
    
    if(popupNotificationPending)
        return true;
    
	bool popupDismissed = false;
	
	if(excludedPopupType != MP_HELP_POPUP_ &&
	   [[MatchPadHelpManager Instance] viewDisplayed] &&
	   (popupZone & MP_ZONE_CENTRE_) > 0)
	{
		[[MatchPadHelpManager Instance] hideAnimated:true Notify:true];
		helpButtonOpen = false;
		popupDismissed= true;
	}
	
	if(excludedPopupType != MP_SETTINGS_POPUP_ &&
	   [[MatchPadSettingsManager Instance] viewDisplayed] &&
	   (popupZone & MP_ZONE_CENTRE_) > 0)
	{
		[[MatchPadSettingsManager Instance] hideAnimated:true Notify:true];
		settingsButtonOpen = false;
		popupDismissed= true;
	}
	
	if(excludedPopupType != MP_STATS_POPUP_ &&
	   [[MatchPadStatsManager Instance] viewDisplayed] &&
	   (popupZone & MP_ZONE_RIGHT_) > 0)
	{
		[[MatchPadStatsManager Instance] hideAnimated:true Notify:true];
		statsButtonOpen = false;
		popupDismissed= true;
	}
	
	if(excludedPopupType != MP_HIGHLIGHTS_POPUP_ &&
	   [[MatchPadHighlightsManager Instance] viewDisplayed] &&
	   (popupZone & MP_ZONE_RIGHT_) > 0)
	{
		[[MatchPadHighlightsManager Instance] hideAnimated:true Notify:true];
		highlightsButtonOpen = false;
		popupDismissed= true;
	}
	
	if(excludedPopupType != MP_REPLAYS_POPUP_ &&
	   [[MatchPadReplaysManager Instance] viewDisplayed] &&
	   (popupZone & MP_ZONE_RIGHT_) > 0)
	{
		[[MatchPadReplaysManager Instance] hideAnimated:true Notify:true];
		replaysButtonOpen = false;
		popupDismissed= true;
	}
	
	if(excludedPopupType != MP_CODING_POPUP_ &&
	   [[MatchPadCodingManager Instance] viewDisplayed] &&
	   (popupZone & MP_ZONE_RIGHT_) > 0)
	{
		[[MatchPadCodingManager Instance] hideAnimated:true Notify:true];
		codingButtonOpen = false;
		popupDismissed= true;
	}

	if(animateMenus && popupDismissed)
		[self animateMenuButton:nil];
	
	return popupDismissed;
}


/////////////////////////////////////////////////////////////////////////////////
// Gesture recogniser handling

- (void) handleMenuButtonDisplayGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	if ( !menuButtonsAnimating)
	{
		if(!menuButtonsDisplayed)
		{
			[self showMenuButtons];
		}
		else
		{
			[self hideMenuButtons];
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////
// BasePadPopupParentDelegate methods

#pragma mark BasePadPopupParentDelegate methods

- (void)notifyShowingPopup:(int)popupType
{
	// Called within the animation brace
    switch(popupType)
    {
        case MP_HELP_POPUP_:
            [helpButton setHidden:true];
            break;
            
        case MP_STATS_POPUP_:
            [statsButton setHidden:true];
            break;
            
		case MP_HIGHLIGHTS_POPUP_:
            [highlightsButton setHidden:true];
            break;
            
		case MP_REPLAYS_POPUP_:
            [replaysButton setHidden:true];
            break;
            
 		case MP_CODING_POPUP_:
            [codingButton setHidden:true];
            break;
            
        default:
            break;
    }
	
	[self.view bringSubviewToFront:statsButton];
	[self.view bringSubviewToFront:highlightsButton];
	[self.view bringSubviewToFront:replaysButton];
	[self.view bringSubviewToFront:codingButton];
	
	[self positionMenuButtons];

    popupNotificationPending = true; // means there will be a call to notifyShowedPopup
}
	
- (void)notifyShowedPopup:(int)popupType
{
	// Called after animation is finished
	
   popupNotificationPending = false;
}

- (void)notifyHidingPopup:(int)popupType
{
	// Called within the animation brace
}

- (void)notifyHidPopup:(int)popupType
{
	// Called after animation is finished
	
	switch(popupType)
	{
		case MP_MASTER_MENU_POPUP_:
			mainMenuButtonOpen = false;
			[self positionMenuButtons];
			break;
			
		case MP_SETTINGS_POPUP_:
			settingsButtonOpen = false;
			[settingsButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MP_HELP_POPUP_:
			helpButtonOpen = false;
			[helpButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MP_STATS_POPUP_:
			statsButtonOpen = false;
			[statsButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MP_HIGHLIGHTS_POPUP_:
			highlightsButtonOpen = false;
			[highlightsButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MP_REPLAYS_POPUP_:
			replaysButtonOpen = false;
			[replaysButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MP_CODING_POPUP_:
			codingButtonOpen = false;
			[codingButton setHidden:false];
			[self positionMenuButtons];
			break;

		default:
			break;
	}
}

- (void)notifyResizingPopup:(int)popupType
{
	[self positionMenuButtons];
}

- (void)notifyExclusiveUse:(int)popupType InZone:(int)popupZone
{
	[self dismissPopupViewsWithExclusion:popupType InZone:popupZone AnimateMenus:false];
}


/////////////////////////////////
// Advertising logo animations

- (void) initialiseLogoImages
{
    currentLogoIndex = 0;
    currentLogoImageView = 0;
    
    [logoImageView0 setHidden:false];
    [logoImageView1 setHidden:false];
    
    [logoImageView0 setAlpha:1.0];
    [logoImageView1 setAlpha:0.0];
    
    [self setNextLogoImage:0 InView:0];
}

- (void) showLogoImages
{
	[logoImageBase setAlpha:0.0];
	[logoImageBase setHidden:false];
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[logoImageBase setAlpha:1.0];
	[UIView commitAnimations];
}

- (void) hideLogoImages
{
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	[logoImageBase setAlpha:0.0];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(hideLogoImagesAnimationDidStop:finished:context:)];
	[UIView commitAnimations];
}

- (void) hideLogoImagesAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context
{
    [logoImageBase setHidden:true];
}

- (void) startLogoAnimation
{
	logoAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(logoAnimationTimerFired:) userInfo:nil repeats:YES];
}

- (void) endLogoAnimation
{
    if(logoAnimationTimer)
        [logoAnimationTimer invalidate];
    
    logoAnimationTimer = nil;
}

- (bool) setNextLogoImage:(int)imageIndex InView:(int)viewIndex
{
    UIImageView * imageView = viewIndex == 0 ? logoImageView0 : logoImageView1;
    
    UIImage * image = nil;
    
    if(imageIndex == 0)
        image = [UIImage imageNamed:@"MidasLogoPirelli.png"];
    else if(imageIndex == 1)
        image = [UIImage imageNamed:@"MidasLogoMobil1.png"];
    else if(imageIndex == 2)
        image = [UIImage imageNamed:@"MidasLogoATT.png"];
    
    if(imageView && image)
    {
        [imageView setImage:image];
        return true;
    }
    else
    {
        return false;
    }
}

-(void)logoAnimationTimerFired: (NSTimer *)theTimer
{
    int nextLogoIndex = (currentLogoIndex + 1) % 3;
    int nextLogoImageView = 1 - currentLogoImageView;
    
    bool imageFound = [self setNextLogoImage:nextLogoIndex InView:nextLogoImageView];

    UIImageView * imageView = nextLogoImageView == 0 ? logoImageView0 : logoImageView1;
    UIImageView * otherImageView = nextLogoImageView == 0 ? logoImageView1 : logoImageView0;
    
    if(imageFound && imageView)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1.0];
        [imageView setAlpha:1.0];
        [otherImageView setAlpha:0.0];
        [UIView commitAnimations];
        
        currentLogoImageView = nextLogoImageView;
    }
    
    currentLogoIndex = nextLogoIndex;

}

- (IBAction) logoDisplayButtonHit:(id)sender
{
	if(!moviesAnimating)
	{
        if(displayLogos)
        {
            [logoImageBase setHidden:true];
            [self endLogoAnimation];
            displayLogos = false;
        }
        else
        {
            int movieCount = [self countMovieViews];

            if(movieCount > 1)
            {
                [logoImageBase setHidden:false];
                [self startLogoAnimation];
            }
        
            displayLogos = true;
        }
    }
}

@end


