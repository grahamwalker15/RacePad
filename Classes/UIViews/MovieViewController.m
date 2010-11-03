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
	
	startTime = 13 * 3600.0 + 43 * 60.0 + 40;
	
    //	Add tap recognizer to bring up time controls
	// This is added to the transparent overlay view which goes above all drawing
	UIGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HandleTapFrom:)];
	[recognizer setCancelsTouchesInView:false];
	[overlayView addGestureRecognizer:recognizer];
    [recognizer release];
	
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
	[[moviePlayer view] setFrame:[movieView bounds]];
	[movieView addSubview:[moviePlayer view]];
	[self.view bringSubviewToFront:overlayView];
	
	float time_of_day = [[RacePadCoordinator Instance] currentTime];
	[self movieGotoTime:time_of_day];

	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_VIDEO_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:movieView];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:movieView];
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

- (void)HandleTapFrom:(UIGestureRecognizer *)gestureRecognizer
{
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
		[time_controller displayInViewController:self Animated:true];
	else
		[time_controller hide];
}

@end
