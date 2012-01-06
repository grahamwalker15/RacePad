//
//  MidasVideoViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasVideoViewController.h"

#import "MidasStandingsManager.h"


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
static UIImage * unselectedBottomButtonImage = nil;

static UIImage * selectedStandingsImage = nil;

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
			unselectedBottomButtonImage = [[UIImage imageNamed:@"bottom-container-unselected.png"] retain];
			
			selectedStandingsImage = [[UIImage imageNamed:@"standings-selected.png"] retain];
		}
		else
		{
			[selectedTopButtonImage retain];
			[unselectedTopButtonImage retain];
			[unselectedBottomButtonImage retain];
			
			[selectedStandingsImage retain];
		}
		
	}
    return self;
}

- (void)viewDidLoad
{	
	
	[super viewDidLoad];
	
	// Fixed data
	unselectedButtonWidth = 66;
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
	
	moviePlayerLayerAdded = false;
	
	[movieView setStyle:BG_STYLE_MIDAS_];
	
	[buttonBackgroundAnimationImage setHidden:true];
	
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
	
	// Add tap and long press recognizers to the leaderboard
	// GG - COMMENT OUT LEADERBOARD : [self addTapRecognizerToView:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : [self addLongPressRecognizerToView:leaderboardView];
	
	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:movieView WithType:RPC_VIDEO_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackZoomView WithType:RPC_TRACK_MAP_VIEW_];
	// GG - COMMENT OUT LEADERBOARD : [[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	
	[[RacePadCoordinator Instance] setVideoViewController:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	//[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary: true];
	
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_VIDEO_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];
	
	// We'll get notification when we know the movie size - set it to a default for now
	movieSize = CGSizeMake(768, 576);
	movieRect = CGRectMake(0, 0, 768, 576);
	[self positionOverlays];
	
	[movieView bringSubviewToFront:overlayView];
	[movieView bringSubviewToFront:trackMapView];
	// GG - COMMENT OUT LEADERBOARD : [movieView bringSubviewToFront:leaderboardView];
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
	
	// GG - COMMENT OUT LEADERBOARD : if(displayLeaderboard)
	// GG - COMMENT OUT LEADERBOARD : {
	// GG - COMMENT OUT LEADERBOARD : 	[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
	// GG - COMMENT OUT LEADERBOARD : }
	
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
		[[RacePadCoordinator Instance] SetViewHidden:movieView];
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
	
	AVPlayerLayer * moviePlayerLayer = [[BasePadMedia Instance] moviePlayerLayer];	
	if(moviePlayerLayer)
	{
		[moviePlayerLayer setFrame:[movieView bounds]];
	}
	
	[UIView commitAnimations];
	
	[[CommentaryBubble Instance] didRotateInterface];
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
	[selectedTopButtonImage release];
	[unselectedTopButtonImage release];
	[unselectedBottomButtonImage release];
	
	[selectedStandingsImage release];
	
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

