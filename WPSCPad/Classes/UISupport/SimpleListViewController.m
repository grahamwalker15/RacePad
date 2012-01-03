    //
//  SimpleListViewController.m
//  RacePad
//
//  Created by Gareth Griffith on 10/21/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "SimpleListViewController.h"
#import "SimpleListView.h"


@implementation SimpleListViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/


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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{	
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)dealloc
{
    [super dealloc];
}

// Action callbacks

- (bool) HandleSelectHeading
{
	return false;
}

- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	return false;
}

- (bool) HandleSelectCol:(int)col
{
	return false;
}

- (bool) HandleSelectCellRow:(int)row Col:(int)col DoubleClick:(bool)double_click LongPress:(bool)long_press
{
	return false;
}

- (bool) HandleSelectBackgroundDoubleClick:(bool)double_click LongPress:(bool)long_press
{
	return false;
}

- (void) HandleTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
}

- (void) OnTapGestureInView:(UIView *)gestureView AtX:(float)x Y:(float)y
{
	int row = -1;
	int col = -1;
		
	if(gestureView && [gestureView isKindOfClass:[SimpleListView class]])
	{
		if([(SimpleListView *)gestureView FindCellAtX:x Y:y RowReturn:&row ColReturn:&col])
		{
			bool if_heading = [(SimpleListView *)gestureView IfHeading];
			
			if(if_heading && row == 0)
			{
				if(![self HandleSelectCol:col])
				{
					[self HandleSelectHeading];
				}
			}
			else
			{
				if(if_heading)
					row --;
				
				if(![self HandleSelectCellRow:row Col:col DoubleClick:false LongPress:false])
				{
					if(![self HandleSelectRow:row DoubleClick:false LongPress:false])
					{
						[self HandleTapGestureInView:gestureView AtX:x Y:y];
					}
				}
			}
		}
		else
		{
			if(![self HandleSelectBackgroundDoubleClick:false LongPress:false])
			{
				[self HandleTapGestureInView:gestureView AtX:x Y:y];
			}
		}
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
			
			if(if_heading && row == 0)
			{
				if(![self HandleSelectCol:col])
				{
					[self HandleSelectHeading];
				}
			}
			else
			{
				if(if_heading)
					row --;
				
				if(![self HandleSelectCellRow:row Col:col DoubleClick:true LongPress:false])
				{
					[self HandleSelectRow:row DoubleClick:true LongPress:false];
				}
			}
		}
		else
		{
			[self HandleSelectBackgroundDoubleClick:true LongPress:false];
		}		
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
			
			if(if_heading && row == 0)
			{
				if(![self HandleSelectCol:col])
				{
					[self HandleSelectHeading];
				}
			}
			else
			{
				if(if_heading)
					row --;
				
				if(![self HandleSelectCellRow:row Col:col DoubleClick:false LongPress:true])
				{
					[self HandleSelectRow:row DoubleClick:false LongPress:true];
				}
			}
		}
		else
		{
			[self HandleSelectBackgroundDoubleClick:false LongPress:true];
		}
	}
}


@end
