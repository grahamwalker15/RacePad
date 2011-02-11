//
//  InfoViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 2/8/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "InfoViewController.h"
#import "RacePadTitleBarController.h"
#import "RacePadCoordinator.h"


@implementation InfoViewController

- (void)viewDidLoad
{
	// Set parameters for views
	//[backgroundView setStyle:BG_STYLE_FULL_SCREEN_GREY_];
	
	// Create the child view controllers
	
	htmlController = [[HTMLViewController alloc] initWithNibName:@"HTMLView" bundle:nil];
	driversController = [[InfoDriversController alloc] initWithNibName:@"InfoDrivers" bundle:nil];
	partnersController = [[InfoPartnersController alloc] initWithNibName:@"InfoPartners" bundle:nil];
	
	childControllerDisplayed = false;
	childControllerClosing = false;
	childController = nil;

	
	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	if(!childControllerClosing)
	{
		// Grab the title bar
		[[RacePadTitleBarController Instance] displayInViewController:self];
			
		// Register the view controller
		[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_LAP_COUNT_VIEW_];
		
		// We disable the screen locking - because that seems to close the socket
		[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
	}
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	if(childControllerDisplayed)
	{
		childControllerClosing = true; // This prevents the resultant viewWillAppear from registering everything
		[self hideChildController:false];
	}
	
	[[RacePadCoordinator Instance] ReleaseViewController:self];
	
	// re-enable the screen locking
	[[UIApplication sharedApplication] setIdleTimerDisabled:NO];
	
	childControllerClosing = false;
	childController = nil;

}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload
{
	[htmlController release];
	[driversController release];
	[partnersController release];
	
	childController = nil;
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	if(childControllerDisplayed)
		[childController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	if(childControllerDisplayed)
		[childController didRotateFromInterfaceOrientation:fromInterfaceOrientation];
	
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


- (IBAction) buttonPressed:(id)sender;
{
	if( sender == driversButton )
	{
		[self showChildController:driversController];
	}
	else if( sender == teamsButton )
	{
		[htmlController setHtmlFile:@"teams.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == circuitsButton )
	{
		[htmlController setHtmlFile:@"circuits.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == standingsButton )
	{
		[htmlController setHtmlFile:@"standings.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == rulesButton )
	{
		[htmlController setHtmlFile:@"rules.htm"];
		[self showChildController:htmlController];
	}
	else if( sender == partnersButton )
	{
		[self showChildController:partnersController];
	}
	else
	{
		[htmlController setHtmlFile:@"home.htm"];
		[self showChildController:htmlController];
	}
}

- (void)showChildController:(InfoChildController *)controller;
{
	if(controller)
	{
		// Set the style for its presentation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationCurrentContext];
		
		// And present it
		[self presentModalViewController:controller animated:true];
		childControllerDisplayed = true;
		childController = controller;
	}
}

- (void)hideChildController:(bool)animated
{
	if(childControllerDisplayed)
	{
		// Set the style for its animation
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		
		// And dismiss it
		[self dismissModalViewControllerAnimated:animated];
		childControllerDisplayed = false;
		childController = nil;
	}
}

@end
