//
//  MidasVideoViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasVideoViewController.h"

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


@implementation MidasVideoViewController

@synthesize mainMovieView;
@synthesize auxMovieView1;
@synthesize auxMovieView2;


@synthesize displayVideo;
@synthesize displayMap;
@synthesize displayLeaderboard;

@synthesize allowBubbleCommentary;

@synthesize midasMenuButtonOpen;
@synthesize helpButtonOpen;
@synthesize alertsButtonOpen;
@synthesize socialMediaButtonOpen;	
@synthesize vipButtonOpen;
@synthesize lapCounterButtonOpen;
@synthesize standingsButtonOpen;
@synthesize mapButtonOpen;
@synthesize followDriverButtonOpen;
@synthesize cameraButtonOpen;
@synthesize timeControlsButtonOpen;
@synthesize myTeamButtonOpen;

static UIImage * selectedTopButtonImage = nil;
static UIImage * unselectedTopButtonImage = nil;

static UIImage * newButtonBackgroundImage = nil;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		// This view is always displayed as a subview
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		if(!selectedTopButtonImage)
		{
			selectedTopButtonImage = [[UIImage imageNamed:@"movement-notification-container.png"] retain];
			unselectedTopButtonImage = [[UIImage imageNamed:@"top-container-unselected.png"] retain];
		}
		else
		{
			[selectedTopButtonImage retain];
			[unselectedTopButtonImage retain];
		}
		
	}
    return self;
}

