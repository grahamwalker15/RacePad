//
//  MidasVideoViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasVideoViewController.h"

#import "MidasPopupManager.h"


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


@implementation MidasVideoViewController

@synthesize displayVideo;
@synthesize displayMap;
@synthesize displayLeaderboard;

@synthesize midasMenuButtonOpen;
@synthesize alertsButtonOpen;
@synthesize twitterButtonOpen;
@synthesize facebookButtonOpen;
@synthesize midasChatButtonOpen;	
@synthesize lapCounterButtonOpen;
@synthesize userNameButtonOpen;
@synthesize standingsButtonOpen;
@synthesize mapButtonOpen;
@synthesize followDriverButtonOpen;
@synthesize headToHeadButtonOpen;
@synthesize timeControlsButtonOpen;
@synthesize vipButtonOpen;
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
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
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
	unselectedButtonWidth = 36;
	selectedButtonWidth = 147;
	
	// Initialise display options
	
	menuButtonsDisplayed = true;
	menuButtonsAnimating = false;
	
	midasMenuButtonOpen = false;
	alertsButtonOpen = false;
	twitterButtonOpen = false;
	facebookButtonOpen = false;
	midasChatButtonOpen = false;	
	lapCounterButtonOpen = false;
	userNameButtonOpen = false;
	standingsButtonOpen = false;
	mapButtonOpen = false;
	followDriverButtonOpen = false;
	headToHeadButtonOpen = false;
	timeControlsButtonOpen = false;
	vipButtonOpen = false;
	myTeamButtonOpen = false;
	
	firstDisplay = true;
	
	displayMap = true;
	displayLeaderboard = true;
	displayVideo = true;
	
	[mainMovieView setStyle:BG_STYLE_INVISIBLE_];
	[auxMovieView1 setStyle:BG_STYLE_INVISIBLE_];
	[auxMovieView2 setStyle:BG_STYLE_INVISIBLE_];
	
	[buttonBackgroundAnimationImage setHidden:true];
	
	[auxMovieView1 setHidden:true];
	[auxMovieView2 setHidden:true];
	
	// Position the menu buttons
	[self positionMenuButtons];
	
	// GG - COMMENT OUT LEADERBOARD :
	[leaderboardView setHidden:true];
	
	// Set the types on the two map views
	[trackMapView setIsZoomView:false];
	[trackZoomView setIsZoomView:true];
	
	[trackMapView setIsOverlayView:true];
	
	[trackZoomContainer setStyle:BG_STYLE_TRANSPARENT_];
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
	
	// Add tap and long press recognizers to overlay in order to catch taps outside map
	[self addTapRecognizerToView:overlayView];
	[self addLongPressRecognizerToView:overlayView];
	
	// Add tap recognizer to button panels to dismiss menus
	[self addTapRecognizerToView:topButtonPanel];
	[self addTapRecognizerToView:bottomButtonPanel];
	
	// Add tap and long press recognizers to the leaderboard
	// GG - COMMENT OUT LEADERBOARD : [self addTapRecognizerToView:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : [self addLongPressRecognizerToView:leaderboardView];
	
	// Add long press recognizers to the overlay to reset video windows (TEMPORARY)
	[self addLongPressRecognizerToView:overlayView];
	[self addLongPressRecognizerToView:mainMovieView];
	
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
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_VIDEO_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	
	// We'll get notification when we know the movie size - set it to a default for now
	movieSize = CGSizeMake(768, 576);
	movieRect = CGRectMake(0, 0, 768, 576);
	[self positionOverlays];
	
	[mainMovieView bringSubviewToFront:overlayView];
	[mainMovieView bringSubviewToFront:trackMapView];
	// GG - COMMENT OUT LEADERBOARD : [movieView bringSubviewToFront:leaderboardView];
	[mainMovieView bringSubviewToFront:trackZoomContainer];
	[mainMovieView bringSubviewToFront:trackZoomView];
	[mainMovieView bringSubviewToFront:videoDelayLabel];
	[mainMovieView bringSubviewToFront:loadingLabel];
	[mainMovieView bringSubviewToFront:loadingTwirl];
	
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
		[[RacePadCoordinator Instance] SetViewDisplayed:mainMovieView];
	}
	
	if(displayMap)
	{
		[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
		[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
	}
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : }
	
	[[RacePadCoordinator Instance] SetViewDisplayed:self];
	
	[[CommentaryBubble Instance] allowBubbles:[self view] BottomRight: false];
	
	if(firstDisplay)
	{
		[self performSelector:@selector(hideMenuButtons) withObject:nil afterDelay: 2.0];
		firstDisplay = false;
	}
	
	
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
		[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
		[[RacePadCoordinator Instance] SetViewHidden:trackZoomView];
	}
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[[RacePadCoordinator Instance] SetViewHidden:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : }
	
	[[RacePadCoordinator Instance] SetViewHidden:self];
	
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
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

- (void) displayMovieSource:(BasePadVideoSource *)source 
{	
	if(!source)
		return;
	
	if(![mainMovieView moviePlayerLayerAdded])
		[self displayMovieSource:source InView:mainMovieView];
	else if(![auxMovieView1 moviePlayerLayerAdded])
		[self displayMovieSource:source InView:auxMovieView1];
	else if(![auxMovieView2 moviePlayerLayerAdded])
		[self displayMovieSource:source InView:auxMovieView2];
}

- (void) displayMovieSource:(BasePadVideoSource *)source InView:(MovieView *)movieView
{	
	// Position the movie and order the overlays
	if([movieView displayMovieSource:source])
	{
		if(movieView == mainMovieView)
		{
			[movieView bringSubviewToFront:overlayView];
			[movieView bringSubviewToFront:trackMapView];
			// GG - COMMENT OUT LEADERBOARD : [movieView bringSubviewToFront:leaderboardView];
			[movieView bringSubviewToFront:trackZoomContainer];
			[movieView bringSubviewToFront:trackZoomView];
			[movieView bringSubviewToFront:videoDelayLabel];
			[movieView bringSubviewToFront:loadingLabel];
			[movieView bringSubviewToFront:loadingTwirl];
		}
	
		[self positionOverlays];	
	}
}

- (void) removeMovieFromView:(BasePadVideoSource *)source
{
	if([mainMovieView movieSource] == source)
		[mainMovieView removeMovieFromView];
}

- (void) removeMoviesFromView
{
	[mainMovieView removeMovieFromView];
}

- (void) positionMovieViews
{
	// Check how many videos are displayed - assume main one is
	
	int movieViewCount = 1;
	
	if([auxMovieView1 moviePlayerLayerAdded])
		movieViewCount++;
	
	if([auxMovieView2 moviePlayerLayerAdded])
		movieViewCount++;
	
	// Position windows
	CGRect superBounds = [self.view bounds];
	
	if(movieViewCount == 1)
	{
		[self showOverlays];
		[mainMovieView setFrame:superBounds];
		[auxMovieView1 setFrame:CGRectMake(superBounds.size.width + 1, 100, superBounds.size.width * 3 / 4, superBounds.size.height * 3 / 4)];
		[auxMovieView2 setFrame:CGRectMake(superBounds.size.width + 1, 100, superBounds.size.width * 3 / 4, superBounds.size.height * 3 / 4)];
	}
	else if(movieViewCount == 2)
	{
		[self hideOverlays];
		[mainMovieView setFrame:CGRectMake(0, 100, superBounds.size.width / 3, superBounds.size.height / 4)];
		if([auxMovieView1 moviePlayerLayerAdded])
			[auxMovieView1 setFrame:CGRectMake(superBounds.size.width / 3, 0, superBounds.size.width * 2 / 3, superBounds.size.height * 2 / 3)];
		else if([auxMovieView2 moviePlayerLayerAdded])
			[auxMovieView2 setFrame:CGRectMake(superBounds.size.width / 3, 0, superBounds.size.width * 2 / 3, superBounds.size.height * 2 / 3)];
	}
	else if(movieViewCount == 3)
	{
		[self hideOverlays];
		[mainMovieView setFrame:CGRectMake(0, 0, superBounds.size.width / 3, superBounds.size.height / 3)];
		if([auxMovieView1 moviePlayerLayerAdded])
			[auxMovieView1 setFrame:CGRectMake(superBounds.size.width / 3, 0, superBounds.size.width * 2 / 2, superBounds.size.height * 2 / 3)];
		if([auxMovieView2 moviePlayerLayerAdded])
			[auxMovieView2 setFrame:CGRectMake(superBounds.size.width * 2 / 3, superBounds.size.height * 2 / 2, superBounds.size.width / 3, superBounds.size.height / 3)];
	}
	
	[mainMovieView resizeMovieSource];
	[auxMovieView1 resizeMovieSource];
	[auxMovieView2 resizeMovieSource];
	
}

- (void) animateMovieViews
{
	if([auxMovieView1 moviePlayerLayerAdded])
		[self showAuxMovieView:auxMovieView1];
	
	if([auxMovieView2 moviePlayerLayerAdded])
		[self showAuxMovieView:auxMovieView2];
	
	[UIView beginAnimations:nil context:nil];
		
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(movieViewAnimationDidStop:finished:context:)];
		
	[UIView setAnimationDuration:0.5];
		
	[self positionMovieViews];
	
	[UIView commitAnimations];
}

