//
//  MidasStandingsViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MidasStandingsViewController.h"
#import "MidasPopupManager.h"

#import "RacePadDatabase.h"
#import "RacePadCoordinator.h"
#import "BasePadMedia.h"

#import "MidasVideoViewController.h"


@implementation MidasStandingsViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	// Set up the table data for SimpleListView
	[standingsView SetTableDataClass:[[RacePadDatabase Instance] midasStandingsData]];
	
	[standingsView setParentController:self];
	[standingsView setExpansionView:expansionView];
	
	[standingsView SetFont:DW_LIGHT_LARGER_CONTROL_FONT_];
	[standingsView setStandardRowHeight:26];
	[standingsView setExpansionRowHeight:CGRectGetHeight(expansionView.bounds)];
	[standingsView setExpansionAllowed:true];
	[standingsView SetHeading:false];
	[standingsView SetBackgroundAlpha:0.0];
	[standingsView setRowDivider:true];
	[standingsView setCellYMargin:3];
	
	[expansionView setHidden:true];
	[standingsView addSubview:expansionView];
	
	// Add gesture recognizers
 	[self addTapRecognizerToView:standingsView];
	[self addDoubleTapRecognizerToView:standingsView];
	
	// Tell the RacePadCoordinator that we're interested in data for this view
	[[RacePadCoordinator Instance] AddView:standingsView WithType:RPC_MIDAS_STANDINGS_VIEW_];
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
		[[MidasStandingsManager Instance] hideAnimated:true Notify:true];
	}
	else if(gestureView == standingsView)
	{
		int row, col;
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool wasExpanded = [standingsView RowExpanded:row];
			
			[standingsView UnexpandAllRows];
			[expansionView setHidden:true];
			[standingsView setExpandedDriver:nil];
			
			if(!wasExpanded)
			{
				[standingsView SetRow:row Expanded:true];
				[standingsView setExpandedDriver:[standingsView GetRowTag:row]];	// Driver name
				[self fillExpansionViewForRow:row];
				[self placeExpansionViewAtRow:row];
			}
		}
		
		[standingsView RequestRedraw];
	}
}

- (void) OnDoubleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{	
	[self OnTapGestureInView:gestureView AtX:x Y:y];
}

- (void) onDisplay
{
	[[RacePadCoordinator Instance] SetViewDisplayed:standingsView];
}

- (void) onHide
{
	[[RacePadCoordinator Instance] SetViewHidden:standingsView];
}

-(IBAction)movieSelected:(id)sender
{
	BasePadViewController * parentViewController = [[MidasStandingsManager Instance] parentViewController];
	
	if(parentViewController && [parentViewController isKindOfClass:[MidasVideoViewController class]])
	{
		MidasVideoViewController * videoViewController = (MidasVideoViewController *) parentViewController;
		
		BasePadVideoSource * videoSource = [[BasePadMedia Instance] findMovieSourceByTag:[standingsView expandedDriver]];

		if(videoSource)
		{
			MovieView * movieView = [videoViewController findFreeMovieView];
			if(movieView)
			{
				[videoViewController displayMovieSource:videoSource InView:movieView];
				[videoViewController animateMovieViews];
			}
		}
	}
}

- (void) placeExpansionViewAtRow:(int)row
{
	float y = [standingsView TableHeightToRow:row - 1] + [standingsView ContentRowHeight:row];
	[expansionView setFrame:CGRectMake(0, y, CGRectGetWidth(expansionView.bounds), CGRectGetHeight(expansionView.bounds))];
	[expansionView setHidden:false];
}

- (void) fillExpansionViewForRow:(int)row
{
	[teamName setText:[standingsView GetCellTextAtRow:row Col:4]];
	
	BasePadVideoSource * videoSource = [[BasePadMedia Instance] findMovieSourceByTag:[standingsView expandedDriver]];
	if(videoSource && [videoSource movieThumbnail])
	{
		[onboardVideoButton setBackgroundImage:[videoSource movieThumbnail] forState:UIControlStateNormal];
	}
	else
	{
		[onboardVideoButton setBackgroundImage:[UIImage imageNamed:@"preview-video-layer.png"] forState:UIControlStateNormal];
	}

	/*
	nationalityFlag;
	votesForCount;
	votesAgainstCount;
	ratingLabel;
	 */
}

@end

@implementation MidasStandingsView

@synthesize parentController;
@synthesize expansionView;
@synthesize expandedDriver;

- (void)dealloc
{
	[expandedDriver release];
	[super dealloc];
}
				 
- (void) Draw:(CGRect)region
{
	// Check that the expanded driver is still at the expanded row
	if(expandedDriver)
	{
		for(int row = 0 ; row < [self RowCount] ; row++)
		{
			NSString * driverAtRow = [self GetRowTag:row];
			if([expandedDriver compare:driverAtRow] == NSOrderedSame)
			{
				if(![self RowExpanded:row])
				{
					[self UnexpandAllRows];
					[self SetRow:row Expanded:true];
					if(parentController)
					{
						[parentController placeExpansionViewAtRow:row];
					}
					break;
				}
			}
		}
	}
	
	// And now we can draw
	[super Draw:region];
}

- (int) ContentRowHeight:(int)row
{
	if(row == 0)
		return standardRowHeight * 1.5;
	else
		return standardRowHeight;
}

- (NSString *) GetRowTag:(int)row
{
	return [self GetCellTextAtRow:row Col:5];	// The abbreviated driver name
}

- (int) GetFontAtRow:(int)row Col:(int)col
{
	if(row == 0)
	{
		if(col == 0)
			return DW_ITALIC_BIG_FONT_;
		else
			return DW_REGULAR_FONT_;
	}
	else
	{
		if(col == 0)
			return DW_ITALIC_LARGER_CONTROL_FONT_;
		else
			return DW_LIGHT_LARGER_CONTROL_FONT_;
	}
}

@end

@implementation MidasStandingsExpansionView
@end



