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
