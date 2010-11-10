//
//  PitWindowViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "PitWindowViewController.h"
#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadTitleBarController.h"
#import "RacePadDatabase.h"
#import "PitWindowView.h"
#import "PitWindow.h"

@implementation PitWindowViewController

- (id)init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void)dealloc
{
    [super dealloc];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	pitWindowView = (PitWindowView *)[self drawingView];

	//  Add extra gesture recognizers
 
	[super viewDidLoad];
	[[RacePadCoordinator Instance] AddView:pitWindowView WithType:RPC_PIT_WINDOW_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[RacePadTitleBarController Instance] displayInViewController:self];
	
	// Register the views
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_PIT_WINDOW_VIEW_];
	[[RacePadCoordinator Instance] SetViewDisplayed:pitWindowView];

	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:pitWindowView];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
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
}

- (void) OnGestureTapAtX:(float)x Y:(float)y
{
	RacePadTimeController * time_controller = [RacePadTimeController Instance];
	
	if(![time_controller displayed])
		[time_controller displayInViewController:self Animated:true];
	else
		[time_controller hide];
}

@end