- (void) movieViewAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([finished intValue] == 1)
	{
		if(![auxMovieView1 moviePlayerLayerAdded])
			[self hideAuxMovieView:auxMovieView1];
		
		if(![auxMovieView2 moviePlayerLayerAdded])
			[self hideAuxMovieView:auxMovieView2];
		
	}
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
	if(auxMovieView1 && ![auxMovieView1 moviePlayerLayerAdded])
		return auxMovieView1;
	else if(auxMovieView2 && ![auxMovieView2 moviePlayerLayerAdded])
		return auxMovieView2;
	
	return nil;
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
	return nil;
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
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[leaderboardView setAlpha:0.0];
	// GG - COMMENT OUT LEADERBOARD : 	[leaderboardView setHidden:false];
	// GG - COMMENT OUT LEADERBOARD : }
	
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
	if([finished intValue] == 1)
	{
		[trackZoomContainer setHidden:true];
		[trackZoomContainer setAlpha:1.0];
		[trackZoomView setCarToFollow:nil];
		// GG - COMMENT OUT LEADERBOARD : [leaderboardView RequestRedraw];
	}
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

- (void) RequestRedraw
{
	int lap = [[RacePadTitleBarController Instance] currentLap];
	int lapCount = [[RacePadTitleBarController Instance] lapCount];
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
	[auxMovieView1 removeMovieFromView];
	[auxMovieView1 removeMovieFromView];
	[self animateMovieViews];
	
	// Zooms on point in map, or chosen car in leader board
	if(!gestureView)
		return;
	
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
	// GG - COMMENT OUT LEADERBOARD : [leaderboardView RequestRedraw];
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

- (IBAction) closeButtonHit:(id)sender
{
	[[RacePadCoordinator Instance] setNameToFollow:nil];
	[self hideZoomMap];
}

- (IBAction) menuButtonHit:(id)sender
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideMenuButtons) object:nil];


	/* Test flashing
	if(sender == alertsButton || sender == twitterButton || sender == facebookButton || sender == midasChatButton)
	{
		[self flashMenuButton:(UIButton *)sender];
	}
	*/
	
	if(sender == alertsButton)
	{
		if(![[MidasAlertsManager Instance] viewDisplayed])
		{
			alertsButtonOpen = true;
			
			[[MidasAlertsManager Instance] grabExclusion:self];
			[self animateMenuButton:alertsButton];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasAlertsManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true XAlignment:MIDAS_ALIGN_LEFT_ YAlignment:MIDAS_ALIGN_TOP_];
		}
	}
	
	if(sender == twitterButton)
	{
		if(![[MidasTwitterManager Instance] viewDisplayed])
		{
			twitterButtonOpen = true;
			
			[[MidasTwitterManager Instance] grabExclusion:self];
			[self animateMenuButton:twitterButton];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasTwitterManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true XAlignment:MIDAS_ALIGN_LEFT_ YAlignment:MIDAS_ALIGN_TOP_];
		}
	}
	
	if(sender == facebookButton)
	{
		if(![[MidasFacebookManager Instance] viewDisplayed])
		{
			facebookButtonOpen = true;
			
			[[MidasFacebookManager Instance] grabExclusion:self];
			[self animateMenuButton:facebookButton];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasFacebookManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true XAlignment:MIDAS_ALIGN_LEFT_ YAlignment:MIDAS_ALIGN_TOP_];
		}
	}
	
	if(sender == midasChatButton)
	{
		if(![[MidasChatManager Instance] viewDisplayed])
		{
			midasChatButtonOpen = true;
			
			[[MidasChatManager Instance] grabExclusion:self];
			[self animateMenuButton:midasChatButton];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasChatManager Instance] displayInViewController:self AtX:CGRectGetMinX(buttonFrame) Animated:true XAlignment:MIDAS_ALIGN_LEFT_ YAlignment:MIDAS_ALIGN_TOP_];
		}
	}

	if(sender == standingsButton)
	{
		if(![[MidasStandingsManager Instance] viewDisplayed])
		{
			standingsButtonOpen = true;
			
			[[MidasStandingsManager Instance] grabExclusion:self];
			[self animateMenuButton:standingsButton];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasStandingsManager Instance] displayInViewController:self AtX:CGRectGetMaxX(buttonFrame) Animated:true XAlignment:MIDAS_ALIGN_RIGHT_ YAlignment:MIDAS_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == mapButton)
	{
		if(![[MidasCircuitViewManager Instance] viewDisplayed])
		{
			mapButtonOpen = true;
			
			[[MidasCircuitViewManager Instance] grabExclusion:self];
			[self animateMenuButton:mapButton];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasCircuitViewManager Instance] displayInViewController:self AtX:CGRectGetMaxX(buttonFrame) Animated:true XAlignment:MIDAS_ALIGN_RIGHT_ YAlignment:MIDAS_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == followDriverButton)
	{
		if(![[MidasFollowDriverManager Instance] viewDisplayed])
		{
			followDriverButtonOpen = true;
			
			[[MidasFollowDriverManager Instance] grabExclusion:self];
			[self animateMenuButton:followDriverButton];
			CGRect buttonFrame = [(UIButton *)sender frame];
			[[MidasFollowDriverManager Instance] displayInViewController:self AtX:CGRectGetMaxX(buttonFrame) Animated:true XAlignment:MIDAS_ALIGN_RIGHT_ YAlignment:MIDAS_ALIGN_BOTTOM_];
		}
	}
	
	if(sender == timeControlsButton)
	{
		[self hideMenuButtons];
		[self toggleTimeControllerDisplay];
	}
	
}

