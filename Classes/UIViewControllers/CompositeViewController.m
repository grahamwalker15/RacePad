//
//  CompositeViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "CompositeViewController.h"
#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadDatabase.h"
#import "TableDataView.h"
#import "TrackMapView.h"
#import "TrackMap.h"

@implementation CompositeViewController


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView {
 }
 */


- (void)viewDidLoad
{
	// Get the video archive file name from RacePadCoordinator
	NSString *url = [[RacePadCoordinator Instance] getVideoArchiveName];
	
	// Use a default bundled video if it can't be found
	if(!url)
		url = [[NSBundle mainBundle] pathForResource:@"Movie on 2010-10-04 at 16.26" ofType:@"mov"];
	
	moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
	[moviePlayer setShouldAutoplay:false];
	[moviePlayer setControlStyle:MPMovieControlStyleNone];
	[[moviePlayer view] setUserInteractionEnabled:true];
	
	// We'll get notification when we know the movie size - set itto zero for now
	movieSize = CGSizeMake(0, 0);
	movieRect = CGRectMake(0, 0, 0, 0);
	
	// Hard code start time for the moment
	startTime = 13 * 3600.0 + 43 * 60.0 + 40;
	
	// Tap,pan and pinch recognizers for map
	[self addTapRecognizerToView:trackMapView];
	[self addPanRecognizerToView:trackMapView];
	[self addPinchRecognizerToView:trackMapView];
	
	// Add tap recognizer to overlay in order to catch taps outside map
	[self addTapRecognizerToView:overlayView];

	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:movieView WithType:RPC_VIDEO_VIEW_];
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
	
	/*
	 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieFinishedCallback:)
	 name:MPMoviePlayerPlaybackDidFinishNotification
	 object:[playerViewController moviePlayer]];
	 
	 [self.view addSubview:playerViewController.view];
	 
	 //---play movie---
	 MPMoviePlayerController *player = [playerViewController moviePlayer];
	 [player play];
	 */
	
	[super viewDidLoad];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	[[moviePlayer view] setFrame:[movieView bounds]];
	[movieView addSubview:[moviePlayer view]];
	[self.view bringSubviewToFront:overlayView];
	[self.view bringSubviewToFront:trackMapView];
	
	// Get notification when we know the movie size
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieSizeCallback:)
												 name:MPMovieNaturalSizeAvailableNotification
											   object:moviePlayer];
	
	float time_of_day = [[RacePadCoordinator Instance] currentTime];
	[self movieGotoTime:time_of_day];
	
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_VIDEO_VIEW_ | RPC_TRACK_MAP_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:movieView];
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:movieView];
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	[moviePlayer stop];
	[[moviePlayer view] removeFromSuperview];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.75];
	[[moviePlayer view] setFrame:[movieView bounds]];	
	[UIView commitAnimations];
		
	[self positionOverlays];

	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
	[moviePlayer release];
    [super dealloc];
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
	[moviePlayer prepareToPlay];
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
	NSTimeInterval movie_time = time - startTime;
	[moviePlayer setCurrentPlaybackTime:movie_time];
	[moviePlayer setInitialPlaybackTime:movie_time];
}

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
		float yOrigin = (movieViewSize.height - newHeight) / 2;
		movieRect = CGRectMake(0, yOrigin, movieViewSize.width, newHeight);
	}
	else
	{
		// It's height limited - work out height centred on view
		float newWidth = movieSize.width * hScale;
		float xOrigin = (movieViewSize.width - newWidth) / 2;
		movieRect = CGRectMake(xOrigin, 0, newWidth, movieViewSize.height);
	}
	
	[trackMapView setFrame:movieRect];
}

- (void) RequestRedrawForType:(int)type
{
}

- (void) OnGestureTapAtX:(float)x Y:(float)y
{
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
		[time_controller displayInViewController:self Animated:true];
	else
		[time_controller hide];
}

- (void) OnGestureDoubleTapAtX:(float)x Y:(float)y
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap setUserXOffset:0.0];
	[trackMap setUserYOffset:0.0];
	[trackMap setUserScale:1.0];
	
	[trackMapView RequestRedraw];
}

- (void) OnGesturePinchAtX:(float)x Y:(float)y Scale:(float)scale Speed:(float)speed
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	float currentUserPanX = [trackMap userXOffset];
	float currentUserPanY = [trackMap userYOffset];
	float currentUserScale = [trackMap userScale];
	float currentMapPanX = [trackMap mapXOffset];
	float currentMapPanY = [trackMap mapYOffset];
	float currentMapScale = [trackMap mapScale];
	float currentScale = currentUserScale * currentMapScale;
	
	if(fabs(currentScale) < 0.001 || fabs(scale) < 0.001)
		return;
	
	// Calculate where the centre point is in the untransformed map
	float x_in_map = (x - currentUserPanX - currentMapPanX) / currentScale; 
	float y_in_map = (y - currentUserPanY - currentMapPanY) / currentScale;
	
	// Now work out the new scale	
	float newScale = currentScale * scale;
	float newUserScale = currentUserScale * scale;
	
	// Now work out where that point in the map would go now
	float new_x = (x_in_map) * newScale + currentMapPanX;
	float new_y = (y_in_map) * newScale + currentMapPanY;
	
	// Andset the user pan to put it back where it was on the screen
	float newPanX = x - new_x ;
	float newPanY = y - new_y ;
	
	[trackMap setUserXOffset:newPanX];
	[trackMap setUserYOffset:newPanY];
	[trackMap setUserScale:newUserScale];
	
	[trackMapView RequestRedraw];
}

- (void) OnGesturePanByX:(float)x Y:(float)y SpeedX:(float)speedx SpeedY:(float)speedy
{
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	
	[trackMap setUserXOffset:[trackMap userXOffset] + x];
	[trackMap setUserYOffset:[trackMap userYOffset] + y];
	
	[trackMapView RequestRedraw];
}
@end
