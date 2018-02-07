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
	[super viewDidLoad];

	// Set parameters for views
	//[backgroundView setStyle:BG_STYLE_FULL_SCREEN_CARBON_];
	
	// Create the child view controllers
	
	htmlController = [[HTMLViewController alloc] initWithNibName:@"HTMLView" bundle:nil];
	driversController = [[InfoDriversController alloc] initWithNibName:@"InfoDrivers" bundle:nil];
	teamsController = [[InfoTeamsController alloc] initWithNibName:@"InfoTeams" bundle:nil];
	standingsController = [[InfoStandingsController alloc] initWithNibName:@"InfoStandings" bundle:nil];
	rulesController = [[InfoRulesController alloc] initWithNibName:@"InfoRules" bundle:nil];
	partnersController = [[InfoPartnersController alloc] initWithNibName:@"InfoPartners" bundle:nil];
	
	childControllerDisplayed = false;
	childControllerClosing = false;
	childController = nil;

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
		[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary:false];
			
		// Register the view controller
		[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_LAP_COUNT_VIEW_];
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
	// Get LocalHTML folder
	 NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	 NSString *docsFolder = [paths objectAtIndex:0];
	 NSString *folder = [docsFolder stringByAppendingPathComponent:@"LocalHTML"];

	if( sender == driversButton )
	{
		[self showChildController:driversController];
	}
	else if( sender == teamsButton )
	{
		[self showChildController:teamsController];
	}
	else if( sender == circuitsButton )
	{
		[self showChildController:driversController];
	}
	else if( sender == standingsButton )
	{
		[standingsController setHtmlFile:nil];
		[self showChildController:standingsController];
	}
	else if( sender == rulesButton )
	{
		[rulesController setHtmlFile:nil];
		[self showChildController:rulesController];
	}
	else if( sender == partnersButton )
	{
		[partnersController setHtmlFile:nil];
		[self showChildController:partnersController];
	}
	else
	{
		NSString *fileName = [folder stringByAppendingPathComponent:@"home.htm"];
		[htmlController setHtmlFile:fileName];
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
