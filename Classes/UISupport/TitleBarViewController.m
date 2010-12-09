    //
//  TitleBarController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/4/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TitleBarViewController.h"
#import "RacePadCoordinator.h"

@implementation TitleBarViewController

@synthesize sponsorButton;
@synthesize alertButton;
@synthesize eventName;
@synthesize clock;
@synthesize lapCounter;

 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad
 {
	 //Tell race pad co-ordinator that we'll be interested in updates
	 [[RacePadCoordinator Instance] AddView:self WithType:RPC_LAP_COUNT_VIEW_];

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
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
    [super dealloc];
}

- (void)RequestRedraw
{
	
}

@end
