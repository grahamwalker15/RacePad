    //
//  DriverListController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DriverListController.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "TableData.h"


@implementation DriverListController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	driver_list_view_ = (TableDataView *)[self view];
	
	[driver_list_view_ SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	
	[driver_list_view_ SetRowHeight:30];
	[driver_list_view_ SetHeading:true];
	
    [super viewDidLoad];
	
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_DRIVER_LIST_VIEW_];
}

- (void)RequestRedraw
{
	[driver_list_view_ RequestRedraw];
}

- (void)viewWillAppear:(BOOL)animated;    // Called when the view is about to made visible. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewDisplayed:self];
}

- (void)viewWillDisappear:(BOOL)animated; // Called when the view is dismissed, covered or otherwise hidden. Default does nothing
{
	[[RacePadCoordinator Instance] SetViewHidden:self];
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

	[[RacePadCoordinator Instance] RemoveView:self];
}


- (void)dealloc
{
    [super dealloc];
}


@end

