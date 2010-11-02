//
//  SimpleListView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/8/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "SimpleListView.h"


@implementation SimpleListView

@synthesize base_colour_;
@synthesize selected_colour_;
@synthesize focus_colour_;
@synthesize selected_text_colour_;
@synthesize text_colour_;
@synthesize background_colour_;

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Super class overrides

//If the view is stored in the nib file,when it's unarchived it's sent -initWithCoder:

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		[self InitialiseSimpleListViewMembers];
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self InitialiseSimpleListViewMembers];
    }
    return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

- (void)dealloc
{
	[option_tyre_ release];
	[prime_tyre_ release];
	[inter_tyre_ release];
	[wet_tyre_ release];
	
	[black_ release];
	[white_ release];
	[blue_ release];
	[orange_ release];
	[yellow_ release];
	[red_ release];
	[cyan_ release];
	[dark_blue_ release];
	[light_blue_ release];
	[dark_grey_ release];
	[light_grey_ release];
	[very_light_blue_ release];
	[very_light_grey_ release];
	[light_orange_ release];
	
	[base_colour_ release];
	[selected_colour_ release];
	[focus_colour_ release];
	[selected_text_colour_ release];
	
	[text_colour_ release];
	[background_colour_ release];
	 
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
//  Methods for this class 

- (void)InitialiseSimpleListViewMembers
{	
	row_count_ = 0;
	row_height_ = 20;
	
	column_count_ = 0;
		
	if_heading_ = false;
	if_large_font_ = false;
			
	text_baseline_ = 0;
	
	selected_row_ = -1;
	selected_col_ =  -1;
	
	down_row_ = -1;
	down_col_ = -1;
	mouse_x_ = -1;
	mouse_y_ = -1;
	down_x_ = -1;
	down_y_ = -1;
	select_on_up_ = false;
	
	click_ = 0;
	double_click_possible_ = false;
	
	base_colour_ = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	selected_colour_ = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	focus_colour_ = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	selected_text_colour_ = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	
	
	alignment_ = SLV_TEXT_LEFT_;
	
	text_colour_ = [self CreateColourRed:255 Green:255 Blue:255];
	background_colour_ =[self CreateColourRed:0 Green:0 Blue:0];

	base_colour_ = [self CreateColourRed:200 Green:200 Blue:200];
	
	selected_colour_ = [self CreateColourRed:220 Green:200 Blue:210];
	focus_colour_ = [self CreateColourRed:180 Green:160 Blue:170];
	
	heading_bg_colour_ = [self CreateColourRed:150 Green:150 Blue:150];
	heading_text_colour_ = [self CreateColourRed:0 Green:0 Blue:0];
	
	black_ = [self CreateColourRed:0 Green:0 Blue:0];
	white_ = [self CreateColourRed:255 Green:255 Blue:255];
	blue_ = [self CreateColourRed:0 Green:0 Blue:255];
	orange_ = [self CreateColourRed:200 Green:140 Blue:0];
	light_orange_ = [self CreateColourRed:250 Green:180 Blue:0];
	yellow_ = [self CreateColourRed:255 Green:255 Blue:0];
	red_ = [self CreateColourRed:255 Green:0 Blue:0];
	cyan_ = [self CreateColourRed:0 Green:255 Blue:255];
	dark_blue_ = [self CreateColourRed:0 Green:0 Blue:150];
	light_blue_ = [self CreateColourRed:120 Green:150 Blue:220];
	dark_grey_ = [self CreateColourRed:130 Green:130 Blue:130];
	light_grey_ = [self CreateColourRed:200 Green:200 Blue:200];
	very_light_blue_ = [self CreateColourRed:220 Green:240 Blue:255];
	very_light_grey_ = [self CreateColourRed:220 Green:220 Blue:220];
	
	option_tyre_ = [self CreateColourRed:255 Green:255 Blue:255];
	prime_tyre_ = [self CreateColourRed:255 Green:255 Blue:0];
	inter_tyre_ = [self CreateColourRed:0 Green:255 Blue:255];
	wet_tyre_ = [self CreateColourRed:110 Green:0 Blue:150];
	
}

- (void) DeleteTable
{
	[self ClearRows];
	column_count_ = 0;
}

- (void) ClearRows
{
	down_row_ = -1;
	row_count_ = 0;
}

- (void) SetRowCount:(int)count
{
	row_count_ = count;
}

- (void) SetRowHeight:(int)height
{
	row_height_ = height;
}

- (void) AddColumn
{
	[self AddColumnWithWidth:50];
}

- (void) AddColumnWithWidth:(int)width
{
	[self AddColumnWithWidth:50 Type:SLV_COL_STANDALONE_];
}

- (void) AddColumnWithWidth:(int)width Type:(int)type
{
	if(column_count_ < SLV_MAX_COLUMNS)
	{
		column_width_[column_count_] = width;
		column_type_[column_count_] = type;
		
		column_count_++;
	}
}

- (void) SetColumn:(int)column Width:(int)width
{
	if(column >= 0 && column < column_count_)
	{
		column_width_[column] = width;
	}
}

- (int) TableWidth
{
	int w = 0;
	for ( int i = 0 ; i < [self ColumnCount] ; i++)
		w += [self ColumnWidth:i];
	
	return w;
}

- (void) SetHeading:(bool)if_heading
{
	if_heading_ = if_heading;
}

- (void) SetLargeFont:(bool)if_large
{
	if_large_font_ = if_large;
}

- (void) ScrollToEnd
{
}

- (void) ScrollToEndAndRedraw
{
}

- (void) ScrollToRow:(int)row
{
}

- (void) ScrollToRowAndRedraw:(int)row
{
}

- (void) MakeRowVisible:(int)row
{
}

- (void) MakeRowVisibleAndRedraw:(int)row
{
}

/*
 - (void) MouseDown ( int x, int y, int button, int detail )
 - (void) DoubleClick ( int x, int y, int button, int detail );
 - (// void MouseMove ( int x, int y, int button, int detail );
 - (void) MouseUp ( int x, int y, int button, int detail );
 - (void) MousePosition ( int x, int y, int detail );
 - (void) Enter ( int x, int y );
 - (void) Exit ( );
 - (void) ActionKey ( unsigned char ch, int detail );
 - (void) GetMousePosition(int &x, int &y);
 */

- (bool) IfHeading
{
	return if_heading_ ;
}

- (void) CheckWindowSize
{
	int row_height = [self RowHeight];
	int row_count = [self RowCount];
	
	int visible_count = current_size_.height / row_height;
}

- (void) SetDefaultFormatting:(bool)if_heading
{
	[self SetTextColour:white_];
	
	if(if_heading)
		[self SetBackgroundColour:focus_colour_];
	else
		[self SetBackgroundColour:base_colour_];
	
	alignment_ = SLV_TEXT_LEFT_;
}

- (void) MixBackgroundColour:(UIColor *)colour MixPct:(int) pct
{
}

- (void) DarkenBackgroundColour
{
}

- (void) LightenBackgroundColour
{
}

- (void) SetAlignment:(int)alignment
{
	alignment_ = alignment;
}

- (bool) IsRowSelected:(int)index
{
	return (index == selected_row_) ;
}

- (int) InqSelectedRowIndex
{
	return selected_row_ ;
}

- (bool) IsColSelected:(int)index
{
	return (index == selected_col_) ;
}

- (int) InqSelectedColIndex
{
	return selected_col_ ;
}

- (void) DrawRow:(int)row AtY:(float)y
{
	// y is the top of the row
	
	bool heading = if_heading_ && row == 0 ;
			
	// Prepare any data specific to a derived class
	if(!heading)
		[self PrepareRow:row];
	
	bool selected = [self IsRowSelected:row];
	bool focus = false;
	
	int maximum_width = current_size_.width;	
	int column_count = [self ColumnCount];
	
	float row_height = [self RowHeight];
	
	int row_index = if_heading_ ? row - 1 : row;
	
	int x = 0 ;
	float xmin = current_bottom_left_.x;
	float xmax = current_top_right_.x;
	
	for ( int col = 0 ; col < column_count ; col ++)
	{
		// Skip headings on child columns
		if(heading && [self ColumnType:col] == SLV_COL_CHILD_)
			continue;
		
		// Get column width (including children if we're on a heading)
		int column_width = [self ColumnWidth:col];
		if(heading && [self ColumnType:col] == SLV_COL_PARENT_)
		{
			int cc = col+1;
			while(cc < column_count && [self ColumnType:cc] == SLV_COL_CHILD_)
			{
				column_width += [self ColumnWidth:cc];
				cc++;
			}
		}
		
		if((x + column_width) > xmin && x < xmax)
		{
			float x_draw = x;
			
			int cell_type ;
			
			[self SetDefaultFormatting:heading];
			
			if(heading)
				cell_type  = SLV_TEXT_CELL_;
			else
				cell_type  = [self InqCellTypeAtRow:row_index Col:col];
			
			if(cell_type  == SLV_TEXT_CELL_)
			{
				NSString * text = heading ? [[self GetHeadingAtCol:col] retain] : [[self GetCellTextAtRow:row_index Col:col] retain];
				
				[self SetBGColour:background_colour_];
				[self SetFGColour:text_colour_];
				
				if(heading)
					[self FillShadedRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				else if([self isOpaque] || [text length] > 0)
					[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];

				if([text length] > 0)
				{				
					float w, h;
					[self GetStringBox:text WidthReturn:&w HeightReturn:&h];
					
					float text_y = y + row_height_ - text_baseline_ - 2 - h;
					
					float xpos ;
					float text_offset = 3;
					
					if(alignment_ == SLV_TEXT_LEFT_)
						xpos = x_draw + text_offset ;
					else if(alignment_ == SLV_TEXT_RIGHT_)
						xpos = x_draw + column_width - w - text_offset ;
					else
						xpos = x_draw + (column_width / 2) - (w / 2) ;
					
					if (xpos < x_draw + text_offset)
						xpos = x_draw + text_offset;
					
					float max_width = column_width - (xpos - x_draw) ;					
					[self DrawClippedString:text AtX:xpos Y:text_y MaxWidth:max_width];
					[self UseRegularFont];
				}
				[text release];
			}
			else if (cell_type  == SLV_IMAGE_CELL_)
			{
				UIImage * image = [[self GetCellImageAtRow:row_index Col:col] retain];
				
				[self SetBGColour:background_colour_];
				
				[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				
				if(image)
				{
					[self DrawImage:image AtX:x_draw Y:y];
					[image release];
				}
				
			}
			else
			{
				UIImage * image = [[self GetCellClientImageAtRow:row_index Col:col] retain];
				
				[self SetBGColour:background_colour_];
				
				[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				
				if(image)
				{
					[self DrawImage:image AtX:x_draw Y:y];
					[image release];
				}
				
			}
		}
		
		x += column_width ;
		
	}
	
}

- (void) Draw:(CGRect)region
{
	// Prepare any data specific to a derived class
	[self PrepareData];
	
	// Then draw row by row
	[self CheckWindowSize];
	[self BeginDrawing];
	
	int row_count = [self RowCount];
	int row_height = [self RowHeight];
	
	float table_height = row_count * [self RowHeight ];
	float table_width = [self TableWidth];
	
	[self SetContentWidth:table_width AndHeight:table_height];
	CGPoint offset = [self contentOffset];
		
	if(if_large_font_)
		[self UseMediumBoldFont];
	else
		[self UseBoldFont];
	
	[self ClearScreen];
	
	// If there is a heading, we'll draw it at the end at the origin - leave space for it
	bool if_heading = [self IfHeading];
	float y = if_heading ? row_height : 0;
	float ymin = current_top_right_.y + y;
	float ymax = current_bottom_left_.y;
	
	int first_row = if_heading ? 1 : 0;

	// Draw the table rows first
	for ( int i = first_row; i < row_count; i ++ )
	{
		if ( (y + row_height) >= ymin )
		{
			[self DrawRow:i AtY:y];
		}

		y += row_height ;
		
		if ( y > ymax )
			break;		
	}
	
	if( y < ymax )
	{
		[self SetBackgroundColour:base_colour_];
		[self FillRectangleX0:current_origin_.x Y0:y X1:current_top_right_.x Y1:ymax];
	}
	
	// Then add the heading if there is one
	if(if_heading)
	{
		y = current_top_right_.y > 0 ? current_top_right_.y : 0;
		[self DrawRow:0 AtY:y];
	}
	
	[self EndDrawing];
}

- (void) DrawBase
{
}

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
// Protected functions that can be overridden

- (int) RowCount
{
	return (if_heading_ ? row_count_ + 1 : row_count_);
}

- (int) ColumnCount
{
	return column_count_;
}

- (int) RowHeight;
{
	return row_height_;
}

- (int) ColumnWidth:(int)col;
{
	if(col >= 0 && col < column_count_)
		return column_width_[col];
	else
		return 30;	// Sensible default even though it should never be called
}

- (int) ColumnType:(int)col;
{
	if(col >= 0 && col < column_count_)
		return column_type_[col];
	else
		return SLV_COL_STANDALONE_;	// Sensible default even though it should never be called
}

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
// Functions that CAN be overridden for customised content (defaults return no content)

- (void) PrepareData
{
}

- (void) PrepareRow:(int)row
{
}

///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
// Functions that MUST be overridden for customised content (defaults return no content)

- (int) InqCellTypeAtRow:(int)row Col:(int)col
{
	return SLV_TEXT_CELL_;
}

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{
	return nil;
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	return nil;
}

- (UIImage *) GetCellClientImageAtRow:(int)row Col:(int)col
{
	return nil;
}

- (NSString *) GetHeadingAtCol:(int)col
{
	return nil;
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
// User interaction routines

- (bool) FindCellAtX:(float)x Y:(float)y RowReturn:(int *)row_return ColReturn:(int *)col_return
{
	int row_count = [self RowCount];
	int row_height = [self RowHeight];
	
	float table_height = row_count * [self RowHeight ];
	float table_width = [self TableWidth];
	
	if(x < 0 || y < 0 || x > table_width || y > table_height)
	{
		return false;
	}

	int row = (int)(y / (float) row_height);
	
	int w = 0;
	int col = 0;
	for ( int i = 0 ; i < [self ColumnCount] ; i++)
	{
		w += [self ColumnWidth:i];
		if(w >= x)
		{
			col = i;
			break;
		}
	}
	
	*row_return = row;
	*col_return = col;
	
	return true;
}


@end
