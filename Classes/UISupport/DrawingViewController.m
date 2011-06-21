//
//  DrawingViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DrawingViewController.h"

@implementation DrawingViewController

@synthesize drawingView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];

	[self addTapRecognizerToView:drawingView];
	[self addDoubleTapRecognizerToView:drawingView];
	[self addLongPressRecognizerToView:drawingView];
}

- (void)dealloc
{
    [super dealloc];
}

@end
