    //
//  HomeViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 5/9/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import "HomeViewController.h"

#import "RacePadTitleBarController.h"
#import "RacePadCoordinator.h"
#import "RacePadSponsor.h"
#import "CommentaryBubble.h"

@implementation HomeViewController

- (void)viewDidLoad
{
	// Set parameters for views	
	[backgroundView setStyle:BG_STYLE_FULL_SCREEN_CARBON_];
	
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
	[[RacePadTitleBarController Instance] displayInViewController:self SupportCommentary:false];
		
	// Register the view controller
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:RPC_LAP_COUNT_VIEW_];
	
	[self updateButtons];
		
	[[CommentaryBubble Instance] noBubbles];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] ReleaseViewController:self];
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
	int tabCount = [[RacePadCoordinator Instance] tabCount];
	
	[button1 setHidden:(tabCount <= 1)];
	[button2 setHidden:(tabCount <= 2)];
	[button3 setHidden:(tabCount <= 3)];
	[button4 setHidden:(tabCount <= 4)];
	[button5 setHidden:(tabCount <= 5)];
	[button6 setHidden:(tabCount <= 6)];
	[button7 setHidden:(tabCount <= 7)];
	
	[button1  setTitle:[[RacePadCoordinator Instance] tabTitle:1] forState:UIControlStateNormal];
	[button2  setTitle:[[RacePadCoordinator Instance] tabTitle:2] forState:UIControlStateNormal];
	[button3  setTitle:[[RacePadCoordinator Instance] tabTitle:3] forState:UIControlStateNormal];
	[button4  setTitle:[[RacePadCoordinator Instance] tabTitle:4] forState:UIControlStateNormal];
	[button5  setTitle:[[RacePadCoordinator Instance] tabTitle:5] forState:UIControlStateNormal];
	[button6  setTitle:[[RacePadCoordinator Instance] tabTitle:6] forState:UIControlStateNormal];
	[button7  setTitle:[[RacePadCoordinator Instance] tabTitle:7] forState:UIControlStateNormal];

	[button1 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button2 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button3 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button4 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button5 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button6 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[button7 setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];

    [button1 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button3 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button4 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button5 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button6 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [button7 setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    
    // highlight in Petronas colour
    [button1 setTitleColor:[UIColor colorWithRed:3.0/255.0 green:168.0/255.0 blue:146.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [button2 setTitleColor:[UIColor colorWithRed:3.0/255.0 green:168.0/255.0 blue:146.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [button3 setTitleColor:[UIColor colorWithRed:3.0/255.0 green:168.0/255.0 blue:146.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [button4 setTitleColor:[UIColor colorWithRed:3.0/255.0 green:168.0/255.0 blue:146.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [button5 setTitleColor:[UIColor colorWithRed:3.0/255.0 green:168.0/255.0 blue:146.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [button6 setTitleColor:[UIColor colorWithRed:3.0/255.0 green:168.0/255.0 blue:146.0/255.0 alpha:1] forState:UIControlStateHighlighted];
    [button7 setTitleColor:[UIColor colorWithRed:3.0/255.0 green:168.0/255.0 blue:146.0/255.0 alpha:1] forState:UIControlStateHighlighted];

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
		[[RacePadCoordinator Instance] selectTab:tabSelected];
}

@end
