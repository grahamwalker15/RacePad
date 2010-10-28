    //
//  MovieViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieViewController.h"


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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	NSString *url = [[NSBundle mainBundle] pathForResource:@"Movie on 2010-10-04 at 16.26" ofType:@"mov"];
	
	MPMoviePlayerViewController *playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:url]];
    
	[super presentMoviePlayerViewControllerAnimated:playerViewController];
	
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



- (void) movieFinishedCallback:(NSNotification*) aNotification
{
	MPMoviePlayerController *player = [aNotification object];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
	[player stop];
	[self.view removeFromSuperview];
	[player autorelease];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