- (void) displayMovieInView
{	
	// Position the movie and order the overlays
	AVPlayerLayer * moviePlayerLayer = [[BasePadMedia Instance] moviePlayerLayer];
	
	if(moviePlayerLayer && !moviePlayerLayerAdded)
	{
		CALayer *superlayer = movieView.layer;
		
		[moviePlayerLayer setFrame:[movieView bounds]];
		[superlayer addSublayer:moviePlayerLayer];
		
		moviePlayerLayerAdded = true;
	}
	
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

- (void) removeMovieFromView
{
	AVPlayerLayer * moviePlayerLayer = [[BasePadMedia Instance] moviePlayerLayer];
	if(moviePlayerLayer && moviePlayerLayerAdded)
	{
		[moviePlayerLayer removeFromSuperlayer];
		moviePlayerLayerAdded = false;
	}	
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
	
	// GG - COMMENT OUT LEADERBOARD : CGRect lb_frame = CGRectMake(movieRect.origin.x + 5, movieRect.origin.y, 60, movieRect.size.height);
	// GG - COMMENT OUT LEADERBOARD : [leaderboardView setFrame:lb_frame];
	
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
	if(![self checkForPopupViews])
		[self handleMenuButtonDisplayGestureInView:gestureView AtX:x Y:y];
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
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

	if(sender == timeControlsButton)
	{
		[self hideMenuButtons];
		[self toggleTimeControllerDisplay];
	}
	
	if(sender == alertsButton || sender == twitterButton || sender == facebookButton || sender == midasChatButton)
	{
		[self flashMenuButton:(UIButton *)sender];
	}
	
	if(sender == standingsButton)
	{
		if(![[MidasStandingsManager Instance] displayed])
		{
			standingsButtonOpen = true;
			[self animateMenuButton:standingsButton withNewWidth:[[MidasStandingsManager Instance] widthOfView] andImage:selectedStandingsImage];
			[[MidasStandingsManager Instance] displayInViewController:self AtX:772 Y:128 Animated:true];
		}
	}
}

- (void) notifyHidingTimeControls
{
	[self showMenuButtons];
}

- (void)notifyHidingStandings
{
	standingsButtonOpen = false;
	[self animateMenuButton:standingsButton withNewWidth:unselectedButtonWidth andImage:unselectedBottomButtonImage];
}

- (void)notifyHidingCircuitView
{
}

- (void)notifyHidingFollowDriver
{
}

- (void)notifyHidingHeadToHead
{
}

///////////////////////////////////////////////////////////////////
// Button Animation Routines


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
	[alertsButton setFrame:CGRectOffset([alertsButton frame], 0, -CGRectGetHeight([alertsButton frame]))];
	[twitterButton setFrame:CGRectOffset([twitterButton frame], 0, -CGRectGetHeight([twitterButton frame]))];
	[facebookButton setFrame:CGRectOffset([facebookButton frame], 0, -CGRectGetHeight([facebookButton frame]))];
	[midasChatButton setFrame:CGRectOffset([midasChatButton frame], 0, -CGRectGetHeight([midasChatButton frame]))];
	
	// Side buttons
	[midasMenuButton setFrame:CGRectOffset([midasMenuButton frame], -CGRectGetWidth([midasMenuButton frame]), 0)];
	
	// Bottom buttons
	[standingsButton setFrame:CGRectOffset([standingsButton frame], 0, CGRectGetHeight([standingsButton frame]))];
	[mapButton setFrame:CGRectOffset([mapButton frame], 0, CGRectGetHeight([mapButton frame]))];
	[followDriverButton setFrame:CGRectOffset([followDriverButton frame], 0, CGRectGetHeight([followDriverButton frame]))];
	[headToHeadButton setFrame:CGRectOffset([headToHeadButton frame], 0, CGRectGetHeight([headToHeadButton frame]))];
	[timeControlsButton setFrame:CGRectOffset([timeControlsButton frame], 0, CGRectGetHeight([timeControlsButton frame]))];
	[vipButton setFrame:CGRectOffset([vipButton frame], 0, CGRectGetHeight([vipButton frame]))];
	[myTeamButton setFrame:CGRectOffset([myTeamButton frame], 0, CGRectGetHeight([myTeamButton frame]))];
	
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
	[alertsButton setFrame:CGRectOffset([alertsButton frame], 0, CGRectGetHeight([alertsButton frame]))];
	[twitterButton setFrame:CGRectOffset([twitterButton frame], 0, CGRectGetHeight([twitterButton frame]))];
	[facebookButton setFrame:CGRectOffset([facebookButton frame], 0, CGRectGetHeight([facebookButton frame]))];
	[midasChatButton setFrame:CGRectOffset([midasChatButton frame], 0, CGRectGetHeight([midasChatButton frame]))];
	
	// Side buttons
	[midasMenuButton setFrame:CGRectOffset([midasMenuButton frame], CGRectGetWidth([midasMenuButton frame]), 0)];
	
	// Bottom buttons
	[standingsButton setFrame:CGRectOffset([standingsButton frame], 0, -CGRectGetHeight([standingsButton frame]))];
	[mapButton setFrame:CGRectOffset([mapButton frame], 0, -CGRectGetHeight([mapButton frame]))];
	[followDriverButton setFrame:CGRectOffset([followDriverButton frame], 0, -CGRectGetHeight([followDriverButton frame]))];
	[headToHeadButton setFrame:CGRectOffset([headToHeadButton frame], 0, -CGRectGetHeight([headToHeadButton frame]))];
	[timeControlsButton setFrame:CGRectOffset([timeControlsButton frame], 0, -CGRectGetHeight([timeControlsButton frame]))];
	[vipButton setFrame:CGRectOffset([vipButton frame], 0, -CGRectGetHeight([vipButton frame]))];
	[myTeamButton setFrame:CGRectOffset([myTeamButton frame], 0, -CGRectGetHeight([myTeamButton frame]))];
	
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

-(void)animateMenuButton:(UIButton *)button withNewWidth:(float)newWidth andImage:(UIImage *)newImage
{
	if(!menuButtonsDisplayed || menuButtonsAnimating)
		return;
	
	menuButtonsAnimating = true;
	
	// Top,bottom or side?
	if(button == alertsButton || button == twitterButton || button == facebookButton || button == midasChatButton)
	{
		// Top buttons
		CGRect baseFrame = [button frame];
		
		int buttonOffset;
		CGRect newFrame;
		
		buttonOffset = newWidth - baseFrame.size.width;
		newFrame = CGRectMake(baseFrame.origin.x, baseFrame.origin.y, newWidth, baseFrame.size.height);
		
		[buttonBackgroundAnimationImage setImage:newImage];
		[buttonBackgroundAnimationImage setFrame:baseFrame];
		[buttonBackgroundAnimationImage setHidden:false];
		
		[button setBackgroundImage:nil forState:UIControlStateNormal];
		newButtonBackgroundImage = [newImage retain];
		
		[UIView beginAnimations:nil context:button];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(menuButtonAnimationDidStop:finished:context:)];
		
		[UIView setAnimationDuration:0.5];
		
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
	else if(button == standingsButton || button == mapButton || button == followDriverButton || button == headToHeadButton)
	{
		// Bottom buttons
		CGRect baseFrame = [button frame];
		
		int buttonOffset;
		CGRect newFrame;
		
		buttonOffset = newWidth - baseFrame.size.width;
		newFrame = CGRectMake(CGRectGetMaxX(baseFrame) - newWidth, baseFrame.origin.y, newWidth, baseFrame.size.height);
		
		[buttonBackgroundAnimationImage setImage:newImage];
		[buttonBackgroundAnimationImage setFrame:baseFrame];
		[buttonBackgroundAnimationImage setHidden:false];
		
		[button setBackgroundImage:nil forState:UIControlStateNormal];
		newButtonBackgroundImage = [newImage retain];
		
		[UIView beginAnimations:nil context:button];
		
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(menuButtonAnimationDidStop:finished:context:)];
		
		[UIView setAnimationDuration:0.5];
		
		if([standingsButton frame].origin.x < baseFrame.origin.x)
			[standingsButton setFrame:CGRectOffset([standingsButton frame], -buttonOffset, 0)];
		
		if([mapButton frame].origin.x < baseFrame.origin.x)
			[mapButton setFrame:CGRectOffset([mapButton frame], -buttonOffset, 0)];
		
		if([followDriverButton frame].origin.x < baseFrame.origin.x)
			[followDriverButton setFrame:CGRectOffset([followDriverButton frame], -buttonOffset, 0)];
		
		if([headToHeadButton frame].origin.x < baseFrame.origin.x)
			[headToHeadButton setFrame:CGRectOffset([headToHeadButton frame], -buttonOffset, 0)];
		
		if([timeControlsButton frame].origin.x < baseFrame.origin.x)
			[timeControlsButton setFrame:CGRectOffset([timeControlsButton frame], -buttonOffset, 0)];
		
		[buttonBackgroundAnimationImage setFrame:newFrame];
		[button setFrame:newFrame];
		
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
		[(UIButton *)context setBackgroundImage:newButtonBackgroundImage forState:UIControlStateNormal];
		[newButtonBackgroundImage release];
		newButtonBackgroundImage = nil;
		
		[buttonBackgroundAnimationImage setHidden:true];
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

- (bool) checkForPopupViews
{
	bool popupDismissed = false;
	
	if([[MidasStandingsManager Instance] displayed])
	{
		[[MidasStandingsManager Instance] hideAnimated:true];
		[self notifyHidingStandings];
		popupDismissed= true;
	}
	
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

@end