- (void) notifyHidingTimeControls
{
	[self showMenuButtons];
}

///////////////////////////////////////////////////////////////////
// Button Animation Routines

// Button positions

-(void)positionMenuButtons
{
	// Get the bounds of the view controller
	CGRect viewBounds = [[self view] bounds];
	
	// And position the buttons in each panel
	CGRect buttonFrame;
	
	////////////////////////////////////////
	// Top buttons - start from the left

	float leftX = CGRectGetMinX(viewBounds) + 60;
	
	// Alerts button
	buttonFrame = [alertsButton frame];
	[alertsButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasAlertsManager Instance] viewDisplayed])
		[[MidasAlertsManager Instance] moveToPositionX:leftX Animated:false];
	
	if(alertsButtonOpen)
		leftX += [[MidasAlertsManager Instance] widthOfView];
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
	// Twitter button
	buttonFrame = [twitterButton frame];
	[twitterButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasTwitterManager Instance] viewDisplayed])
		[[MidasTwitterManager Instance] moveToPositionX:leftX Animated:false];
	
	if(twitterButtonOpen)
		leftX += [[MidasTwitterManager Instance] widthOfView];
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
	// Facebook button
	buttonFrame = [facebookButton frame];
	[facebookButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasFacebookManager Instance] viewDisplayed])
		[[MidasFacebookManager Instance] moveToPositionX:leftX Animated:false];
	
	if(facebookButtonOpen)
		leftX += [[MidasFacebookManager Instance] widthOfView];
	else
		leftX += CGRectGetWidth(buttonFrame);
	
	leftX += 2;
	
	// MidasChat button
	buttonFrame = [midasChatButton frame];
	[midasChatButton setFrame:CGRectMake(leftX, 0, CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasChatManager Instance] viewDisplayed])
		[[MidasChatManager Instance] moveToPositionX:leftX Animated:false];
		
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
	
	// Head to Head button
	buttonFrame = [headToHeadButton frame];
	if(headToHeadButtonOpen)
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
	
	// Time controls button
	buttonFrame = [timeControlsButton frame];
	rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 20;
	
	if(rightX > 134)
		rightX = 134;
	
	buttonFrame = [vipButton frame];
	if(vipButtonOpen)
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
	
	
	rightX -= 4;
	
	buttonFrame = [myTeamButton frame];
	if(myTeamButtonOpen)
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
	
	
	// See if we need to offset buttons
	
	float buttonOffset = 0.0;
	
	if(leftPopupX < 10)
	{
		float popupCentre = (rightPopupX + leftPopupX) / 2;
		buttonOffset = CGRectGetMidX(viewBounds) - popupCentre;
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
		[headToHeadButton setAlpha:0.0];
		[timeControlsButton setAlpha:0.0];
		[vipButton setAlpha:0.0];
		[myTeamButton setAlpha:0.0];
	}
	else
	{
		[moreLeftImage setAlpha:0.0];
		[moreRightImage setAlpha:0.0];
		
		[standingsButton setAlpha:1.0];
		[mapButton setAlpha:1.0];
		[followDriverButton setAlpha:1.0];
		[headToHeadButton setAlpha:1.0];
		[timeControlsButton setAlpha:1.0];
		[vipButton setAlpha:1.0];
		[myTeamButton setAlpha:1.0];
	}

	
	// Then do the actual position
	rightX = CGRectGetMaxX(viewBounds) - 2 + buttonOffset;
	
	// Standings button
	buttonFrame = [standingsButton frame];
	[standingsButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasStandingsManager Instance] viewDisplayed])
		[[MidasStandingsManager Instance] moveToPositionX:rightX Animated:false];
			
	if(standingsButtonOpen)
		rightX -= [[MidasStandingsManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Circuit button
	buttonFrame = [mapButton frame];
	[mapButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasCircuitViewManager Instance] viewDisplayed])
		[[MidasCircuitViewManager Instance] moveToPositionX:rightX Animated:false];
	
	if(mapButtonOpen)
		rightX -= [[MidasCircuitViewManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Follow driver button
	buttonFrame = [followDriverButton frame];
	[followDriverButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	if([[MidasFollowDriverManager Instance] viewDisplayed])
		[[MidasFollowDriverManager Instance] moveToPositionX:rightX Animated:false];
	
	if(followDriverButtonOpen)
		rightX -= [[MidasFollowDriverManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Head to Head button
	buttonFrame = [headToHeadButton frame];
	[headToHeadButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	
	if(headToHeadButtonOpen)
		rightX -= [[MidasStandingsManager Instance] widthOfView];
	else
		rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 2;
	
	// Time controls button
	buttonFrame = [timeControlsButton frame];
	[timeControlsButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	
	rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 20;
	
	if(rightX > 134)
		rightX = 134;
	
	buttonFrame = [vipButton frame];
	[vipButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
	
	rightX -= CGRectGetWidth(buttonFrame);
	
	rightX -= 4;
	
	buttonFrame = [myTeamButton frame];
	[myTeamButton setFrame:CGRectMake(rightX - CGRectGetWidth(buttonFrame), CGRectGetMinY(buttonFrame), CGRectGetWidth(buttonFrame), CGRectGetHeight(buttonFrame))];
}

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
	[midasMenuButton setFrame:CGRectOffset([midasMenuButton frame], -CGRectGetWidth([midasMenuButton frame]), 0)];
	
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
	[midasMenuButton setFrame:CGRectOffset([midasMenuButton frame], CGRectGetWidth([midasMenuButton frame]), 0)];
	
	// Bottom buttons
	[bottomButtonPanel setFrame:CGRectOffset([bottomButtonPanel frame], 0, -CGRectGetHeight([standingsButton frame]))];
	
	[UIView commitAnimations];
}

- (void)menuAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([finished intValue] == 1)
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
	if(!button || button == alertsButton || button == twitterButton || button == facebookButton || button == midasChatButton)
	{
		[UIView beginAnimations:nil context:button];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(menuButtonAnimationDidStop:finished:context:)];
		
		[UIView setAnimationDuration:0.5];
		
		[self positionMenuButtons];
		
		[UIView commitAnimations];
		
	}
	else if(button == standingsButton || button == mapButton || button == followDriverButton || button == headToHeadButton)
	{
		[UIView beginAnimations:nil context:button];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(menuButtonAnimationDidStop:finished:context:)];
		
		[UIView setAnimationDuration:0.5];
		
		[self positionMenuButtons];
				
		[UIView commitAnimations];
	}
	else if(button == vipButton || button == myTeamButton)
	{
	}
	else if(button == midasMenuButton)
	{
	}
}

- (void)menuButtonAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([finished intValue] == 1)
	{
		menuButtonsAnimating = false;
	}
}

// Button flashing for push notification

-(void)flashMenuButton:(UIButton *)button
{
	if(!menuButtonsDisplayed || menuButtonsAnimating)
		return;
	
	menuButtonsAnimating = true;
	
	// Top buttons only
	if(button == alertsButton || button == twitterButton || button == facebookButton || button == midasChatButton)
	{
		CGRect baseFrame = [button frame];
		
		int buttonOffset;
		CGRect newFrame;
		UIImage * newImage;
		
		if(baseFrame.size.width > unselectedButtonWidth)	// i.e. it's already open so we'll close
		{
			buttonOffset = unselectedButtonWidth - baseFrame.size.width;
			newFrame = CGRectMake(baseFrame.origin.x, baseFrame.origin.y, unselectedButtonWidth, baseFrame.size.height);
			newImage = unselectedTopButtonImage;
		}
		else
		{
			buttonOffset = selectedButtonWidth - baseFrame.size.width;
			newFrame = CGRectMake(baseFrame.origin.x, baseFrame.origin.y, selectedButtonWidth, baseFrame.size.height);
			newImage = selectedTopButtonImage;
		}
		
		[buttonBackgroundAnimationImage setImage:newImage];
		[buttonBackgroundAnimationImage setFrame:baseFrame];
		[buttonBackgroundAnimationImage setHidden:false];
		
		[button setBackgroundImage:nil forState:UIControlStateNormal];
		newButtonBackgroundImage = [newImage retain];
		
		[UIView beginAnimations:nil context:button];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(menuFlashDidStop:finished:context:)];
		
		[UIView setAnimationDuration:0.75];
		
		[buttonBackgroundAnimationImage setFrame:newFrame];
		[button setFrame:newFrame];
		
		if([alertsButton frame].origin.x > baseFrame.origin.x)
			[alertsButton setFrame:CGRectOffset([alertsButton frame], buttonOffset, 0)];
		
		if([twitterButton frame].origin.x > baseFrame.origin.x)
			[twitterButton setFrame:CGRectOffset([twitterButton frame], buttonOffset, 0)];
		
		if([facebookButton frame].origin.x > baseFrame.origin.x)
			[facebookButton setFrame:CGRectOffset([facebookButton frame], buttonOffset, 0)];
		
		if([midasChatButton frame].origin.x > baseFrame.origin.x)
			[midasChatButton setFrame:CGRectOffset([midasChatButton frame], buttonOffset, 0)];
		
		[UIView commitAnimations];
	}
}

- (void)menuFlashDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([finished intValue] == 1)
	{
		menuButtonsAnimating = false;
		[(UIButton *)context setBackgroundImage:newButtonBackgroundImage forState:UIControlStateNormal];
		[newButtonBackgroundImage release];
		newButtonBackgroundImage = nil;
		
		[buttonBackgroundAnimationImage setHidden:true];
	}
}

