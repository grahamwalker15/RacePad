    //
//  TeamStatsViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 12/3/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "TeamStatsViewController.h"

@implementation TeamStatsViewController

- (void)viewDidLoad
{
	// Set parameters for display
	[alertView SetHeading:false];
	[alertView setStandardRowHeight:35];
	[alertView setCellYMargin:5];
	[alertView SetFont:DW_CONTROL_FONT_];
	[alertView setRowDivider:true];
	[alertView setAdaptableRowHeight:true];
	
	[alertView SetBackgroundAlpha:0.5];
	
	[alertView setDefaultTextColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
	[alertView setDefaultBackgroundColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	[alertView SetSelectedColour:[UIColor colorWithRed:0.8 green:0.8 blue:1.0 alpha:0.8]];
		
	// Add gesture recognizers to alert view - these will be sent to view itself and we will be notified as delegate
 	[alertView addTapRecognizer];
	[alertView addLongPressRecognizer];
	
	[super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
	[alertView SelectRow:-1];
	[super viewWillAppear:animated];
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

- (void) onDisplay
{
}

- (void) onHide
{
}


@end
