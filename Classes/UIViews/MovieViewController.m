//
//  MovieViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieViewController.h"
#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"

@implementation MovieViewController

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

- (void)viewDidLoad
{
	// Get the video archive file name from RacePadCoordinator
	currentMovie = [[self getVideoArchiveName] retain];
	[self getStartTime];
		
	moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:currentMovie]];
	[moviePlayer setShouldAutoplay:false];
	[moviePlayer setControlStyle:MPMovieControlStyleNone];
	[[moviePlayer view] setUserInteractionEnabled:true];
	
	// We'll get notification when we know the movie size - set itto zero for now
	movieSize = CGSizeMake(0, 0);
	
    //	Add tap recognizer to bring up time controls
	// This is added to the transparent overlay view which goes above all drawing
	[self addTapRecognizerToView:overlayView];
	
	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:movieView WithType:RPC_VIDEO_VIEW_];
	
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
	// Check that we have the right movie loaded
	NSString *movie = [[self getVideoArchiveName] retain];
	if ( [movie compare:currentMovie] != NSOrderedSame )
	{
		[moviePlayer setContentURL:[NSURL fileURLWithPath:movie]];
		[currentMovie release];
		currentMovie = movie;
		[self getStartTime];
	}
	else
		[movie release];

	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
		
	// Position the movie player
	[[moviePlayer view] setFrame:[movieView bounds]];
	[movieView addSubview:[moviePlayer view]];
	[self.view bringSubviewToFront:overlayView];
	
	// Get notification when we know the movie size
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(movieSizeCallback:)
										  name:MPMovieNaturalSizeAvailableNotification
										  object:moviePlayer];
	
	// Set the play time
	float time_of_day = [[RacePadCoordinator Instance] currentTime];
	[self movieGotoTime:time_of_day];

	// Register the view
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_VIDEO_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:movieView];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:movieView];
	[[RacePadTitleBarController Instance] hide];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	[moviePlayer stop];
	[[moviePlayer view] removeFromSuperview];

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
    
	// Work out movie position
	CGRect movieViewBounds = [movieView bounds];
	CGSize  movieViewSize = movieViewBounds.size;
	
	if(movieViewSize.width < 1 || movieViewSize.height < 1 || movieSize.width < 1 || movieSize.height < 1)
		return;
	
	float wScale = movieViewSize.width / movieSize.width;
	float hScale = movieViewSize.height / movieSize.height;
	
	CGRect movieRect;
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
}

- (void) movieFinishedCallback:(NSNotification*) aNotification
{
	MPMoviePlayerController *player = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
	[player stop];
	[self.view removeFromSuperview];
	[player autorelease];    
}

- (void) RequestRedrawForType:(int)type
{
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
		[time_controller displayInViewController:self Animated:true];
	else
		[time_controller hide];
}

@end