- (void)viewDidLoad
{	
	
	[super viewDidLoad];
	
	// Fixed data
	unselectedButtonWidth = 44;
	selectedButtonWidth = 147;
	
	// Initialise display options
	
	menuButtonsDisplayed = true;
	menuButtonsAnimating = false;
	moviesAnimating = false;
	flashedMenuButton = nil;
	
	midasMenuButtonOpen = false;
	helpButtonOpen = false;
	alertsButtonOpen = false;
	socialMediaButtonOpen = false;	
	vipButtonOpen = false;
	lapCounterButtonOpen = false;
	standingsButtonOpen = false;
	mapButtonOpen = false;
	followDriverButtonOpen = false;
	cameraButtonOpen = false;
	timeControlsButtonOpen = false;
	myTeamButtonOpen = false;
	
	socialMediaButtonFlashed = false;
    timeControllerPending = false;

	firstDisplay = true;
	
	displayMap = false;
	displayLeaderboard = false;
	displayVideo = true;
	
	disableOverlays = false;
	
	allowBubbleCommentary = false;
	
	priorityAuxMovie = 1;
	movieViewsStored = false;
	
	[mainMovieView setStyle:BG_STYLE_INVISIBLE_];
	[auxMovieView1 setStyle:BG_STYLE_INVISIBLE_];
	[auxMovieView2 setStyle:BG_STYLE_INVISIBLE_];
	
	[mainMovieView setTitleView:mainMovieViewTitleView];
	[mainMovieView setTitleBackgroundImage:mainMovieViewTitleBackgroundImage];
	
	[auxMovieView1 setTitleView:auxMovieView1TitleView];
	[auxMovieView1 setAudioImage:auxMovieView1AudioImage];
	[auxMovieView1 setTitleBackgroundImage:auxMovieView1TitleBackgroundImage];
	
	[auxMovieView2 setTitleView:auxMovieView2TitleView];
	[auxMovieView2 setAudioImage:auxMovieView2AudioImage];
	[auxMovieView2 setTitleBackgroundImage:auxMovieView2TitleBackgroundImage];
		
	[mainMovieView setCloseButton:nil];
	[auxMovieView1 setCloseButton:auxMovieView1CloseButton];
	[auxMovieView2 setCloseButton:auxMovieView2CloseButton];
	
	[mainMovieView setMovieNameButton:mainMovieViewDriverName];
	[auxMovieView1 setMovieNameButton:auxMovieView1DriverName];
	[auxMovieView2 setMovieNameButton:auxMovieView2DriverName];
	
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
	
	[pushNotificationAnimationImage setHidden:true];
	[pushNotificationAnimationLabel setHidden:true];
	
	[auxMovieView1 setHidden:true];
	[auxMovieView2 setHidden:true];
	
	// Position the menu buttons
	[self positionMenuButtons];
	
	// GG - COMMENT OUT LEADERBOARD :
	[leaderboardView setHidden:true];
	
	// Set the types on the two map views
	[trackMapView setIsZoomView:false];
	[trackMapView setIsOverlayView:true];
	[trackMapView setMidasStyle:true];

	[trackZoomView setIsZoomView:false];
	[trackZoomView setIsOverlayView:false];
	[trackZoomView setSmallSized:true];
	[trackMapView setMidasStyle:true];
	
	//[trackZoomContainer setStyle:BG_STYLE_MIDAS_TRANSPARENT_];
	[trackZoomContainer setStyle:BG_STYLE_INVISIBLE_];
	[trackZoomContainer setHidden:true];
	trackZoomOffsetX = 0;
	trackZoomOffsetY = 0;
	
	// Set leaderboard data source and associate  with zoom map
 	// GG - COMMENT OUT LEADERBOARD : [leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	// GG - COMMENT OUT LEADERBOARD : [leaderboardView setAssociatedTrackMapView:trackZoomView];
	
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
	
	// Add tap and long press recognizers to overlay and movie views in order to catch taps outside map
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
	
	// Add tap recognizer to button panels to dismiss menus
	[self addTapRecognizerToView:topButtonPanel];
	[self addTapRecognizerToView:bottomButtonPanel];
	
	// Add tap and long press recognizers to the leaderboard
	// GG - COMMENT OUT LEADERBOARD : [self addTapRecognizerToView:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : [self addLongPressRecognizerToView:leaderboardView];
	
	// Add long press and pinch recognizers to the overlay to reset video windows (TEMPORARY)
	[self addLongPressRecognizerToView:overlayView];
	[self addLongPressRecognizerToView:mainMovieView];
	[self addLongPressRecognizerToView:auxMovieView1];
	[self addLongPressRecognizerToView:auxMovieView2];
	
	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:mainMovieView WithType:RPC_VIDEO_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackZoomView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_LAP_COUNT_VIEW_];
	// GG - COMMENT OUT LEADERBOARD : [[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	
	[[RacePadCoordinator Instance] setVideoViewController:self];
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_VIDEO_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_ | RPC_TRACK_STATE_VIEW_)];
	[[MidasCoordinator Instance] RegisterSocialmediaResponder:self WithTypeMask:MIDAS_SM_ALL_];
	
	// We'll get notification when we know the movie size - set it to a default for now
	movieSize = CGSizeMake(768, 576);
	movieRect = CGRectMake(0, 0, 768, 576);
	[self positionOverlays];
	
	[mainMovieView bringSubviewToFront:overlayView];
	[mainMovieView bringSubviewToFront:trackMapView];
	// GG - COMMENT OUT LEADERBOARD : [movieView bringSubviewToFront:leaderboardView];
	/// GG - ZOOM MAP NOW NOT CHILD OF MOVIE :[mainMovieView bringSubviewToFront:trackZoomContainer];
	/// GG - ZOOM MAP NOW NOT CHILD OF MOVIE :[mainMovieView bringSubviewToFront:trackZoomView];
	[mainMovieView bringSubviewToFront:videoDelayLabel];
	[mainMovieView bringSubviewToFront:loadingLabel];
	[mainMovieView bringSubviewToFront:loadingTwirl];
		
	if(displayVideo)
	{
		// Register us to play video
		[[BasePadMedia Instance] RegisterViewController:self];
		[[RacePadCoordinator Instance] SetViewDisplayed:mainMovieView];
		
		// Then check that we have the right movie loaded
		[mainMovieView setMovieViewDelegate:self];
		[[BasePadMedia Instance] verifyMovieLoaded];
		
	}
	
	if(displayMap)
	{
		if(disableOverlays)
		{
			[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
			[trackZoomContainer setHidden:true];
		}
		else
		{
			[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
			[trackZoomContainer setHidden:false];
		}
	}
    else
    {
        [trackZoomContainer setHidden:true];
        [[RacePadCoordinator Instance] SetViewHidden:trackZoomView];
        
        [trackMapView setHidden:true];
        [[RacePadCoordinator Instance] SetViewHidden:trackMapView];
    }
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : }
	
	[[RacePadCoordinator Instance] SetViewDisplayed:self];
	
	[[CommentaryBubble Instance] setMidasStyle:true];
	if(allowBubbleCommentary)
		[[CommentaryBubble Instance] allowBubbles:[self view] BottomRight: false];
	else
		[[CommentaryBubble Instance] noBubbles];
	
	if(firstDisplay)
	{
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
		[[RacePadCoordinator Instance] SetViewHidden:mainMovieView];
		[[BasePadMedia Instance] ReleaseViewController:self];
	}
	
	if(displayMap)
	{
		if(disableOverlays)
			[[RacePadCoordinator Instance] SetViewHidden:trackZoomView];
		else
			[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	}
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : }
	
	[[RacePadCoordinator Instance] SetViewHidden:self];
	
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	[[MidasCoordinator Instance] ReleaseSocialmediaResponder:self];
	
	// Reset the time controls to auto hide so that other view controllers are OK
	[[BasePadTimeController Instance] setAutoHide:true];

	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overridden to allow any orientation.
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
	[[CommentaryBubble Instance] willRotateInterface];
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
	
	[[CommentaryBubble Instance] didRotateInterface];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
	[selectedTopButtonImage release];
	[unselectedTopButtonImage release];
	
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
        [movieView bringSubviewToFront:trackMapView];
        // GG - COMMENT OUT LEADERBOARD : [movieView bringSubviewToFront:leaderboardView];
        [movieView bringSubviewToFront:trackZoomContainer];
        [movieView bringSubviewToFront:trackZoomView];
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
	CGRect mapInsetRect = CGRectMake(0, 54,308,260);
	
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
		[self setOverlaysDisabled:false];
		[self showOverlays];
		[mainMovieView setFrame:superBounds];
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
		[self setOverlaysDisabled:true];
		[trackZoomContainer setFrame:mapInsetRect];
		[self showOverlays];
		[mainMovieView setFrame:leftViewRect];
		[mainMovieView setShouldShowLabels:true];
        [mainMovieView setAudioMuted:true];
		if([auxMovieView1 movieSourceAssociated] && ![auxMovieView1 movieScheduledForRemoval])
		{
			priorityAuxMovie = 1;
			[auxMovieView1 setFrame:centreViewRect];
			[auxMovieView1 setShouldShowLabels:true];
			[auxMovieView2 setShouldShowLabels:false];
 		}
		else if([auxMovieView2 movieSourceAssociated] && ![auxMovieView2 movieScheduledForRemoval])
		{
			priorityAuxMovie = 2;
			[auxMovieView2 setFrame:centreViewRect];
			[auxMovieView2 setShouldShowLabels:true];
			[auxMovieView1 setShouldShowLabels:false];
		}
        [auxMovieView1 setAudioMuted:priorityAuxMovie == 2];
        [auxMovieView2 setAudioMuted:priorityAuxMovie == 1];
	}
	else if(movieViewCount == 3)
	{
		[self setOverlaysDisabled:true];
		[trackZoomContainer setFrame:mapInsetRect];
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

- (void) storeMovieViews
{
	movieViewsStored = true;
	[auxMovieView1 storeMovieSource];
	[auxMovieView2 storeMovieSource];
}

- (void) restoreMovieViews
{
	movieViewsStored = false;
	[auxMovieView1 restoreMovieSource];
	[auxMovieView2 restoreMovieSource];
}

- (void) clearMovieViewStore
{
	movieViewsStored = false;
	[auxMovieView1 clearMovieSourceStore];
	[auxMovieView2 clearMovieSourceStore];
}

- (void) prepareToAnimateMovieViews:(MovieView *)newView From:(int)movieDirection
{
	if(moviesAnimating)
		return;
	
	// Remove the backed up view layout
	[self clearMovieViewStore];
    
	if(newView && movieDirection != MV_CURRENT_POSITION)
		[self prePositionMovieView:newView From:movieDirection];	
}

- (void) animateMovieViews:(MovieView *)newView From:(int)movieDirection
{
	if(moviesAnimating)
		return;
	
	moviesAnimating = true;
	
    // Remove the time controls if they qre there
    // Switch off time controller if we're returning to a forced live view
    if([BasePadViewController timeControllerDisplayed])
    {
        [self toggleTimeControllerDisplay];
        timeControllerPending = true;
    }
    
	if(newView && movieDirection != MV_CURRENT_POSITION)
		[self prePositionMovieView:newView From:movieDirection];
	
	if([auxMovieView1 movieSourceAssociated] && ![auxMovieView1 movieScheduledForRemoval])
		[self showAuxMovieView:auxMovieView1];
	
	if([auxMovieView2 movieSourceAssociated] && ![auxMovieView2 movieScheduledForRemoval])
		[self showAuxMovieView:auxMovieView2];
	
	[auxMovieView1 hideMovieLabels];
	[auxMovieView2 hideMovieLabels];
	
	[UIView beginAnimations:nil context:nil];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(movieViewAnimationDidStop:finished:context:)];
	
	[UIView setAnimationDuration:1.0];
	
	[self positionMovieViews];
	
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
		[mainMovieView showMovieLabels:MV_NO_CLOSE_NO_AUDIO];
	else
		[mainMovieView hideMovieLabels];
	
	if([auxMovieView1 shouldShowLabels])
		[auxMovieView1 showMovieLabels:(priorityAuxMovie == 1) ? MV_CLOSE_AND_AUDIO : MV_CLOSE_NO_AUDIO];
	else
		[auxMovieView1 hideMovieLabels];

	if([auxMovieView2 shouldShowLabels])
		[auxMovieView2 showMovieLabels:(priorityAuxMovie == 2) ? MV_CLOSE_AND_AUDIO : MV_CLOSE_NO_AUDIO];
	else
		[auxMovieView2 hideMovieLabels];
    
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

- (void) showOverlays
{
	if(displayMap)
	{
		if(disableOverlays)
		{
			[trackZoomContainer setAlpha:0.0];
			[trackZoomContainer setHidden:false];
		}
		else
		{
			[trackMapView setAlpha:0.0];
			[trackMapView setHidden:false];
		}
	}
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[leaderboardView setAlpha:0.0];
	// GG - COMMENT OUT LEADERBOARD : 	[leaderboardView setHidden:false];
	// GG - COMMENT OUT LEADERBOARD : }
	
	[UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
	if(displayMap)
	{
		if(disableOverlays)
		{
			[trackZoomContainer setAlpha:1.0];
		}
		else
		{
			[trackMapView setAlpha:1.0];
		}
	}
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[leaderboardView setAlpha:1.0];
	// GG - COMMENT OUT LEADERBOARD : }
	
	[UIView commitAnimations];
}

- (void) hideOverlays
{
	[trackMapView setHidden:true];
	// GG - COMMENT OUT LEADERBOARD : [leaderboardView setHidden:true];
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
	[trackZoomContainer setHidden:true];
	[trackZoomContainer setAlpha:1.0];
	[trackZoomView setCarToFollow:nil];
	// GG - COMMENT OUT LEADERBOARD : [leaderboardView RequestRedraw];
}

- (void) positionOverlays
{
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
	
	[trackMapView setFrame:movieRect];
	
	// GG - COMMENT OUT LEADERBOARD : CGRect lb_frame = CGRectMake(movieRect.origin.x + 5, movieRect.origin.y, 60, movieRect.size.height);
	// GG - COMMENT OUT LEADERBOARD : [leaderboardView setFrame:lb_frame];
	
	// GG - COMMENT OUT ZOOM MAP : CGRect zoom_frame = CGRectMake(movieRect.origin.x + 80, movieViewSize.height - 320, 300, 300);
	// GG - COMMENT OUT ZOOM MAP : CGRect offsetFrame = CGRectOffset(zoom_frame, trackZoomOffsetX, trackZoomOffsetY);
	// GG - COMMENT OUT ZOOM MAP : CGRect bgRect = [[self view] frame];
	// GG - COMMENT OUT ZOOM MAP : if ( offsetFrame.origin.x < 0 )
	// GG - COMMENT OUT ZOOM MAP : 	offsetFrame = CGRectOffset(offsetFrame, -offsetFrame.origin.x, 0);
	// GG - COMMENT OUT ZOOM MAP : if ( offsetFrame.origin.y < 0 )
	// GG - COMMENT OUT ZOOM MAP : 	offsetFrame = CGRectOffset(offsetFrame, 0, -offsetFrame.origin.y);
	// GG - COMMENT OUT ZOOM MAP : if ( offsetFrame.origin.x + offsetFrame.size.width > bgRect.origin.x + bgRect.size.width )
	// GG - COMMENT OUT ZOOM MAP : 	offsetFrame = CGRectOffset(offsetFrame, (bgRect.origin.x + bgRect.size.width) - (offsetFrame.origin.x + offsetFrame.size.width), 0);
	// GG - COMMENT OUT ZOOM MAP : if ( offsetFrame.origin.y + offsetFrame.size.height > bgRect.origin.y + bgRect.size.height )
	// GG - COMMENT OUT ZOOM MAP : 	offsetFrame = CGRectOffset(offsetFrame, 0, (bgRect.origin.y + bgRect.size.height) - (offsetFrame.origin.y + offsetFrame.size.height));
	
	// GG - COMMENT OUT ZOOM MAP : [trackZoomContainer setFrame:offsetFrame];
}

- (void) setTrackState:(int)state
{
	switch (state)
	{
		case TM_TRACK_GREEN:
		default:
			[lapCounterButton setBackgroundImage:[UIImage imageNamed:@"lap-counter-white.png"] forState:UIControlStateNormal];
			[trackStateButton setHidden:true];
			break;
		case TM_TRACK_YELLOW:
			[trackStateButton setHidden:true];
			[lapCounterButton setBackgroundImage:[UIImage imageNamed:@"lap-counter-yellow.png"] forState:UIControlStateNormal];
			[lapCounterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			break;
		case TM_TRACK_SC:
			[trackStateButton setImage:[UIImage imageNamed:@"MidasTitleSC.png"]];
			[trackStateButton setHidden:false];
			[lapCounterButton setBackgroundImage:[UIImage imageNamed:@"lap-counter-yellow.png"] forState:UIControlStateNormal];
			[lapCounterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			break;
		case TM_TRACK_SCSTBY:
			break;
		case TM_TRACK_SCIN:
			break;
		case TM_TRACK_RED:
			[trackStateButton setHidden:true];
			[lapCounterButton setBackgroundImage:[UIImage imageNamed:@"lap-counter-red.png"] forState:UIControlStateNormal];
			[lapCounterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		case TM_TRACK_GRID:
			break;
		case TM_TRACK_CHEQUERED:
			[trackStateButton setImage:[UIImage imageNamed:@"MidasTitleChequered.png"]];
			[trackStateButton setHidden:false];
			[lapCounterButton setBackgroundImage:[UIImage imageNamed:@"lap-counter-white.png"] forState:UIControlStateNormal];
			[lapCounterButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
			break;
	}
}

- (void) RequestRedraw
{
	int lap = [[RacePadTitleBarController Instance] currentLap];
	int lapCount = [[RacePadTitleBarController Instance] lapCount];
	
	if(lap > lapCount)
		lap = lapCount;
	
	NSNumber *i = [NSNumber numberWithInt:lap];
	NSNumber *c = [NSNumber	numberWithInt:lapCount];
	NSString *s = [i stringValue];
	s = [s stringByAppendingString:@"/"];
	s = [s stringByAppendingString:[c stringValue]];
	[lapCounterButton setTitle:s forState:UIControlStateNormal];
	
	[super RequestRedraw];
}

- (void) RequestRedrawForType:(int)type
{
	if(type == RPC_TRACK_STATE_VIEW_)
		[self setTrackState:[[RacePadTitleBarController Instance] trackState]];
	
	[super RequestRedrawForType:type];
}


- (void)setMapDisplayed:(bool)state
{
	if(state)
	{
		if(!displayMap)
		{
			displayMap = true;
			
			if(disableOverlays)
			{
				[trackZoomContainer setHidden:false];			
				[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];			
				[trackZoomView RequestRedraw];
			}
			else
			{
				[trackMapView setHidden:false];			
				[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];			
				[trackMapView RequestRedraw];
			}
		}
	}
	else
	{
		if(displayMap)
		{
			displayMap = false;

			if(disableOverlays)
			{
				[trackZoomContainer setHidden:true];			
				[[RacePadCoordinator Instance] SetViewHidden:trackZoomView];			
			}
			else
			{
				[trackMapView setHidden:true];
				[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
			}
		}
	}
}

- (void)setOverlaysDisabled:(bool)state
{
	if(!state)
	{
		if(disableOverlays)
		{
			disableOverlays = false;
			
			if(displayMap)
			{
				[trackZoomContainer setHidden:true];			
				[[RacePadCoordinator Instance] SetViewHidden:trackZoomView];			

				[trackMapView setHidden:false];			
				[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];			
				[trackMapView RequestRedraw];
			}
		}
	}
	else
	{
		if(!disableOverlays)
		{
			disableOverlays = true;
			if(displayMap)
			{
				[trackMapView setHidden:true];
				[[RacePadCoordinator Instance] SetViewHidden:trackMapView];

				[trackZoomContainer setHidden:false];			
				[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];			
				[trackZoomView RequestRedraw];
			}
		}
	}
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// GG - COMMENT OUT LEADERBOARD : 
	/*
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
	*/
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	if([BasePadViewController timeControllerDisplayed])
		[self toggleTimeControllerDisplay];
	
	// Either close popup views if there are any or pop menus up or down
	if(![self dismissPopupViews])
		[self handleMenuButtonDisplayGestureInView:gestureView AtX:x Y:y];
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
					[self storeMovieViews];
					[auxMovieView1 setMovieScheduledForRemoval:true];
					[auxMovieView2 setMovieScheduledForRemoval:true];
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
				else if(movieViewsStored)
				{
					[self restoreMovieViews];
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
	
	// Zooms on point in map, or chosen car in leader board
	// GG - COMMENT OUT LEADERBOARD : 
	/*
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
	*/
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// If it's a movie view, reload movie
	if(gestureView && [gestureView isKindOfClass:[MovieView class]])
	{
		[(MovieView *)gestureView redisplayMovieSource];
	}
	
	//On the map, reset zoom
	if(gestureView && [gestureView isKindOfClass:[TrackMapView class]])
	{
	
		/*
		if([(TrackMapView *)gestureView isZoomView])
		{
			[[RacePadCoordinator Instance] setNameToFollow:nil];
			[self hideZoomMap];
		}
		else
		*/
		{
			{
				[(TrackMapView *)gestureView setUserXOffset:0.0];
				[(TrackMapView *)gestureView setUserYOffset:0.0];
				[(TrackMapView *)gestureView setUserScale:1.0];	
			}
		}
	
		[trackMapView RequestRedraw];
	}
	// GG - COMMENT OUT LEADERBOARD : [leaderboardView RequestRedraw];
}


- (void) OnPinchGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	if(!gestureView)
		return;
		
	if([gestureView isKindOfClass:[TrackMapView class]])
	{	
		RacePadDatabase *database = [RacePadDatabase Instance];
		TrackMap *trackMap = [database trackMap];
		
		[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:scale X:x Y:y];
		
		[(TrackMapView *)gestureView RequestRedraw];
	}
	else if([gestureView isKindOfClass:[MovieView class]])
	{	
		if(!moviesAnimating)
		{
			if(gestureView == mainMovieView)
			{
				if(scale > 1)
				{
					[self storeMovieViews];
					[auxMovieView1 setMovieScheduledForRemoval:true];
					[auxMovieView2 setMovieScheduledForRemoval:true];
					[self animateMovieViews:nil From:MV_CURRENT_POSITION];
				}
				else if(movieViewsStored)
				{
					[self restoreMovieViews];
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
	
	// If we're on the track map, pan the map
	if(gestureView == trackMapView || gestureView == trackZoomView)
	{
		RacePadDatabase *database = [RacePadDatabase Instance];
		TrackMap *trackMap = [database trackMap];
		[trackMap adjustPanInView:(TrackMapView *)gestureView X:x Y:y];	
		[(TrackMapView *)gestureView RequestRedraw];
	}
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
		if(sender == auxMovieView1CloseButton)
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
	//[[RacePadCoordinator Instance] setNameToFollow:nil];
	//[self hideZoomMap];
}

- (IBAction) menuButtonHit:(id)sender
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMenuButtons) object:nil];
	
	// If the selected button is in a flashed state, get rid of this first
	if(flashedMenuButton && sender == flashedMenuButton)
	{
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(flashMenuButton:) object:nil];

		if(sender == socialMediaButton)
			socialMediaButtonFlashed = false;

		[self setFlashStateForButton:sender ToState:false Animated:false];
		[[MidasCoordinator Instance] releaseSocialmediaQueue];	
	}
	
	
	if(sender == midasMenuButton)
	{
		if(![[MidasMasterMenuManager Instance] viewDisplayed])
		{
			midasMenuButtonOpen = true;
			
			[[MidasMasterMenuManager Instance] grabExclusion:self];
			[[MidasMasterMenuManager Instance] displayInViewController:self AtX:0 Animated:true Direction:POPUP_DIRECTION_RIGHT_ XAlignment:POPUP_ALIGN_FULL_SCREEN_ YAlignment:POPUP_ALIGN_FULL_SCREEN_];
		}
		else
		{
			[[MidasMasterMenuManager Instance] hideAnimated:true Notify:true];
		}
		
		[self.view bringSubviewToFront:midasMenuButton];
	}
	
	if(sender == helpButton)
	{
		if(![[MidasHelpManager Instance] viewDisplayed])
		{
			helpButtonOpen = true;
			
			[[MidasHelpManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasHelpManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_DOWN_ XAlignment:POPUP_ALIGN_LEFT_ YAlignment:POPUP_ALIGN_TOP_];
		}
	}
	
	if(sender == alertsButton)
	{
		if(![[MidasAlertsManager Instance] viewDisplayed])
		{
			alertsButtonOpen = true;
			
			[[MidasAlertsManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasAlertsManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_DOWN_ XAlignment:POPUP_ALIGN_LEFT_ YAlignment:POPUP_ALIGN_TOP_];
		}
	}
	
	if(sender == socialMediaButton)
	{
		if(![[MidasSocialMediaManager Instance] viewDisplayed])
		{
			socialMediaButtonOpen = true;
			
			[[MidasSocialMediaManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasSocialMediaManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_DOWN_ XAlignment:POPUP_ALIGN_LEFT_ YAlignment:POPUP_ALIGN_TOP_];
		}
	}
	
	if(sender == vipButton)
	{
		if(![[MidasVIPManager Instance] viewDisplayed])
		{
			vipButtonOpen = true;
			
			[[MidasVIPManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasVIPManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_DOWN_ XAlignment:POPUP_ALIGN_LEFT_ YAlignment:POPUP_ALIGN_TOP_];
		}
	}
		
	if(sender == standingsButton)
	{
		if(![[MidasStandingsManager Instance] viewDisplayed])
		{
			standingsButtonOpen = true;
			
			[[MidasStandingsManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasStandingsManager Instance] displayInViewController:self AtX:CGRectGetMaxX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_UP_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == mapButton)
	{
		if(![[MidasCircuitViewManager Instance] viewDisplayed])
		{
			mapButtonOpen = true;
			
			[[MidasCircuitViewManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasCircuitViewManager Instance] displayInViewController:self AtX:CGRectGetMaxX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_UP_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == followDriverButton)
	{
		if(![[MidasFollowDriverManager Instance] viewDisplayed])
		{
			followDriverButtonOpen = true;
			
			[[MidasFollowDriverManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasFollowDriverManager Instance] displayInViewController:self AtX:CGRectGetMaxX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_UP_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == cameraButton)
	{
		if(![[MidasCameraManager Instance] viewDisplayed])
		{
			cameraButtonOpen = true;
			
			[[MidasCameraManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasCameraManager Instance] displayInViewController:self AtX:CGRectGetMaxX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_UP_ XAlignment:POPUP_ALIGN_RIGHT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == myTeamButton)
	{
		if(![[MidasMyTeamManager Instance] viewDisplayed])
		{
			myTeamButtonOpen = true;
			
			[[MidasMyTeamManager Instance] grabExclusion:self];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasMyTeamManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true Direction:POPUP_DIRECTION_UP_ XAlignment:POPUP_ALIGN_LEFT_ YAlignment:POPUP_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == timeControlsButton)
	{
		
		//[self notifyExclusiveUse:MIDAS_POPUP_NONE_ InZone:MIDAS_POPUP_ZONE_ALL_];
		//[self hideMenuButtons];
		//[self positionMenuButtons];
		[self toggleTimeControllerDisplay];
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
	CGRect centreViewRect = CGRectMake(324, 244,700,394);
    
	if ( timeControllerInstance && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
        [timeControllerInstance displayTimeControllerInViewController:self InRect:centreViewRect Animated:true];
    }
    
    // Ensure that all displayed popups are in front
    if(standingsButtonOpen)
        [[MidasStandingsManager Instance] bringToFront];
    
	if(mapButtonOpen)
        [[MidasCircuitViewManager Instance] bringToFront];

	if(followDriverButtonOpen)
        [[MidasFollowDriverManager Instance] bringToFront];

	if(cameraButtonOpen)
        [[MidasCameraManager Instance] bringToFront];

	if(myTeamButtonOpen)
        [[MidasMyTeamManager Instance] bringToFront];
        
}

- (void) executeTimeControllerHide
{
    id timeControllerInstance = [BasePadViewController timeControllerInstance];
	if ( timeControllerInstance && [timeControllerInstance conformsToProtocol:@protocol(TimeControllerInstance)] )
	{
        [timeControllerInstance hideTimeController];
    }
}

///////////////////////////////////////////////////////////////////
// Button Animation Routines

// Button positions

-(void)positionMenuButtons
{
	if(midasMenuButtonOpen)
		[midasMenuButton setFrame:CGRectMake(0,332,91,61)];
	else
		[midasMenuButton setFrame:CGRectMake(-36,332,91,61)];
	
	[self positionTopMenuButtons];
	[self positionBottomMenuButtons];	
}

-(void)positionTopMenuButtons
{
	// Get the bounds of the view controller
	CGRect viewBounds = [[self view] bounds];
	
	// And position the buttons in each panel
	CGRect buttonFrame;
	
	////////////////////////////////////////
	// Top buttons - start from the left
	
	float leftX = CGRectGetMinX(viewBounds) + 60;
	
	// Help button
	buttonFrame = [helpButton frame];
	[helpButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(helpButtonOpen)
		[[MidasHelpManager Instance] moveToPositionX:leftX Animated:false];
	
	if(helpButtonOpen)
		leftX += [[MidasHelpManager Instance] widthOfView];
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
	// Alerts button
	buttonFrame = [alertsButton frame];
	[alertsButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(alertsButtonOpen)
		[[MidasAlertsManager Instance] moveToPositionX:leftX Animated:false];
	
	if(alertsButtonOpen)
		leftX += [[MidasAlertsManager Instance] widthOfView];
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
	// Social Media button
	buttonFrame = [socialMediaButton frame];
	[socialMediaButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(socialMediaButtonOpen)
		[[MidasSocialMediaManager Instance] moveToPositionX:leftX Animated:false];
	
	if(socialMediaButtonOpen)
		leftX += [[MidasSocialMediaManager Instance] widthOfView];
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
	// VIP button
	buttonFrame = [vipButton frame];
	[vipButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(vipButtonOpen)
		[[MidasVIPManager Instance] moveToPositionX:leftX Animated:false];
	
	if(vipButtonOpen)
		leftX += [[MidasVIPManager Instance] widthOfView];
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
	// DF button
	buttonFrame = [dfButton frame];
	[dfButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
}

-(void)positionBottomMenuButtons
{
	// Get the bounds of the view controller
	CGRect viewBounds = [[self view] bounds];
	
	// And position the buttons in bottom panel
	CGRect buttonFrame;
		
	////////////////////////////////////////
	// Bottom buttons - Start from the right
	
	// We need to do this in two passes in order to determine if buttons need to be moved to allow popup edges
	// to be on screen
	
	// The first pass just establishes the predicted positions
	
	float rightX = CGRectGetMaxX(viewBounds) - 2;
	float leftPopupX = rightX;
	float rightPopupX = -1.0;
	
	// Standings button
	buttonFrame = [standingsButton frame];	
	if(standingsButtonOpen)
	{
		if(rightPopupX < 0)
			rightPopupX = rightX;
		
		rightX -= [[MidasStandingsManager Instance] preferredWidthOfView];
		leftPopupX = rightX;
	}
	else
	{
		rightX -= CGRectGetWidth(buttonFrame);
	}
	
	rightX -= 2;
	
	// Circuit button
	buttonFrame = [mapButton frame];
	if(mapButtonOpen)
	{
		if(rightPopupX < 0)
			rightPopupX = rightX;
		
		rightX -= [[MidasCircuitViewManager Instance] preferredWidthOfView];
		leftPopupX = rightX;
	}
	else
	{
		rightX -= CGRectGetWidth(buttonFrame);
	}
	
	rightX -= 2;
	
	// Follow driver button
	buttonFrame = [followDriverButton frame];
	if(followDriverButtonOpen)
	{
		if(rightPopupX < 0)
			rightPopupX = rightX;
		
		rightX -= [[MidasFollowDriverManager Instance] preferredWidthOfView];
		leftPopupX = rightX;
	}
	else
	{
		rightX -= CGRectGetWidth(buttonFrame);
	}
	
	rightX -= 2;
	
	// Camera button
	buttonFrame = [cameraButton frame];
	if(cameraButtonOpen)
	{
		if(rightPopupX < 0)
			rightPopupX = rightX;
		
		rightX -= [[MidasCameraManager Instance] preferredWidthOfView];
		leftPopupX = rightX;
	}
	else
	{
		rightX -= CGRectGetWidth(buttonFrame);
	}
	
	rightX -= 2;
	
	// Time controls button
	buttonFrame = [timeControlsButton frame];
	rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 6;
	
	// VIP and MyTeam buttons are special cases - they start from left, but may interact with others
	
	float maxLeftX = rightX;
	
	float leftX = CGRectGetMinX(viewBounds) + 60;
	
	// MyTeam button
	buttonFrame = [myTeamButton frame];
	[myTeamButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasMyTeamManager Instance] viewDisplayed])
		[[MidasMyTeamManager Instance] moveToPositionX:leftX Animated:false];
	
	if(myTeamButtonOpen)
	{
		// My Team popup is left aligned
		if(leftX < leftPopupX)
			leftPopupX = leftX;
	
		
		float thisRightPopupX = leftPopupX + [[MidasMyTeamManager Instance] preferredWidthOfView];
		
		if(rightPopupX < thisRightPopupX)
			rightPopupX = thisRightPopupX;

		leftX += [[MidasMyTeamManager Instance] preferredWidthOfView];		
	}
	else
	{
		leftX += CGRectGetWidth(buttonFrame);
	}
	
	leftX += 2;
	
	// We need to push the other buttons right again if either of the panels was open
	// They both have exclusive use, so their panels won't be open
	

	// See if we need to offset buttons
	
	float leftButtonOffset = (leftX > maxLeftX) ? (leftX - maxLeftX) : 0.0;
	float buttonOffset = ((myTeamButtonOpen || vipButtonOpen) && leftX > maxLeftX) ? (leftX - maxLeftX) : 0.0;
	
	if(myTeamButtonOpen)
	{
		leftPopupX -= buttonOffset;
		rightPopupX -= buttonOffset;
	}
	
	if(buttonOffset < 1 && leftPopupX < 10)
	{
		float popupCentre = (rightPopupX + leftPopupX) / 2;
		buttonOffset = CGRectGetMidX(viewBounds) - popupCentre;
	}
	else if(leftButtonOffset > 1 && leftPopupX < 10)
	{
		leftButtonOffset = 0.0;
	}
	
	// And hide all buttons if any are off the screen
	if(rightX < 0 || buttonOffset > 2)
	{
		if(rightX < 0)
			[moreLeftImage setAlpha:1.0];
		else
			[moreLeftImage setAlpha:0.0];
		
		if(buttonOffset > 2)
			[moreRightImage setAlpha:1.0];
		else
			[moreRightImage setAlpha:0.0];
		
		[standingsButton setAlpha:0.0];
		[mapButton setAlpha:0.0];
		[followDriverButton setAlpha:0.0];
		[cameraButton setAlpha:0.0];
		[timeControlsButton setAlpha:0.0];
		[myTeamButton setAlpha:0.0];
	}
	else
	{
		[moreLeftImage setAlpha:0.0];
		[moreRightImage setAlpha:0.0];
		
		[standingsButton setAlpha:1.0];
		[mapButton setAlpha:1.0];
		[followDriverButton setAlpha:1.0];
		[cameraButton setAlpha:1.0];
		[timeControlsButton setAlpha:1.0];
		[myTeamButton setAlpha:1.0];
	}
	
	
	// Then do the actual position
	rightX = CGRectGetMaxX(viewBounds) - 2 + buttonOffset;
	
	// Standings button
	buttonFrame = [standingsButton frame];
	[standingsButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(standingsButtonOpen)
		[[MidasStandingsManager Instance] moveToPositionX:rightX Animated:false];
	
	if(standingsButtonOpen)
		rightX -= [[MidasStandingsManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Circuit button
	buttonFrame = [mapButton frame];
	[mapButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(mapButtonOpen)
		[[MidasCircuitViewManager Instance] moveToPositionX:rightX Animated:false];
	
	if(mapButtonOpen)
		rightX -= [[MidasCircuitViewManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Follow driver button
	buttonFrame = [followDriverButton frame];
	[followDriverButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(followDriverButtonOpen)
		[[MidasFollowDriverManager Instance] moveToPositionX:rightX Animated:false];
	
	if(followDriverButtonOpen)
		rightX -= [[MidasFollowDriverManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Camera button
	buttonFrame = [cameraButton frame];
	[cameraButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(cameraButtonOpen)
		[[MidasCameraManager Instance] moveToPositionX:rightX Animated:false];
	
	if(cameraButtonOpen)
		rightX -= [[MidasCameraManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Time controls button
	buttonFrame = [timeControlsButton frame];
	[timeControlsButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	
	rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 20;
	
	leftX = CGRectGetMinX(viewBounds) + 60 - leftButtonOffset; // Moves them back to the left a bit if the right hand panels interfere
	
	// MyTeam button
	buttonFrame = [myTeamButton frame];
	[myTeamButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if(myTeamButtonOpen)
		[[MidasMyTeamManager Instance] moveToPositionX:leftX Animated:false];
	
	if(myTeamButtonOpen)
		leftX += [[MidasMyTeamManager Instance] preferredWidthOfView];		
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
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
	
	// Top buttons
	[topButtonPanel setFrame:CGRectOffset([topButtonPanel frame], 0, -CGRectGetHeight([alertsButton frame]))];
	
	// Side buttons
	if(midasMenuButtonOpen)
		[midasMenuButton setFrame:CGRectMake(0,332,91,61)];
	else
		[midasMenuButton setFrame:CGRectMake(-91,332,91,61)];
	
	// Bottom buttons
	[bottomButtonPanel setFrame:CGRectOffset([bottomButtonPanel frame], 0, CGRectGetHeight([standingsButton frame]))];
	
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
	
	// Top buttons
	[topButtonPanel setFrame:CGRectOffset([topButtonPanel frame], 0, CGRectGetHeight([alertsButton frame]))];
	
	// Side buttons
	if(midasMenuButtonOpen)
		[midasMenuButton setFrame:CGRectMake(0,332,91,61)];
	else
		[midasMenuButton setFrame:CGRectMake(-36,332,91,61)];
	
	// Bottom buttons
	[bottomButtonPanel setFrame:CGRectOffset([bottomButtonPanel frame], 0, -CGRectGetHeight([standingsButton frame]))];
	
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
	
	// Top,bottom or side?
	if(!button || button == helpButton || button == alertsButton || button == socialMediaButton || button == vipButton)
	{
		[UIView beginAnimations:nil context:button];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(menuButtonAnimationDidStop:finished:context:)];
		
		[UIView setAnimationDuration:0.5];
		
		[self positionMenuButtons];
		
		[UIView commitAnimations];
		
	}
	else if(button == standingsButton || button == mapButton || button == followDriverButton || button == cameraButton)
	{
		[UIView beginAnimations:nil context:button];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(menuButtonAnimationDidStop:finished:context:)];
		
		[UIView setAnimationDuration:0.5];
		
		[self positionMenuButtons];
				
		[UIView commitAnimations];
	}
	else if(button == myTeamButton)
	{
	}
	else if(button == midasMenuButton)
	{
	}
}

- (void)menuButtonAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	menuButtonsAnimating = false;
}

// Button flashing for push notification

-(void)flashMenuButton:(UIButton *)button WithName:(NSString *)name
{
	if(!menuButtonsDisplayed)
	{
		[[MidasCoordinator Instance] releaseSocialmediaQueue];
		return;
	}
	
	[pushNotificationAnimationLabel setText:name];
	[self flashMenuButton:button];
}
	
-(void)flashMenuButton:(UIButton *)button
{
	if(!menuButtonsDisplayed)
	{
		[[MidasCoordinator Instance] releaseSocialmediaQueue];
		return;
	}
	
	// Social media buttons only
	
	bool newState;
	
	if(button == socialMediaButton)
		newState = !socialMediaButtonFlashed;
	else
		return;
	
	[self setFlashStateForButton:button ToState:newState Animated:true];
	
	if(button == socialMediaButton)
		socialMediaButtonFlashed = newState;
}

-(void)setFlashStateForButton:(UIButton *)button ToState:(bool)flashState Animated:(bool)animated
{
	if(!animated)
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(flashMenuButton:) object:nil];

	CGRect baseFrame = [button frame];
	CGRect baseLabelFrame = CGRectMake(baseFrame.origin.x + 42, baseFrame.origin.y, baseFrame.size.width - 42, baseFrame.size.height);
		
	CGRect newFrame;
	CGRect newLabelFrame;
	UIImage * newImage;
		
	bool closing;
	float duration;
		
	if(flashState)
	{
		newFrame = CGRectMake(baseFrame.origin.x, baseFrame.origin.y, selectedButtonWidth, baseFrame.size.height);
		newLabelFrame = CGRectMake(baseFrame.origin.x + 42, baseFrame.origin.y, selectedButtonWidth - 42, baseFrame.size.height);
		newImage = selectedTopButtonImage;
		closing = false;
		duration = 0.25;		
		flashedMenuButton = button;
	}
	else
	{
		newFrame = CGRectMake(baseFrame.origin.x, baseFrame.origin.y, unselectedButtonWidth, baseFrame.size.height);
		newLabelFrame = CGRectMake(baseFrame.origin.x + 42, baseFrame.origin.y, unselectedButtonWidth - 42, baseFrame.size.height);
		newImage = unselectedTopButtonImage;
		closing = true;
		duration = 0.15;
		flashedMenuButton = nil;
	}
	
	if(!closing)
	{
		[pushNotificationAnimationLabel setFrame:(animated ? baseLabelFrame : newLabelFrame)];
		[pushNotificationAnimationLabel setHidden:false];
		[pushNotificationAnimationLabel setAlpha:1.0];
	}
		
	if(animated)
	{
		[pushNotificationAnimationImage setImage:newImage];
		[pushNotificationAnimationImage setFrame:baseFrame];
		[pushNotificationAnimationImage setHidden:false];

		[pushNotificationAnimationLabel setFrame:baseLabelFrame];
		[pushNotificationAnimationLabel setHidden:false];
		[pushNotificationAnimationLabel setAlpha:0.0];	// Will animate up from 0 if opening - will disappear immediately when closing
		
		[button setBackgroundImage:nil forState:UIControlStateNormal];
	}
	else
	{
		[pushNotificationAnimationImage setHidden:true];
		
		if(closing)
		{
			[pushNotificationAnimationLabel setHidden:true];
		}
		else
		{
			[pushNotificationAnimationLabel setFrame:newLabelFrame];
			[pushNotificationAnimationLabel setHidden:false];
			[pushNotificationAnimationLabel setAlpha:1.0];
		}
	}
	
	newButtonBackgroundImage = [newImage retain];

	if(animated)
	{
		[UIView beginAnimations:nil context:button];
		[UIView setAnimationDelegate:self];
		
		if(closing)
			[UIView setAnimationDidStopSelector:@selector(menuEndFlashDidStop:finished:context:)];
		else
			[UIView setAnimationDidStopSelector:@selector(menuFlashDidStop:finished:context:)];
		
		[UIView setAnimationDuration:duration];

		[pushNotificationAnimationImage setFrame:newFrame];
		[pushNotificationAnimationLabel setFrame:newLabelFrame];
		[pushNotificationAnimationLabel setAlpha:(closing ? 0.0 : 1.0)];
	}
		
	[button setFrame:newFrame];
	[self positionTopMenuButtons];
		
	if(animated)
	{
		[UIView commitAnimations];
	}
	else
	{
		[button setBackgroundImage:newButtonBackgroundImage forState:UIControlStateNormal];
		[newButtonBackgroundImage release];
		newButtonBackgroundImage = nil;
		
		if(closing)
		{
			[pushNotificationAnimationLabel setHidden:true];
		}
		
	}

}

- (void)menuFlashDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	UIButton * button = (UIButton *) context;
	
	if(button != socialMediaButton)	// Shouldn't ever happen
		return;
	
	// If the menu has been opened in the meantime, just set button to closed. Otherwise, schedule closing in 3 secs.
	
	bool scheduleClose = true;
	if(button == socialMediaButton && socialMediaButtonOpen)
	{
		scheduleClose = false;
		socialMediaButtonFlashed = false;
	}
	
	if(scheduleClose)
	{
		[button setBackgroundImage:newButtonBackgroundImage forState:UIControlStateNormal];
		[self performSelector:@selector(flashMenuButton:) withObject:context afterDelay: 3.0];
	}
	else
	{
		[self setFlashStateForButton:button ToState:false Animated:false];
		[[MidasCoordinator Instance] releaseSocialmediaQueue];
	}
	 
	 
	[newButtonBackgroundImage release];
	newButtonBackgroundImage = nil;
	
	[pushNotificationAnimationImage setHidden:true];

}

- (void)menuEndFlashDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	[(UIButton *)context setBackgroundImage:newButtonBackgroundImage forState:UIControlStateNormal];
	[newButtonBackgroundImage release];
	newButtonBackgroundImage = nil;	
	[pushNotificationAnimationImage setHidden:true];
	
	[pushNotificationAnimationLabel setHidden:true];
	
	[[MidasCoordinator Instance] releaseSocialmediaQueue];
}


// Popup view management

- (bool) dismissPopupViews
{
	return [self dismissPopupViewsWithExclusion:MIDAS_POPUP_NONE_  InZone:(int)MIDAS_POPUP_ZONE_ALL_ AnimateMenus:true];
}

- (bool) dismissPopupViewsWithExclusion:(int)excludedPopupType InZone:(int)popupZone AnimateMenus:(bool)animateMenus
{
	bool popupDismissed = false;
	
	if(excludedPopupType != MIDAS_HELP_POPUP_ &&
	   [[MidasHelpManager Instance] viewDisplayed] &&
	   (popupZone & MIDAS_POPUP_ZONE_TOP_) > 0)
	{
		[[MidasHelpManager Instance] hideAnimated:true Notify:false];
		helpButtonOpen = false;
		[helpButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_ALERTS_POPUP_ &&
	   [[MidasAlertsManager Instance] viewDisplayed] &&
	   (popupZone & MIDAS_POPUP_ZONE_TOP_) > 0)
	{
		[[MidasAlertsManager Instance] hideAnimated:true Notify:false];
		alertsButtonOpen = false;
		[alertsButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_SOCIAL_MEDIA_POPUP_ &&
	   [[MidasSocialMediaManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_POPUP_ZONE_TOP_) > 0 || (popupZone & MIDAS_POPUP_ZONE_SOCIAL_MEDIA_) > 0))
	{
		[[MidasSocialMediaManager Instance] hideAnimated:true Notify:false];
		socialMediaButtonOpen = false;
		[socialMediaButton setHidden:false];
		popupDismissed= true;
	}
	
	   if(excludedPopupType != MIDAS_VIP_POPUP_ &&
		  [[MidasVIPManager Instance] viewDisplayed] &&
		  (popupZone & MIDAS_POPUP_ZONE_TOP_) > 0)
	   {
		   [[MidasVIPManager Instance] hideAnimated:true Notify:false];
		   vipButtonOpen = false;
		   [vipButton setHidden:false];
		   popupDismissed= true;
	   }
	   
	   if(excludedPopupType != MIDAS_STANDINGS_POPUP_ &&
	   [[MidasStandingsManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_POPUP_ZONE_BOTTOM_) > 0 || (popupZone & MIDAS_POPUP_ZONE_DATA_AREA_) > 0))
	{
		[[MidasStandingsManager Instance] hideAnimated:true Notify:false];
		standingsButtonOpen = false;
		[standingsButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_CIRCUIT_POPUP_ &&
	   [[MidasCircuitViewManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_POPUP_ZONE_BOTTOM_) > 0 || (popupZone & MIDAS_POPUP_ZONE_DATA_AREA_) > 0))
	{
		[[MidasCircuitViewManager Instance] hideAnimated:true Notify:false];
		mapButtonOpen = false;
		[mapButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_FOLLOW_DRIVER_POPUP_ &&
	   [[MidasFollowDriverManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_POPUP_ZONE_BOTTOM_) > 0 || (popupZone & MIDAS_POPUP_ZONE_DATA_AREA_) > 0))
	{
		[[MidasFollowDriverManager Instance] hideAnimated:true Notify:false];
		followDriverButtonOpen = false;
		[followDriverButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_CAMERA_POPUP_ &&
	   [[MidasCameraManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_POPUP_ZONE_BOTTOM_) > 0 || (popupZone & MIDAS_POPUP_ZONE_DATA_AREA_) > 0))
	{
		[[MidasCameraManager Instance] hideAnimated:true Notify:false];
		cameraButtonOpen = false;
		[cameraButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_MY_TEAM_POPUP_ &&
	   [[MidasMyTeamManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_POPUP_ZONE_BOTTOM_) > 0 || (popupZone & MIDAS_POPUP_ZONE_MY_AREA_) > 0))		
	{
		[[MidasMyTeamManager Instance] hideAnimated:true Notify:false];
		myTeamButtonOpen = false;
		[myTeamButton setHidden:false];
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
	[self positionMenuButtons];
}
	
- (void)notifyShowedPopup:(int)popupType
{
	switch(popupType)
	{
		case MIDAS_HELP_POPUP_:
			[helpButton setHidden:true];
			break;
			
		case MIDAS_ALERTS_POPUP_:
			[alertsButton setHidden:true];
			break;
			
		case MIDAS_SOCIAL_MEDIA_POPUP_:
			[socialMediaButton setHidden:true];
			break;
			
		case MIDAS_VIP_POPUP_:
			[vipButton setHidden:true];
			break;
			
		case MIDAS_STANDINGS_POPUP_:
			[standingsButton setHidden:true];
			break;
			
		case MIDAS_CIRCUIT_POPUP_:
			[mapButton setHidden:true];
			break;
			
		case MIDAS_FOLLOW_DRIVER_POPUP_:
			[followDriverButton setHidden:true];
			break;
			
		case MIDAS_CAMERA_POPUP_:
			[cameraButton setHidden:true];
			break;
			
		case MIDAS_MY_TEAM_POPUP_:
			[myTeamButton setHidden:true];
			break;
			
		default:
			break;
	}
	
//	[self.view bringSubviewToFront:bottomButtonPanel];
//	[self.view bringSubviewToFront:topButtonPanel];
	
	//[self animateMenuButton:nil];
}

- (void)notifyHidingPopup:(int)popupType
{
	// Called within the animation brace
	
	switch(popupType)
	{
		case MIDAS_MASTER_MENU_POPUP_:
			midasMenuButtonOpen = false;
			[self positionMenuButtons];
			break;
			
		case MIDAS_HELP_POPUP_:
			helpButtonOpen = false;
			[helpButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MIDAS_ALERTS_POPUP_:
			alertsButtonOpen = false;
			[alertsButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MIDAS_SOCIAL_MEDIA_POPUP_:
			socialMediaButtonOpen = false;
			[socialMediaButton setHidden:false];
			[self positionMenuButtons];
			break;
						
		case MIDAS_VIP_POPUP_:
			vipButtonOpen = false;
			[vipButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MIDAS_STANDINGS_POPUP_:
			standingsButtonOpen = false;
			[standingsButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MIDAS_CIRCUIT_POPUP_:
			mapButtonOpen = false;
			[mapButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MIDAS_FOLLOW_DRIVER_POPUP_:
			followDriverButtonOpen = false;
			[followDriverButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MIDAS_CAMERA_POPUP_:
			cameraButtonOpen = false;
			[cameraButton setHidden:false];
			[self positionMenuButtons];
			break;
			
		case MIDAS_MY_TEAM_POPUP_:
			myTeamButtonOpen = false;
			[myTeamButton setHidden:false];
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


////////////////////////////////////////////////////////////////////
// MidasSocialmediaResponderDelegate Methods

- (void)notifyNewSocialmediaMessage:(MidasSocialmediaMessage *)message
{
	[[MidasCoordinator Instance] blockSocialmediaQueue];
	
	UIButton * button = nil;
	bool buttonOpen = false;
	
	if([message messageType] == MIDAS_SM_TWITTER_)
	{
		button = socialMediaButton;
		buttonOpen = socialMediaButtonOpen;
	}
	else if([message messageType] == MIDAS_SM_FACEBOOK_)
	{
		button = socialMediaButton;
		buttonOpen = socialMediaButtonOpen;
	}
	else if([message messageType] == MIDAS_SM_MIDAS_CHAT_)
	{
		button = socialMediaButton;
		buttonOpen = socialMediaButtonOpen;
	}
	
	if(buttonOpen)
		[[MidasCoordinator Instance] releaseSocialmediaQueue];
	else
		[self flashMenuButton:button WithName:[message messageSender]];
}

@end


