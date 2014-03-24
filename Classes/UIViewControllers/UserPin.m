//
//  UserPin.m
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "UserPin.h"
#import "RacePadCoordinator.h"
#import "BasePadPrefs.h"
#import "RacePadAppDelegate.h"
#import "GameViewController.h"

@implementation UserPin

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
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
	[pin1 release];
	[pin2 release];
	[pin3 release];
	[pin4 release];
	[cancel release];

    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	changingPin = true;
	[pin1 setText:@""];
	[pin2 setText:@""];
	[pin3 setText:@""];
	[pin4 setText:@""];
	[titleButton.titleLabel setText:@"Enter Pin"];
	[titleButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
	changingPin = false;
	wrongPinEntered = false;
}

-(void) cancelPressed:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
	[gameController pinFailed];
}

-(void) digitPressed:(id)sender
{
	NSString *text1 = pin1.text;
	NSString *text2 = pin2.text;
	NSString *text3 = pin3.text;
	NSString *text4 = pin4.text;
	
	// Find next button
	UITextField * nextButton = nil;
	if(text1.length < 1)
		nextButton = pin1;
	else if(text2.length < 1)
		nextButton = pin2;
	else if(text3.length < 1)
		nextButton = pin3;
	else if(text4.length < 1)
		nextButton = pin4;
	
	if ( nextButton )
	{
		UIButton *button = sender;
		
		[nextButton setText:button.titleLabel.text];
		
		if ( nextButton == pin4)
		{
			NSString *text = pin1.text;
			text = [text stringByAppendingString:pin2.text];
			text = [text stringByAppendingString:pin3.text];
			text = [text stringByAppendingString:pin4.text];
			if([text intValue] == userPin )
			{
				[self dismissViewControllerAnimated:YES completion:nil];
				[gameController pinCorrect];
			}
			else
			{
				[titleButton.titleLabel setText:@"Try again"];
				[titleButton setBackgroundColor:[UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:0.6]];
				[pin1 setText:@""];
				[pin2 setText:@""];
				[pin3 setText:@""];
				[pin4 setText:@""];
				wrongPinEntered = true;
			}
		}
		else if(wrongPinEntered)
		{
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.25];
			[titleButton.titleLabel setText:@"Enter Pin"];
			[titleButton setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0]];
			[UIView commitAnimations];
			wrongPinEntered = false;
		}
	}
}

-(void) deletePressed:(id)sender
{
	NSString *text1 = pin1.text;
	NSString *text2 = pin2.text;
	NSString *text3 = pin3.text;
	NSString *text4 = pin4.text;
	
	// Find last button
	UITextField * lastButton = nil;
	if(text4.length > 0)
		lastButton = pin4;
	else if(text3.length > 0)
		lastButton = pin3;
	else if(text2.length > 0)
		lastButton = pin2;
	else if(text1.length > 0)
		lastButton = pin1;
	
	if (lastButton)
	{
		[lastButton setText:@""];
	}
}

- (void) getPin: (int)inPin Controller: (GameViewController *)controller
{
	userPin = inPin;
	gameController = controller;
	[gameController presentViewController:self animated:YES completion:nil];
}

@end
