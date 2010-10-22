//
//  TrackMapViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/1/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TrackMapViewController.h"
#import "RacePadCoordinator.h"
#import "RacePadDatabase.h"
#import "TableDataView.h"
#import "TrackMapView.h"

@implementation TrackMapViewController

- (id)init
{
	if(self = [super init])
	{
	}
	
	return self;
}

- (void)RequestRedraw
{
	[track_map_view_ RequestRedraw];
	//[timing_view_ RequestRedraw];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	track_map_view_ = (TrackMapView *)[self view];

 	//[timing_view_ SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	//[timing_view_ SetRowHeight:28];
	//[timing_view_ SetHeading:true];
	
	[super viewDidLoad];
	[[RacePadCoordinator Instance] AddView:self WithType:RPC_TRACK_MAP_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidAppear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewDisplayed:self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:self];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/*
- (void)viewDidUnload
{	
}
 */


- (void)dealloc
{
    [super dealloc];
}

@end
