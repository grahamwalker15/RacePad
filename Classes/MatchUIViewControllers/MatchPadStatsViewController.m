//
//  MatchPadStatsViewController.m
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MatchPadStatsViewController.h"
#import "BasePadPopupManager.h"

#import "MatchPadCoordinator.h"
#import "BasePadMedia.h"

#import "MatchPadVideoViewController.h"

@implementation MatchPadStatsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
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
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	[super OnTapGestureInView:gestureView AtX:x Y:y];
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	[self OnTapGestureInView:gestureView AtX:x Y:y];
}

- (void) onDisplay
{
}

- (void) onHide
{
}

-(IBAction)buttonSelected:(id)sender
{
}

@end

