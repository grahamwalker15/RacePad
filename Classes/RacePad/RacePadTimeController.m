//
//  RacePadTimeController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/25/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadTimeController.h"
#import "TimeViewController.h"

@implementation RacePadTimeController

static RacePadTimeController * instance_ = nil;

+(RacePadTimeController *)Instance
{
	if(!instance_)
		instance_ = [[RacePadTimeController alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{	
		timeController = [[TimeViewController alloc] initWithNibName:@"TimeControlView" bundle:nil];
	}
	
	return self;
}


- (void)dealloc
{
	[timeController release];
    [super dealloc];
}

//////////////////////////////////////////////////////////////////////////////////////////

- (void) onStartUp
{
}

- (void) displayInViewController:(UIViewController *)viewController
{
	//[viewController presentModalViewController:timeController animated:true];

	CGRect super_bounds = [viewController.view bounds];
	CGRect time_controller_bounds = [timeController.view bounds];
	
	CGRect frame = CGRectMake(super_bounds.origin.x, super_bounds.origin.y + super_bounds.size.height - time_controller_bounds.size.height, super_bounds.size.width, time_controller_bounds.size.height);
	[timeController.view setFrame:frame];

	UIBarButtonItem *  test_button = [timeController testButton];

	[viewController.view addSubview:timeController.view];
	
	[[timeController testButton] setTarget:instance_];
	[[timeController testButton] setAction:@selector(TestPressed:)];
		
	/*
	// Set the style for its presentation
	[viewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[viewController setModalPresentationStyle:UIModalPresentationCurrentContext];
		
	// And display it
	[viewController presentModalViewController:timeController animated:true];
	 */
}

- (void) hide
{
	[timeController.view removeFromSuperview];
}

- (IBAction)TestPressed:(id)sender
{
	int x = 0;
}

@end
