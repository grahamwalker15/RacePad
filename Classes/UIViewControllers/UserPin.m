//
//  UserPin.m
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserPin.h"
#import "RacePadCoordinator.h"
#import "RacePadPrefs.h"
#import "RacePadAppDelegate.h"
#import "GameViewController.h"

@implementation UserPin

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
		changingPin = false;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
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
	[pin release];
	[cancel release];

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	changingPin = true;
	[pin setText:@""];
	changingPin = false;
}

-(void) cancelPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
	[gameController pinFailed];
}

-(void) digitPressed:(id)sender
{
	NSString *text = pin.text;
	if ( text.length < 4 )
	{
		UIButton *button = sender;
		
		text = [text stringByAppendingString: button.titleLabel.text];
		[pin setText:text];
		if ( [text intValue] == userPin )
		{
			[self dismissModalViewControllerAnimated:YES];
			[gameController pinCorrect];
		}
	}
}

-(void) deletePressed:(id)sender
{
	NSString *text = pin.text;
	if ( text.length > 0 )
	{
		text = [text substringToIndex:text.length - 1];
		[pin setText:text];
	}
}

- (void) getPin: (int)inPin Controller: (GameViewController *)controller
{
	userPin = inPin;
	gameController = controller;
	[gameController presentModalViewController:self animated:YES];
}

@end
