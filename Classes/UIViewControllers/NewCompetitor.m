//
//  NewCompetitor.m
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NewCompetitor.h"
#import "GameViewController.h"
#import "RacePadCoordinator.h"
#import "BasePadPrefs.h"
#import "RacePadAppDelegate.h"
#import "RacePrediction.h"
#import "RacePadDatabase.h"

@implementation NewCompetitor

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
        // Custom initialization
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
		alreadyBad = false;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	[whirl setHidesWhenStopped:YES];
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
}


- (void)dealloc
{
	[status release];
	[name release];
	[whirl release];
	[cancel release];

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	if ( alreadyBad )
		[status setText:@"User is already registered. Please select a new name."];
	else
		[status setText:@"Please enter a new user name."];
	[name setText:@""];
	[whirl stopAnimating];
	[name becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[status setText:@"Checking"];
	[whirl startAnimating];
	RacePrediction *p = [[RacePadDatabase Instance] racePrediction]; 
	if ( p.gameStatus == GS_NOT_STARTED )
	{
		NSString *user = name.text;
		if ( [gameController validName:user] )
		{
			[p setUser:user];
			[[RacePadCoordinator Instance]checkUserName:user];
			return YES;
		}
	}
	return NO;
}

-(void) cancelPressed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[gameController cancelledRegister];
}

-(void) badUser
{
	[whirl stopAnimating];
	[status setText:@"User is already registered. Please select a new name."];
}

- (void) getUser: (GameViewController *)controller AlreadyBad: (bool) b
{
	alreadyBad = b;
	gameController = controller;
	[gameController presentViewController:self animated:YES completion:nil];
}

@end
