//
//  LeaderboardView.m
//  RacePad
//
//  Created by Gareth Griffith on 11/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "RaceMapLeaderboardView.h"
#import "RaceMapData.h"
#import "TableData.h"
#import "TrackMapView.h"


@implementation RaceMapLeaderboardView

@synthesize tableData;
@synthesize associatedTrackMapView;
@synthesize smallDisplay;
@synthesize useBoldFont;
@synthesize addOutlines;
@synthesize highlightCar;

- (id)initWithCoder:(NSCoder*)coder
{
    if ((self = [super initWithCoder:coder]))
    {
		associatedTrackMapView = nil;
		smallDisplay = false;
		useBoldFont = true;
		addOutlines = true;
	}
	
    return self;
}

- (void)dealloc
{
	[tableData release];
	[highlightCar release];
	
    [super dealloc];
}

- (void) DrawRow:(int)row_index AtY:(float)y
{
	// y is the top of the row
	
	// We highlight any car being followed in the associated map view, so get this car
    
	bool followingCar = false;
	NSString * carToFollow = nil;
	
	if(associatedTrackMapView)
	{
		carToFollow = [associatedTrackMapView carToFollow];
		followingCar = [carToFollow length] > 0;
	}
	else
	{
		carToFollow = highlightCar;
		followingCar = [carToFollow length] > 0;
	}
    
    
	[self SaveGraphicsState];
	
	if(smallDisplay)
	{
		if(useBoldFont)
			[self UseFont:DW_LARGER_CONTROL_FONT_];
		else
			[self UseFont:DW_LIGHT_LARGER_CONTROL_FONT_];
	}
	else
	{
		if(useBoldFont)
			[self UseFont:DW_REGULAR_FONT_];
		else
			[self UseFont:DW_LIGHT_REGULAR_FONT_];
	}
	
	float row_height = [self RowHeight];
	
	int x_draw = 2 ;
	int column_width = current_size_.width - 4;
	
	//float xmin = current_bottom_left_.x;
	//float xmax = current_top_right_.x;
    
	NSString * text = [[self GetCellTextAtRow:row_index Col:2] retain];
	NSString * pitText = [[self GetCellTextAtRow:row_index Col:1] retain];
    
	bool shadeBackground = addOutlines;
	
	if(followingCar && [text isEqualToString:carToFollow])
	{
		[self SetBGColour:dark_magenta_];
		[self SetFGColour:white_];
		shadeBackground = true;
	}
	else if([pitText isEqualToString:@"P"])
	{
		[self SetBGColour:[UIColor colorWithRed:0.7 green:0.7 blue:1.0 alpha:1.0]];
		[self SetFGColour:black_];
		shadeBackground = true;
	}
	else if([pitText isEqualToString:@"E"])
	{
		[self SetBGColour:[UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]];
		[self SetFGColour:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0]];
	}
	else if(!addOutlines)
	{
		[self SetBGColour:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.3]];
		[self SetFGColour:white_];
	}
	else
	{
		[self SetBGColour:black_];
		[self SetFGColour:white_];
	}
	
	if(!shadeBackground)
		[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
	else
		[self FillShadedRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height WithHighlight:false];
    
	if([text length] > 0)
	{
		float w, h;
		[self GetStringBox:text WidthReturn:&w HeightReturn:&h];
		
		float text_y = y + (row_height - h) / 2;
		
		float xpos ;
		float text_offset = 3;
		
		xpos = x_draw + text_offset ;
		
		[self DrawString:text AtX:xpos Y:text_y];
	}
	
	if(addOutlines)
	{
		[self SetFGColour:white_];
		[self SetLineWidth:2.0];
		[self LineRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
	}
	
	[text release];
    [pitText release];
	
	[self RestoreGraphicsState];
    
}

- (void) Draw:(CGRect)region
{
	// Draw row by row
	[self BeginDrawing];
	
	int row_count = [self RowCount];
	int row_height = [self RowHeight];
	
	float table_height = row_count * row_height;
	
	float y = (current_size_.height - table_height) / 2;
	
	float content_width = current_size_.width;
	float content_height = table_height > current_size_.height ? table_height : current_size_.height;
	
	[self SetContentWidth:content_width AndHeight:content_height];
	
	if(y < 0)
		y = 0;
	
	float ybase = y;
	
	[self UseBoldFont];
	
	[self ClearScreen];
	
	float ymin = current_top_right_.y;
	float ymax = current_bottom_left_.y;
	
	// Draw the table row by row
	for ( int i = 0; i < row_count; i ++ )
	{
		if ( (y + row_height) >= ymin )
		{
			[self DrawRow:i AtY:y];
		}
		
		y += row_height ;
		
		if ( y > ymax )
			break;
	}
	
	// Then draw the line dividers
	if(!addOutlines)
	{
		y = ybase;
		int x_draw = 2 ;
		int column_width = current_size_.width - 4;
		
		for ( int i = 0; i < row_count; i ++ )
		{
			[self SetFGColour:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.7]];
			[self LineX0:x_draw Y0:y X1:x_draw + column_width Y1:y];
            
			y += row_height ;
			
			if ( y > ymax )
				break;
			
			[self SetFGColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
			[self LineX0:x_draw Y0:y-1 X1:x_draw + column_width Y1:y-1];
		}
		
		[self SetFGColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0]];
		[self LineX0:x_draw + column_width Y0:ybase X1:x_draw + column_width Y1:ymax];
		[self SetFGColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5]];
		[self LineX0:x_draw + column_width+1 Y0:ybase X1:x_draw + column_width+1 Y1:ymax];
	}
	
    
	[self EndDrawing];
}

- (NSString *) carNameAtX:(float)x Y:(float)y
{
	int row_count = [self RowCount];
	int row_height = [self RowHeight];
	
	float table_height = row_count * row_height;
	
	float ytop = (current_size_.height - table_height) / 2;
	
	if(ytop < 0)
		ytop = 0;
	
	if(y < ytop)
		return nil;
	
	int row = (int)((float)(y - ytop) / row_height);
	
	if(tableData && row < [tableData rows])
        return [self GetCellTextAtRow:row Col:2];
	else
		return nil;
}

- (NSString *) carNameAtPosition:(int)position
{
	if(tableData && [tableData rows] >= position)
		return [self GetCellTextAtRow:position - 1 Col:2];
	else
		return nil;
}

- (int) RowCount
{
	if(tableData)
		return [tableData rows];
	else
		return 0;
}

- (int) RowHeight
{
	if(smallDisplay)
		return 22;
	else
		return 24;
}

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{
	if(tableData)
	{
		TableCell *cell = [tableData cell:row Col:col];
		
		if ( cell )
		{
			return [cell string];
		}
	}
	
	return nil;
}


@end
