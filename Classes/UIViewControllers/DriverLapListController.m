    //
//  DriverLapListController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/24/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverLapListController.h"

#import "TableDataView.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "TableData.h"

@implementation DriverLapListController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
		 // This view is always displayed as a subview
		 // Set the style for its presentation
		 [self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		 [self setModalPresentationStyle:UIModalPresentationCurrentContext];
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
 	// Set up the table data for SimpleListView
	[lap_list_view_ SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	
	[lap_list_view_ SetRowHeight:28];
	[lap_list_view_ SetHeading:true];
		
	[super viewDidLoad];
	
	// Tell the RacePadCoordinator that we will be interested in data for this view
	[[RacePadCoordinator Instance] AddView:lap_list_view_ WithType:RPC_DRIVER_LIST_VIEW_];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewDisplayed:lap_list_view_];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:lap_list_view_];
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


////////////////////////////////////////////////////////////////////////////////

- (IBAction)BackButton:(id)sender
{
	[[self parentViewController] HideDriverLapList];
}

- (IBAction)PreviousButton:(id)sender
{
	[[self parentViewController] HideDriverLapList];
}

- (IBAction)NextButton:(id)sender
{
	[[self parentViewController] HideDriverLapList];
}

@end
