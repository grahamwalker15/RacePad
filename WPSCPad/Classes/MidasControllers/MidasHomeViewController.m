//
//  MidasHomeViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasHomeViewController.h"


#import "RacePadTitleBarController.h"
#import "RacePadCoordinator.h"
#import "RacePadSponsor.h"
#import "CommentaryBubble.h"

@implementation MidasHomeViewController

- (void)viewDidLoad
{
	// Set parameters for views	
	[backgroundView setStyle:BG_STYLE_MIDAS_];
	
	[super viewDidLoad];
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

- (void)viewWillAppear:(BOOL)animated
{
	// Register the view controller
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_LAP_COUNT_VIEW_];
		
	[[CommentaryBubble Instance] noBubbles];
	
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
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

/////////////////////////////////////////////////////////////////////////////////



-(IBAction)loadArchive
{
	[[RacePadCoordinator Instance] loadSession:@"09_11Mza" Session:@"Race"];
}

-(IBAction)loadLive
{
	[[RacePadCoordinator Instance] loadSession:@"09_11Mza" Session:@"Race"];
}

@end

