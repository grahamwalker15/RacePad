//
//  LeaderboardView.m
//  RacePad
//
//  Created by Gareth Griffith on 11/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "LeaderboardView.h"
#import "RacePadDatabase.h"
#import "TableData.h"
#import "TrackMap.h"


@implementation LeaderboardView

@synthesize tableData;

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
	}
	
    return self;
}

- (void)dealloc
{
	[tableData release];
	
    [super dealloc];
}

- (void) DrawRow:(int)row_index AtY:(float)y
{
	// y is the top of the row
	
	// We highlight any car being followed in the map, so get this car
	RacePadDatabase *database = [RacePadDatabase Instance];
	TrackMap *trackMap = [database trackMap];
	NSString * carToFollow = [trackMap carToFollow];
	bool followingCar = [carToFollow length] > 0;

	[self SaveGraphicsState];
	
	float row_height = [self RowHeight];
	
	int x_draw = 2 ;
	int column_width = current_size_.width - 4;
	
	//float xmin = current_bottom_left_.x;
	//float xmax = current_top_right_.x;
				
	NSString * text = [[self GetCellTextAtRow:row_index Col:3] retain];
			
	if(followingCar && [text isEqualToString:carToFollow])
		[self SetBGColour:dark_magenta_];
	else
		[self SetBGColour:black_];
	
	[self SetFGColour:white_];
				
	[self FillShadedRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				
	if([text length] > 0)
	{				
		float w, h;
		[self GetStringBox:text WidthReturn:&w HeightReturn:&h];
		
		float text_y = y + (row_height - h) / 2;
		
		float xpos ;
		float text_offset = 3;
		
		xpos = x_draw + text_offset ;
		
		[self DrawString:text AtX:xpos Y:text_y];
		[self UseRegularFont];
	}
	
	[self SetLineWidth:2.0];
	[self LineRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
	
	[text release];
	
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
	
	if(y < 0)
		y = 0;
	
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
	   return [self GetCellTextAtRow:row Col:3];
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
