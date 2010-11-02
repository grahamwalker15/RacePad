    //
//  RacePadViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/29/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RacePadViewController.h"


@implementation RacePadViewController

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
	[super didReceiveMemoryWarning];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
}


- (void)dealloc
{
    [super dealloc];
}

- (UIView *) baseView
{
	return [self view];
}

- (void) RequestRedrawForType:(int)type
{
}


@end
