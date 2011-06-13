    //
//  HomeViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 5/9/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "HomeViewController.h"

#import "MatchPadTitleBarController.h"
#import "MatchPadCoordinator.h"
#import "MatchPadSponsor.h"

@implementation HomeViewController

- (void)viewDidLoad
{
	// Set parameters for views	
	
	[super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	// Grab the title bar
	[[MatchPadTitleBarController Instance] displayInViewController:self];
		
	// Register the view controller
	[[MatchPadCoordinator Instance] RegisterViewController:self WithTypeMask:0];
	
	[self updateButtons];
		
	// We disable the screen locking - because that seems to close the socket
	[[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[MatchPadCoordinator Instance] ReleaseViewController:self];
	
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

- (void) updateButtons
{
	int tabCount = [[MatchPadCoordinator Instance] tabCount];
	
	[button1 setHidden:(tabCount <= 1)];
	[button2 setHidden:(tabCount <= 2)];
	[button3 setHidden:(tabCount <= 3)];
	[button4 setHidden:(tabCount <= 4)];
	[button5 setHidden:(tabCount <= 5)];
	[button6 setHidden:(tabCount <= 6)];
	[button7 setHidden:(tabCount <= 7)];
	
	[button1  setTitle:[[MatchPadCoordinator Instance] tabTitle:1] forState:UIControlStateNormal];
	[button2  setTitle:[[MatchPadCoordinator Instance] tabTitle:2] forState:UIControlStateNormal];
	[button3  setTitle:[[MatchPadCoordinator Instance] tabTitle:3] forState:UIControlStateNormal];
	[button4  setTitle:[[MatchPadCoordinator Instance] tabTitle:4] forState:UIControlStateNormal];
	[button5  setTitle:[[MatchPadCoordinator Instance] tabTitle:5] forState:UIControlStateNormal];
	[button6  setTitle:[[MatchPadCoordinator Instance] tabTitle:6] forState:UIControlStateNormal];
	[button7  setTitle:[[MatchPadCoordinator Instance] tabTitle:7] forState:UIControlStateNormal];

	[button1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button3 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button4 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button5 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button6 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button7 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
}

- (IBAction) buttonPressed:(id)sender
{	
	int tabSelected = -1;
	
	if( sender == button1 )
	{
		tabSelected = 1;
	}
	else if( sender == button2 )
	{
		tabSelected = 2;
	}
	else if( sender == button3 )
	{
		tabSelected = 3;
	}
	else if( sender == button4 )
	{
		tabSelected = 4;
	}
	else if( sender == button5 )
	{
		tabSelected = 5;
	}
	else if( sender == button6 )
	{
		tabSelected = 6;
	}
	else if( sender == button7 )
	{
		tabSelected = 7;
	}

	if(tabSelected >= 0)
		[[MatchPadCoordinator Instance] selectTab:tabSelected];
}

@end
