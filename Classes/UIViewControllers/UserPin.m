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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
		[self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		[self setModalPresentationStyle:UIModalPresentationFormSheet];
		changingPin = false;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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
}


- (void)dealloc {
	[pin release];
	[cancel release];

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	changingPin = true;
	[pin setText:@""];
	changingPin = false;
	[pin becomeFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ( [pin.text intValue] == userPin )
	{
		[pin resignFirstResponder];
		[self dismissModalViewControllerAnimated:YES];
		[gameController pinCorrect];
		return YES;
	}
	changingPin = true;
	[pin setText:@""];
	changingPin = false;
	return NO;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	int newLength = pin.text.length - range.length + string.length;
	if ( newLength > 4 )
		return NO;
	
	for ( int i = 0; i < string.length; i++ )
	{
		unichar ch = [string characterAtIndex:i];
		if ( ch < '0' || ch > '9' )
			return NO;
	}
	return YES;
}

-(void) cancelPressed:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
	[gameController pinFailed];
}

- (void) getPin: (int)inPin Controller: (GameViewController *)controller
{
	userPin = inPin;
	gameController = controller;
	[gameController presentModalViewController:self animated:YES];
}

@end
