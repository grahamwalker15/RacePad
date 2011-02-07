    //
//  TimeViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/26/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TimeViewController.h"


@implementation TimeViewController

@synthesize toolbar;
@synthesize playButton;
@synthesize replayButton;
@synthesize timeSlider;
@synthesize clock;
@synthesize goLiveButton;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[goLiveButton setButtonColour:[UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1.0]];
	[goLiveButton setTextColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
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

@end