- (bool) dismissPopupViews
{
	return [self dismissPopupViewsWithExclusion:MIDAS_POPUP_NONE_  InZone:(int)MIDAS_ZONE_ALL_ AnimateMenus:true];
}

- (bool) dismissPopupViewsWithExclusion:(int)excludedPopupType InZone:(int)popupZone AnimateMenus:(bool)animateMenus
{
	bool popupDismissed = false;
	
	if(excludedPopupType != MIDAS_ALERTS_POPUP_ &&
	   [[MidasAlertsManager Instance] viewDisplayed] &&
	   (popupZone & MIDAS_ZONE_TOP_) > 0)
	{
		[[MidasAlertsManager Instance] hideAnimated:true Notify:false];
		alertsButtonOpen = false;
		[alertsButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_TWITTER_POPUP_ &&
	   [[MidasTwitterManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_ZONE_TOP_) > 0 || (popupZone & MIDAS_ZONE_SOCIAL_MEDIA_) > 0))
	{
		[[MidasTwitterManager Instance] hideAnimated:true Notify:false];
		twitterButtonOpen = false;
		[twitterButton setHidden:false];
		popupDismissed= true;
	}
	
	   if(excludedPopupType != MIDAS_FACEBOOK_POPUP_ &&
		  [[MidasFacebookManager Instance] viewDisplayed] &&
		  ((popupZone & MIDAS_ZONE_TOP_) > 0 || (popupZone & MIDAS_ZONE_SOCIAL_MEDIA_) > 0))
	{
		[[MidasFacebookManager Instance] hideAnimated:true Notify:false];
		facebookButtonOpen = false;
		[facebookButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_CHAT_POPUP_ &&
	   [[MidasChatManager Instance] viewDisplayed] &&
	   ((popupZone & MIDAS_ZONE_TOP_) > 0 || (popupZone & MIDAS_ZONE_SOCIAL_MEDIA_) > 0))

	{
		[[MidasChatManager Instance] hideAnimated:true Notify:false];
		midasChatButtonOpen = false;
		[midasChatButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_STANDINGS_POPUP_ &&
	   [[MidasStandingsManager Instance] viewDisplayed] &&
	   (popupZone & MIDAS_ZONE_BOTTOM_) > 0)

	{
		[[MidasStandingsManager Instance] hideAnimated:true Notify:false];
		standingsButtonOpen = false;
		[standingsButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_CIRCUIT_POPUP_ &&
	   [[MidasCircuitViewManager Instance] viewDisplayed] &&
	   (popupZone & MIDAS_ZONE_BOTTOM_) > 0)

	{
		[[MidasCircuitViewManager Instance] hideAnimated:true Notify:false];
		mapButtonOpen = false;
		[mapButton setHidden:false];
		popupDismissed= true;
	}
	
	if(excludedPopupType != MIDAS_FOLLOW_DRIVER_POPUP_ &&
	   [[MidasFollowDriverManager Instance] viewDisplayed] &&
	   (popupZone & MIDAS_ZONE_BOTTOM_) > 0)

	{
		[[MidasFollowDriverManager Instance] hideAnimated:true Notify:false];
		followDriverButtonOpen = false;
		[followDriverButton setHidden:false];
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
// MidasPopupParentDelegate methods

#pragma mark MidasPopupParentDelegate methods

- (void)notifyShowingPopup:(int)popupType
{
	switch(popupType)
	{
		case MIDAS_ALERTS_POPUP_:
			[alertsButton setHidden:true];
			break;
			
		case MIDAS_TWITTER_POPUP_:
			[twitterButton setHidden:true];
			break;
			
		case MIDAS_FACEBOOK_POPUP_:
			[facebookButton setHidden:true];
			break;
			
		case MIDAS_CHAT_POPUP_:
			[midasChatButton setHidden:true];
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
			
		default:
			break;
	}
	
//	[self.view bringSubviewToFront:bottomButtonPanel];
//	[self.view bringSubviewToFront:topButtonPanel];
	
	[self animateMenuButton:nil];
}

- (void)notifyHidingPopup:(int)popupType
{
	switch(popupType)
	{
		case MIDAS_ALERTS_POPUP_:
			alertsButtonOpen = false;
			[alertsButton setHidden:false];
			[self animateMenuButton:alertsButton];
			break;
			
		case MIDAS_TWITTER_POPUP_:
			twitterButtonOpen = false;
			[twitterButton setHidden:false];
			[self animateMenuButton:twitterButton];
			break;
			
		case MIDAS_FACEBOOK_POPUP_:
			facebookButtonOpen = false;
			[facebookButton setHidden:false];
			[self animateMenuButton:facebookButton];
			break;
			
		case MIDAS_CHAT_POPUP_:
			midasChatButtonOpen = false;
			[midasChatButton setHidden:false];
			[self animateMenuButton:midasChatButton];
			break;
			
		case MIDAS_STANDINGS_POPUP_:
			standingsButtonOpen = false;
			[standingsButton setHidden:false];
			[self animateMenuButton:standingsButton];
			break;
			
		case MIDAS_CIRCUIT_POPUP_:
			mapButtonOpen = false;
			[mapButton setHidden:false];
			[self animateMenuButton:mapButton];
			break;
			
		case MIDAS_FOLLOW_DRIVER_POPUP_:
			followDriverButtonOpen = false;
			[followDriverButton setHidden:false];
			[self animateMenuButton:followDriverButton];
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

@end


