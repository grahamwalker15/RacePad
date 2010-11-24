    //
//  AlertViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 11/10/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AlertViewController.h"
#import "AlertData.h"
#import "RacePadCoordinator.h"
#import "RacePadTimeController.h"
#import "RacePadDatabase.h"

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


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[alertView SetHeading:false];
	
	// Add gesture recognizers
 	[self addTapRecognizerToView:alertView];
	[self addDoubleTapRecognizerToView:alertView];
	[self addLongPressRecognizerToView:alertView];
	
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

//////////////////////////////////////////////////////////////////////
//  Methods for this class

- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	float time = [[alertData itemAtIndex:row] timeStamp];
	[[RacePadCoordinator Instance] jumpToTime:time];
	[[RacePadTimeController Instance] updateClock:time];
	
	if(parentPopover)
	{
		[parentPopover dismissPopoverAnimated:true];
	}
	
	[[RacePadCoordinator Instance] prepareToPlay];
	[[RacePadCoordinator Instance] startPlay];
	[[RacePadTimeController Instance] updatePlayButton];
	
	return true;
}

- (IBAction) closePressed:(id)sender
{
	if(parentPopover)
	{
		[parentPopover dismissPopoverAnimated:true];
	}
}

@end
