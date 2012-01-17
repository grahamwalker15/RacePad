    //
//  MidasAlertsViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/9/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasAlertsViewController.h"
#import "MidasPopupManager.h"
#import "AlertData.h"
#import "RacePadCoordinator.h"
#import "BasePadTimeController.h"
#import "RacePadDatabase.h"


@implementation MidasAlertsViewController

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[alertView SetHeading:false];
	[alertView setStandardRowHeight:20];
	[alertView SetFont:DW_CONTROL_FONT_];
	[alertView setDefaultTextColour:[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0]];
	[alertView setDefaultBackgroundColour:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:0.5]];
	[alertView SetBackgroundAlpha:0.75];
	[alertView setRowDivider:true];
	
	// Add gesture recognizers
 	[self addTapRecognizerToView:alertView];
	[self addDoubleTapRecognizerToView:alertView];
	
}

- (void)viewWillAppear:(BOOL)animated
{
	[alertView SelectRow:-1];
	[self UpdateList];
	[super viewWillAppear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Overriden to allow any orientation.
    return NO;
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
	AlertData * alertData = [[RacePadDatabase Instance] alertData];
	float time = [[alertData itemAtIndex:dataRow] timeStamp];
	[[RacePadCoordinator Instance] jumpToTime:time];
	[[BasePadTimeController Instance] updateClock:time];
	
	[alertView SelectRow:row];
	[alertView RequestRedraw];
	
	[NSTimer scheduledTimerWithTimeInterval:0.4 target:self selector:@selector(dismissTimerExpired:) userInfo:nil repeats:NO];
	
	[[RacePadCoordinator Instance] setPlaybackRate:1.0];
	[[RacePadCoordinator Instance] prepareToPlay];
	[[RacePadCoordinator Instance] startPlay];
	[[BasePadTimeController Instance] updatePlayButtons];
	
	return true;
}

- (void) dismissTimerExpired:(NSTimer *)theTimer
{
	[[MidasAlertsManager Instance] hideAnimated:true Notify:true];
}

- (void) UpdateList
{
	int v = typeChooser.selectedSegmentIndex;
	[alertView setFilter:v Driver:[[BasePadCoordinator Instance]nameToFollow]];
	[alertView ResetScroll];
	[alertView RequestRedraw];
}

- (IBAction) typeChosen:(id)sender
{
	[self UpdateList];
}

// Action callbacks

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	int row = -1;
	int col = -1;
	
	if(gestureView && [gestureView isKindOfClass:[SimpleListView class]])
	{
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(!if_heading || row > 0)
			{
				if(if_heading)
					row --;
				
				[self HandleSelectRow:row DoubleClick:false LongPress:false];
			}
		}
	}
	else 
	{
		[super OnTapGestureInView:gestureView AtX:x Y:y];
	}	
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	int row = -1;
	int col = -1;
	
	if(gestureView && [gestureView isKindOfClass:[SimpleListView class]])
	{
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(!if_heading || row > 0)
			{
				if(if_heading)
					row --;
				
				[self HandleSelectRow:row DoubleClick:true LongPress:false];
			}
		}
	}
	else 
	{
		[super OnDoubleTapGestureInView:gestureView AtX:x Y:y];
	}
}

- (void) OnLongPressGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	int row = -1;
	int col = -1;
	
	if(gestureView && [gestureView isKindOfClass:[SimpleListView class]])
	{
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(!if_heading || row > 0)
			{
				if(if_heading)
					row --;
				
				[self HandleSelectRow:row DoubleClick:false LongPress:true];
			}
		}
	}
	else 
	{
		[super OnLongPressGestureInView:gestureView AtX:x Y:y];
	}
}

@end

@implementation MidasAlertsView

- (int) ColumnWidth:(int)col;
{
	switch (col)
	{
		case 0:
			return 20;
		case 1:
			return 30;
		case 2:
			return 250;
		case 3:
			return 0;
		case 4:
			return 0;
		default:
			return 0;
	}
}


@end
