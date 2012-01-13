//
//  MidasCircuitViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/7/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasCircuitViewController.h"
#import "MidasPopupManager.h"

#import "RacePadCoordinator.h"

@implementation MidasCircuitViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[trackMapView setIsZoomView:false];
	[trackMapView setIsOverlayView:true];
	[trackMapView setSmallSized:true];
	
	[[RacePadCoordinator Instance] AddView:trackMapView WithType:RPC_TRACK_MAP_VIEW_];
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

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	if(gestureView == heading)
	{
		[[MidasCircuitViewManager Instance] hideAnimated:true Notify:true];
	}
}

- (void) onDisplay
{
	[[RacePadCoordinator Instance] SetViewDisplayed:trackMapView];
}

- (void) onHide
{
	[[RacePadCoordinator Instance] SetViewHidden:trackMapView];
}


@end
