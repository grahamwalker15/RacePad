//
//  CompositeViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CompositeViewController.h"
#import "RacePadCoordinator.h"
#import "RacePadTitleBarController.h"
#import "RacePadTimeController.h"

#import "VideoHelpController.h"

#import "RacePadDatabase.h"
#import "TableDataView.h"
#import "TrackMapView.h"
#import "TrackMap.h"

@implementation CompositeViewController

@synthesize displayMap;
@synthesize displayLeaderboard;

- (void)viewDidLoad
{	
	// Initialise display options
	displayMap = true;
	displayLeaderboard = true;

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

	// Set leaderboard data source and associate  with zoom map
 	[leaderboardView SetTableDataClass:[[RacePadDatabase Instance] leaderBoardData]];
	[leaderboardView setAssociatedTrackMapView:trackZoomView];
	
	// Get the video archive file name from RacePadCoordinator
	currentMovie = [[self getVideoArchiveName] retain];
	[self getStartTime];
	
	moviePlayer = [[AVPlayer alloc] initWithURL:[NSURL fileURLWithPath:currentMovie]];
	[moviePlayer setActionAtItemEnd:AVPlayerActionAtItemEndPause];
		
	// Tap,pan and pinch recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addLongPressRecognizerToView:trackMapView];
	[self addDoubleTapRecognizerToView:trackMapView];
	[self addPanRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	
	// And  for the zoom map
	[self addTapRecognizerToView:trackZoomView];
	[self addDoubleTapRecognizerToView:trackZoomView];
	[self addPinchRecognizerToView:trackZoomView];
	
	// And add pan view to the trackZoomView to allow dragging the container
	[self addPanRecognizerToView:trackZoomView];
	
	// Add tap recognizer to overlay in order to catch taps outside map
	[self addTapRecognizerToView:overlayView];

	// Add tap and long press recognizers to the leaderboard
	[self addTapRecognizerToView:leaderboardView];
	[self addLongPressRecognizerToView:leaderboardView];

	// We'll get notification when we know the movie size - set it to a default for now
	movieSize = CGSizeMake(768, 576);
	movieRect = CGRectMake(0, 0, 768, 576);
	[self positionOverlays];
	
	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:movieView WithType:RPC_VIDEO_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackZoomView WithType:RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] AddView:leaderboardView WithType:RPC_LEADER_BOARD_VIEW_];
	
	[super viewDidLoad];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Check that we have the right movie loaded
	NSString *movie = [[self getVideoArchiveName] retain];
	if ( [movie compare:currentMovie] != NSOrderedSame )
	{
		AVPlayerItem * item = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:movie]];
		[moviePlayer replaceCurrentItemWithPlayerItem:item];
		[currentMovie release];
		currentMovie = movie;
		[self getStartTime];
	}
	else
	{
		[movie release];
	}
	
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:(RPC_VIDEO_VIEW_ | RPC_TRACK_MAP_VIEW_ | RPC_LAP_COUNT_VIEW_)];

	// Position the movie and order the overlays
	CALayer *superlayer = movieView.layer;
	moviePlayerLayer = [AVPlayerLayer playerLayerWithPlayer:moviePlayer];
	[moviePlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
	[moviePlayerLayer setFrame:[movieView bounds]];

	[superlayer addSublayer:moviePlayerLayer];

	//[[moviePlayer view] setFrame:[movieView bounds]];
	//[movieView addSubview:[moviePlayer view]];
	
	[self positionOverlays];
	
	[movieView bringSubviewToFront:overlayView];
	[movieView bringSubviewToFront:trackMapView];
	[movieView bringSubviewToFront:leaderboardView];
	[movieView bringSubviewToFront:trackZoomContainer];
	[movieView bringSubviewToFront:trackZoomView];
	
	// Get notification when we know the movie size
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieSizeCallback:)
													name:MPMovieNaturalSizeAvailableNotification
													object:moviePlayer];
	
	float time_of_day = [[RacePadCoordinator Instance] currentTime];
	[self movieGotoTime:time_of_day];
	
	if([trackZoomView carToFollow] != nil)
	{
		[trackZoomView setUserScale:10.0];
		[trackZoomContainer setHidden:false];
	}
	
	[[RacePadCoordinator Instance] SetViewDisplayed:movieView];
	
	if(displayMap)
	{
		[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
		[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
	}
	
	if(displayLeaderboard)
	{
		[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:movieView];

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
	
	[moviePlayer pause];
	[moviePlayerLayer removeFromSuperlayer];
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
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
	[moviePlayerLayer setFrame:[movieView bounds]];
	[UIView commitAnimations];
	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
	[moviePlayerLayer release];
	[moviePlayer release];
    [super dealloc];
}

- (HelpViewController *) helpController
{
	if(!helpController)
		helpController = [[VideoHelpController alloc] initWithNibName:@"VideoHelp" bundle:nil];
	
	return (HelpViewController *)helpController;
}

////////////////////////////////////////////////////////////////////////////
// Movie information
////////////////////////////////////////////////////////////////////////////

- (void) getStartTime
{
	startTime = -1;
	
	// Try to find a meta file
	NSString *metaFileName = [currentMovie stringByReplacingOccurrencesOfString:@".m4v" withString:@".vmd"];
	metaFileName = [metaFileName stringByReplacingOccurrencesOfString:@".mp4" withString:@".vmd"];
	FILE *metaFile = fopen([metaFileName UTF8String], "rt" );
	if ( metaFile )
	{
		char keyword[128];
		int value;
		if ( fscanf(metaFile, "%128s %d", keyword, &value ) == 2 )
			if ( strcmp ( keyword, "VideoStartTime" ) == 0 )
				startTime = value;
		fclose(metaFile);
	}
	
	if ( startTime == -1 )
	{
		// Default to hard coded start time
		startTime = 13 * 3600.0 + 43 * 60.0 + 40;
	}
}

- (NSString *)getVideoArchiveName
{
	NSString *name = [[RacePadCoordinator Instance] getVideoArchiveName];
	
	// Use a default bundled video if it can't be found
	if(!name)
		name = [[NSBundle mainBundle] pathForResource:@"Movie on 2010-10-04 at 16.26" ofType:@"mov"];
	
	return name;
}

////////////////////////////////////////////////////////////////////////////
// Play controls
////////////////////////////////////////////////////////////////////////////


- (void) movieLoad:(NSString *)movie_name
{
}

- (void) movieSetStartTime:(float)time
{
	startTime = time;
}

- (void) moviePrepareToPlay
{
	//[moviePlayer prepareToPlay];
}

- (void) moviePlay
{
	[moviePlayer play];
}

- (void) movieStop
{
	[moviePlayer pause];	
}

- (void) movieGotoTime:(float)time
{
	Float64 movie_time = time - startTime;
	
	CMTime cm_time = CMTimeMakeWithSeconds(movie_time, 600);
	
	[moviePlayer seekToTime:cm_time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
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
	[trackZoomContainer setFrame:zoom_frame];
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
				[self hideZoomMap];
				[leaderboardView RequestRedraw];
			}
			else
			{
				[trackZoomView followCar:name];
				
				if(!zoomMapVisible)
					[self showZoomMap];
				
				[trackZoomView setUserScale:10.0];
				[trackZoomView RequestRedraw];
				[leaderboardView RequestRedraw];
			}
			
			return;
		}
		
	}
	
	// Reach here if either tap was outside leaderboard, or no car was found at tap point
	RacePadTimeController * time_controller = [RacePadTimeController Instance];

	if(![time_controller displayed])
	{
		[time_controller displayInViewController:self Animated:true];
	}
	else
	{
		[time_controller hide];
	}

}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	// Make sure we're on the map - do nothing otherwise
	if(!gestureView || ![gestureView isKindOfClass:[TrackMapView class]])
	{
		return;
	}
	
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	if([(TrackMapView *)gestureView isZoomView])
	{
		[self hideZoomMap];
	}
	else
	{
		float current_scale = [(TrackMapView *)gestureView userScale];
		float current_xoffset = [(TrackMapView *)gestureView userXOffset];
		float current_yoffset = [(TrackMapView *)gestureView userYOffset];

		if(current_scale == 1.0 && current_xoffset == 0.0 && current_yoffset == 0.0)
		{
			[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:10 X:x Y:y];
		}
		else
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

	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];	
	
	if([gestureView isKindOfClass:[TrackMapView class]])
	{
		float current_scale = [(TrackMapView *)gestureView userScale];
		if(current_scale > 0.001)
		{
			[trackMap adjustScaleInView:(TrackMapView *)gestureView Scale:10/current_scale X:x Y:y];
		}
	}
	else if([gestureView isKindOfClass:[LeaderboardView class]])
	{
		NSString * name = [leaderboardView carNameAtX:x Y:y];
		[[(LeaderboardView *)gestureView associatedTrackMapView] followCar:name];
		[trackZoomContainer setHidden:false];

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

- (void) movieSizeCallback:(NSNotification*) aNotification
{
	MPMoviePlayerController *player = [aNotification object];
	movieSize = [player naturalSize];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMovieNaturalSizeAvailableNotification object:player];
    
	[self positionOverlays];
}

- (void) movieFinishedCallback:(NSNotification*) aNotification
{
	MPMoviePlayerController *player = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
	[player stop];
	[self.view removeFromSuperview];
	[player autorelease];    
}

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
	[[RacePadTimeController Instance] setHideTimer];
	
	int selectedSegment = [optionSwitches selectedSegmentIndex];
	
	if(selectedSegment == 0)
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
	else
	{
		bool zoomMapVisible = ([trackZoomView carToFollow] != nil);
		displayMap = true;
		displayLeaderboard = true;
		[trackMapView setHidden:false];
		[leaderboardView setHidden:false];
		
		[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
		[[RacePadCoordinator Instance] SetViewDisplayed:leaderboardView];
		
		[trackMapView RequestRedraw];
		[leaderboardView RequestRedraw];
		
		if(zoomMapVisible)
		{
			[trackZoomContainer setHidden:false];
			[[RacePadCoordinator Instance] SetViewDisplayed:trackZoomView];
			[trackZoomView RequestRedraw];
		}
	}	

}

@end
