//
//  AlertViewController.m
//  MatchPad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AlertViewController.h"
#import "AlertData.h"
#import "MatchPadCoordinator.h"
#import "BasePadTimeController.h"
#import "MatchPadDatabase.h"

@implementation AlertViewController

@synthesize parentPopover;


 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
        // Custom initialization
		parentPopover = nil;
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[alertView SetHeading:false];
	
	// Add gesture recognizers
 	[self addTapRecognizerToView:alertView];
	[self addLongPressRecognizerToView:alertView];

}

- (void)viewWillAppear:(BOOL)animated
{
	[alertView SelectRow:-1];
	[super viewWillAppear:animated];
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

//////////////////////////////////////////////////////////////////////
//  Methods for this class

- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	int dataRow = [ alertView filteredRowToDataRow:row];
	AlertData * alertData = [[MatchPadDatabase Instance] alertData];
	float time = [[alertData itemAtIndex:dataRow] timeStamp];
	[[MatchPadCoordinator Instance] jumpToTime:time];
	[[BasePadTimeController Instance] updateClock:time];
	
	[alertView SelectRow:row];
	[alertView RequestRedraw];
	
	[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(dismissTimerExpired:) userInfo:nil repeats:NO];
	
	[[MatchPadCoordinator Instance] setPlaybackRate:1.0];
	[[MatchPadCoordinator Instance] prepareToPlay];
	[[MatchPadCoordinator Instance] startPlay];
	[[BasePadTimeController Instance] updatePlayButtons];
	
	return true;
}

- (void) dismissTimerExpired:(NSTimer *)theTimer
{
	if(parentPopover)
	{
		[parentPopover dismissPopoverAnimated:true];
	}
}

- (IBAction) closePressed:(id)sender
{
	if(parentPopover)
	{
		[parentPopover dismissPopoverAnimated:true];
	}
}

- (IBAction) typeChosen:(id)sender
{
	int v = typeChooser.selectedSegmentIndex;
	[alertView setFilter:v Player:[[BasePadCoordinator Instance]nameToFollow]];
	[alertView ResetScroll];
	[alertView RequestRedraw];
}

@end
