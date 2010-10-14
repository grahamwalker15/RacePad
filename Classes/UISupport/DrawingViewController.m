//
//  DrawingViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrawingViewController.h"


@implementation DrawingViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	// Make the view aware of orientation changes.
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(OrientationChange:) name:@"UIDeviceOrientationDidChangeNotification"  object:nil];
	
    [super viewDidLoad];
}

- (void)dealloc
{
    [super dealloc];
}

// Action callbacks

// orientation view swapping logic
- (void) OrientationChange:(NSNotification *)notification
{
	[self.view setNeedsLayout];
	[self.view setNeedsDisplay];
}

- (IBAction) OnTouchDownX:(float)x Y:(float)y
{
}

- (IBAction) OnTouchUpX:(float)x Y:(float)y
{
}

- (IBAction) OnTouchMoveX:(float)x Y:(float)y
{
}

- (IBAction) OnTouchCancelledX:(float)x Y:(float)y
{
}


@end
