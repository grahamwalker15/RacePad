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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	track_map_view_ = (TrackMapView *)[self view];

 	//[timing_view_ SetTableDataClass:[[RacePadDatabase Instance] driverListData]];
	//[timing_view_ SetRowHeight:28];
	//[timing_view_ SetHeading:true];
	
	[super viewDidLoad];
	[[RacePadCoordinator Instance] AddView:track_map_view_ WithType:RPC_TRACK_MAP_VIEW_];
	//[[RacePadCoordinator Instance] AddView:timing_view_ WithType:RPC_DRIVER_LIST_VIEW_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillAppear:(BOOL)animated
{
	[[RacePadCoordinator Instance] RegisterViewController:self];
	[[RacePadCoordinator Instance] SetViewDisplayed:track_map_view_];
	//[[RacePadCoordinator Instance] SetViewDisplayed:timing_view_];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewWillDisappear:(BOOL)animated
{
	[[RacePadCoordinator Instance] SetViewHidden:track_map_view_];
	//[[RacePadCoordinator Instance] SetViewHidden:timing_view_];
	
	[track_map_view_ ReleaseBackground];
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


- (void)viewDidUnload
{	
    [super viewDidUnload];
}



- (void)dealloc
{
    [super dealloc];
}

@end
