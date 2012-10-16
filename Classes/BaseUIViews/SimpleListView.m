//
//  SimpleListView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/8/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "SimpleListView.h"
#import "TableData.h"
#import "BasePadCoordinator.h"

@implementation SimpleListView

@synthesize standardRowHeight;
@synthesize expansionRowHeight;

@synthesize expansionAllowed;
@synthesize adaptableRowHeight;

@synthesize cellYMargin;
@synthesize rowDivider;
@synthesize shadeHeading;

@synthesize font_;
@synthesize draw_all_cells_;
@synthesize background_alpha_;
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
	[self setDelegate:self];
	
	row_count_ = 0;
	standardRowHeight = 20;
	expansionRowHeight = 0;
	
	adaptableRowHeight = false;
	
	for(int i = 0 ; i < SLV_MAX_ROWS ; i++)
		expansionFlag[i] = 0;
	
	expansionAllowed = false;
	
	column_count_ = 0;
	
	cellYMargin = 0;
	rowDivider = false;
	
	font_ = DW_BOLD_FONT_;
    
	if_heading_ = false;
	shadeHeading = false;
	swiping_enabled_ = false;
    
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
	
	base_colour_ = [[UIColor alloc] initWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
	selected_colour_ = [[UIColor alloc] initWithRed:0.2 green:0.2 blue:1.0 alpha:1.0];
	focus_colour_ = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	selected_text_colour_ = [[UIColor alloc] initWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	
	alignment_ = SLV_TEXT_LEFT_;
	
	text_colour_ = [DrawingView CreateColourRed:255 Green:255 Blue:255];
	background_colour_ = [DrawingView CreateColourRed:0 Green:0 Blue:0];
	
	background_alpha_ = 1.0;
	draw_all_cells_ = true;
	
	focus_colour_ = [DrawingView CreateColourRed:180 Green:160 Blue:170];
	
	heading_bg_colour_ = [DrawingView CreateColourRed:150 Green:150 Blue:150];
	heading_text_colour_ = [DrawingView CreateColourRed:0 Green:0 Blue:0];
	
	option_tyre_ = [DrawingView CreateColourRed:255 Green:255 Blue:255];
	prime_tyre_ = [DrawingView CreateColourRed:255 Green:255 Blue:0];
	inter_tyre_ = [DrawingView CreateColourRed:0 Green:255 Blue:255];
	wet_tyre_ = [DrawingView CreateColourRed:110 Green:0 Blue:150];
	
	scroll_to_end_requested_ = false;
	reset_scroll_requested_ = false;
	scroll_animating_ = false;
	scrollTimeoutTimer = nil;
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
	
	for(int i = 0 ; i < SLV_MAX_ROWS ; i++)
		expansionFlag[i] = 0;
	
}

- (void) UnexpandAllRows
{
	for(int i = 0 ; i < SLV_MAX_ROWS ; i++)
		expansionFlag[i] = 0;
	
}

- (void) SetRow:(int)row Expanded:(bool)expanded
{
	if(row < SLV_MAX_ROWS)
		expansionFlag[row] = expanded ? 1 : 0;
}

- (bool) RowExpanded:(int)row
{
	if(row < SLV_MAX_ROWS)
		return (expansionFlag[row] == 1);
	else
		return false;
}

- (void) SetRowCount:(int)count
{
	row_count_ = count;
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
	// Get the device orientation
	int orientation = [[BasePadCoordinator Instance] deviceOrientation];
	portraitMode = (orientation == UI_ORIENTATION_PORTRAIT_);
	
	// Work out width
	int w = 0;
	for ( int i = 0 ; i < [self ColumnCount] ; i++)
	{
		// Do we count this column?
		if([self ColumnUse:i] == TD_USE_FOR_NONE)
			continue;
		else if(portraitMode && [self ColumnUse:i] == TD_USE_FOR_LANDSCAPE)
			continue;
		else if(!portraitMode && [self ColumnUse:i] == TD_USE_FOR_PORTRAIT)
			continue;
		
		w += [self ColumnWidth:i];
	}
	
	return w;
}

- (int) TableHeight
{
	int h = 0;
	for ( int i = 0 ; i < [self RowCount] ; i++)
	{
		h += [self RowHeight:i];
	}
	
	return h;
}

- (int) TableHeightToRow:(int)row
{
	if(row < 0)
		return 0;
	
	int h = 0;
	for ( int i = 0 ; i <= row ; i++)
	{
		h += [self RowHeight:i];
	}
	
	return h;
}

- (void) SetHeading:(bool)if_heading
{
	if_heading_ = if_heading;
}

- (void) SetSwipingEnabled:(bool)value
{
	swiping_enabled_ = value;
}

- (void)RequestRedraw
{
	// Ignore redraw requests while we're animating a scroll
	if(!scroll_animating_)
		[self setNeedsDisplay];
}

- (void) ResetScroll
{
	reset_scroll_requested_ = true;
}

- (void) RequestScrollToEnd
{
	if ( scroll_animating_ )
	{
		scroll_to_end_requested_ = true;
		return;
	}
	
	CGRect bounds = [self bounds];
    
	float table_height = [self TableHeight];
	float table_width = [self TableWidth];
	
	[self SetContentWidth:table_width AndHeight:table_height];
	
	float yOffset = floorf(table_height - bounds.size.height);
	
	if(yOffset < 0)
	{
		[self setContentOffset:CGPointMake(0.0, 0.0) animated:false];
		[self getCurrentBoundsInfo];
		[self RequestRedraw];
	}
	else
	{
		if ( reset_scroll_requested_ )
			[self setContentOffset:CGPointZero animated:false];
		[self ScrollToEnd];
	}
	reset_scroll_requested_ = false;
}

- (void) ScrollToEnd
{
	// Don't do it if an animation is in progress - it will be done in the DidStop callback
	if(scroll_animating_)
		return;
	
	scroll_to_end_requested_ = false;
    
	CGRect bounds = [self bounds];
	
	float yOffset = floorf([self TableHeight] - bounds.size.height);
	
	if(yOffset < 0)
		yOffset = 0;
	
	CGPoint currentOffset = [self contentOffset];
	if ( currentOffset.y != yOffset )
	{
		scroll_animating_ = true;
		
		[self setContentOffset:CGPointMake(0.0, yOffset) animated:true];
		[self getCurrentBoundsInfo];
        
		// Set timer to catch it if the end callback isn't called for any reason
		[self setScrollTimer];
	}
	else
		[self RequestRedraw];
}

- (void) ScrollToRow:(int)row
{
	CGRect bounds = [self bounds];
	float yOffset = [self TableHeightToRow:row] - bounds.size.height;
    
	if(yOffset < 0)
		yOffset = 0;
    
	[self setContentOffset:CGPointMake(0.0, yOffset) animated:false];
	[self RequestRedraw];
}

- (void) MakeRowVisible:(int)row
{
	float w = [self TableWidth];
	float h = [self RowHeight:row];
	float y = row <= 0 ? 0 : [self TableHeightToRow:row - 1];
	
	[self scrollRectToVisible:CGRectMake(0.0, y, w, h) animated:false];
	[self RequestRedraw];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if(scrollTimeoutTimer)
	{
		[scrollTimeoutTimer invalidate];
		scrollTimeoutTimer = nil;
	}
    
	[self getCurrentBoundsInfo];
	
	scroll_animating_ = false;
    
	if(scroll_to_end_requested_)
		[self performSelector:@selector(RequestScrollToEnd) withObject:nil afterDelay: 0.1];
}

- (void) setScrollTimer
{
	// Timer to re-enable redraws just in case scroll to end hasn't finished in 3 secs
	if(scrollTimeoutTimer)
		[scrollTimeoutTimer invalidate];
	
	scrollTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(scrollTimerExpired:) userInfo:nil repeats:NO];
}

- (void) scrollTimerExpired:(NSTimer *)theTimer
{
	scrollTimeoutTimer = nil;
	
	[self getCurrentBoundsInfo];
	
	scroll_animating_ = false;
    
	if(scroll_to_end_requested_)
		[self RequestScrollToEnd];
    
}

- (bool) IfHeading
{
	return if_heading_ ;
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

- (void) SelectRow:(int)index
{
	selected_row_= index ;
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

- (void) DrawRow:(int)row AtY:(float)y WithRowHeight:(float)row_height AndLineHeight:(float)line_height
{
	// y is the top of the row
	
	bool heading = if_heading_ && row == 0 ;
    
	// Prepare any data specific to a derived class
	if(!heading)
		[self PrepareRow:row];
	
	bool selected = [self IsRowSelected:row];
	
	int column_count = [self ColumnCount];
	
	int row_index = if_heading_ ? row - 1 : row;
	
	int x = 0 ;
	float xmin = current_bottom_left_.x;
	float xmax = current_top_right_.x;
	
	for ( int col = 0 ; col < column_count ; col ++)
	{
		// Skip headings on child columns
		if(heading && [self ColumnType:col] == SLV_COL_CHILD_)
			continue;
		
		// Do we draw this column
		if([self ColumnUse:col] == TD_USE_FOR_NONE)
			continue;
		else if(portraitMode && [self ColumnUse:col] == TD_USE_FOR_LANDSCAPE)
			continue;
		else if(!portraitMode && [self ColumnUse:col] == TD_USE_FOR_PORTRAIT)
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
		
		int font = [self GetFontAtRow:row Col:col];
		[self UseFont:font];
        
		if((x + column_width) > xmin && x < xmax)
		{
			float x_draw = x;
			
			int cell_type ;
			
			[self SetDefaultFormatting:heading];
			
			if(heading)
				cell_type  = SLV_TEXT_CELL_;
			else
				cell_type  = [self InqCellTypeAtRow:row_index Col:col];
			
			if(cell_type  == SLV_CUSTOM_DRAW_)
			{
				[self CustomDrawCellForRow:row Col:col AtX:(float)x Y:(float)y WithRowHeight:row_height ColumnWidth:column_width AndLineHeight:line_height];
			}
			else if(cell_type  == SLV_TEXT_CELL_)
			{
				NSString * text = heading ? [[self GetHeadingAtCol:col] retain] : [[self GetCellTextAtRow:row_index Col:col] retain];
				
				if(selected)
				{
                    
					[self SetBGColour:[selected_colour_ colorWithAlphaComponent:background_alpha_]];
					[self SetFGColour:selected_text_colour_];
				}
				else
				{
					[self SetBGColour:[background_colour_ colorWithAlphaComponent:background_alpha_]];
					[self SetFGColour:text_colour_];
				}
				
				if(heading)
				{
					if(shadeHeading)
						[self FillShadedRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height WithHighlight:true];
					else
						[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				}
				else if(draw_all_cells_ || [self isOpaque] || [text length] > 0)
				{
					[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				}
                
				if([text length] > 0)
				{
					float w, h;
					[self GetStringBox:text WidthReturn:&w HeightReturn:&h];
                    
					float text_y = y + line_height - text_baseline_ - cellYMargin - 2 - h;
					
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
					
					if(adaptableRowHeight)
						[self DrawMultiLineString:text AtX:xpos Y:text_y MaxWidth:max_width Height:row_height];
					else
						[self DrawClippedString:text AtX:xpos Y:text_y MaxWidth:max_width];
				}
				[text release];
			}
			else if (cell_type  == SLV_IMAGE_CELL_)
			{
				UIImage * image = [[self GetCellImageAtRow:row_index Col:col] retain];
				
				if(selected)
				{
					[self SetBGColour:[selected_colour_ colorWithAlphaComponent:background_alpha_]];
				}
				else
				{
					[self SetBGColour:[background_colour_ colorWithAlphaComponent:background_alpha_]];
				}
				
				[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				
				if(image)
				{
					float w = [image size].width;
					float h = [image size].height;
					
					
					if(w > column_width && w > 0 && h > 0)
					{
						float image_rect_height = column_width * h / w;
						float ypos = y + line_height - text_baseline_ - cellYMargin - 2 - image_rect_height;
						[self DrawImage:image InRect:CGRectMake(x_draw, ypos, column_width, image_rect_height)];
					}
					else
					{
						float xpos = x_draw + (column_width / 2) - (w / 2) ;
						float ypos = y + line_height - text_baseline_ - cellYMargin - 2 - h;
						[self DrawImage:image AtX:xpos Y:ypos];
					}
					
					[image release];
				}
				
			}
			else
			{
				UIImage * image = [[self GetCellClientImageAtRow:row_index Col:col] retain];
				
				[self SetBGColour:[background_colour_ colorWithAlphaComponent:background_alpha_]];
				
				[self FillRectangleX0:x_draw Y0:y X1:x_draw + column_width Y1:y + row_height];
				
				if(image)
				{
					float w = [image size].width;
					float h = [image size].height;
					
					if(w > column_width && w > 0 && h > 0)
					{
						float image_rect_height = column_width * h / w;
						[self DrawImage:image InRect:CGRectMake(x_draw, y - cellYMargin, column_width, image_rect_height)];
					}
					else
					{
						float xpos = x_draw + (column_width / 2) - (w / 2) ;
						[self DrawImage:image AtX:xpos Y:y - cellYMargin];
					}
                    
					[image release];
				}
			}
		}
		
		x += column_width ;
		
	}
	
}

-(void)	CustomDrawCellForRow:(int)row Col:(int)col AtX:(float)x Y:(float)y WithRowHeight:(float)row_height ColumnWidth:(int)column_width AndLineHeight:(float)line_height
{
	// Override to draw custom cells
}

- (void) Draw:(CGRect)region
{
	// Get the device orientation
	int orientation = [[BasePadCoordinator Instance] deviceOrientation];
	portraitMode = (orientation == UI_ORIENTATION_PORTRAIT_);
    
	// Prepare any data specific to a derived class
	[self PrepareData];
	
	// Clear the row height cache
	[self ClearRowHeightCache];
	
	// Then draw row by row
	[self BeginDrawing];
	
	int row_count = [self RowCount];
	
	float table_height = [self TableHeight];
	float table_width = [self TableWidth];
	
	float content_width = table_width > current_size_.width ? table_width : current_size_.width;
	float content_height = table_height > current_size_.height ? table_height : swiping_enabled_ ? current_size_.height + 1 : current_size_.height;
	
	[self SetContentWidth:content_width AndHeight:content_height];
    
	[self SaveFont];
	
	// If there is a heading, we'll draw it at the end at the origin - leave space for it and set it to clip
	bool if_heading = [self IfHeading];
	float y = if_heading ? [self standardRowHeight] : 0;
	float ymin = current_top_right_.y + y;
	float ymax = current_bottom_left_.y;
	
	int first_row = if_heading ? 1 : 0;
	
	[self SaveGraphicsState];
	
	if(if_heading)
		[self SetClippingArea:CGRectMake(current_bottom_left_.x, ymin, current_size_.width, ymax - ymin) ];
    
	// Draw the table rows first
	for ( int i = first_row; i < row_count; i ++ )
	{
		int line_height = [self ContentRowHeight:i];
		int content_row_height = adaptableRowHeight ? [self MaxContentRowHeight:i] : [self ContentRowHeight:i];
		int row_height = [self RowHeight:i];
        
		if ( (y + row_height) >= ymin )
		{
			[self DrawRow:i AtY:y WithRowHeight:content_row_height AndLineHeight:line_height];
		}
        
		y += row_height ;
		
		if ( y > ymax )
			break;
	}
	
	if( y < ymax )
	{
		if(y < ymin)
			y = ymin;
		
		[self SetBGColour:[base_colour_ colorWithAlphaComponent:background_alpha_]];
		[self FillRectangleX0:current_origin_.x Y0:y X1:current_top_right_.x Y1:ymax];
	}
	
	// Then draw the line dividers
	if(rowDivider)
	{
		y = if_heading ? [self standardRowHeight] : 0;
        
		for ( int i = first_row; i < row_count; i ++ )
		{
			y += [self RowHeight:i] ;
            
			if ( y > ymax )
				break;
            
			[self SetFGColour:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8]];
			[self LineX0:0 Y0:y-1 X1:content_width Y1:y-1];
			[self SetFGColour:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:0.8]];
			[self LineX0:0 Y0:y X1:content_width Y1:y];
		}
	}
    
	[self RestoreGraphicsState];	// Restores clip region
    
	// Then add the heading if there is one
	if(if_heading)
	{
		y = current_top_right_.y > 0 ? current_top_right_.y : 0;
		[self DrawRow:0 AtY:y WithRowHeight:standardRowHeight AndLineHeight:standardRowHeight];
	}
	
	[self RestoreFont];
    
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

- (int) RowHeight:(int)row;
{
	if(adaptableRowHeight)
		return [self MaxContentRowHeight:row] + [self ExpansionRowHeight:row];
	else
		return [self ContentRowHeight:row] + [self ExpansionRowHeight:row];
}

- (int) ContentRowHeight:(int)row;
{
	return standardRowHeight;
}

- (void) ClearRowHeightCache
{
	for(int i = 0 ; i < SLV_MAX_ROWS ;i++)
		maxRowHeightCache[i] = 0;
}

- (int) MaxContentRowHeight:(int)row;
{
	if(row >= 0 && row < SLV_MAX_ROWS && maxRowHeightCache[row] > 0)
		return maxRowHeightCache[row];
	
	bool heading = if_heading_ && row == 0 ;
	
	if(heading)
		return standardRowHeight;
	
	// Prepare any data specific to a derived class
	[self PrepareRow:row];
    
	int column_count = [self ColumnCount];
    
	int row_index = if_heading_ ? row - 1 : row;
	
	float row_height = [self ContentRowHeight:row];
	float maxHeight = row_height;
    
	for ( int col = 0 ; col < column_count ; col ++)
	{
		// Skip headings on child columns
		if(heading && [self ColumnType:col] == SLV_COL_CHILD_)
			continue;
		
		// Do we draw this column
		if([self ColumnUse:col] == TD_USE_FOR_NONE)
			continue;
		else if(portraitMode && [self ColumnUse:col] == TD_USE_FOR_LANDSCAPE)
			continue;
		else if(!portraitMode && [self ColumnUse:col] == TD_USE_FOR_PORTRAIT)
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
		
		int font = [self GetFontAtRow:row Col:col];
		[self UseFont:font];
		
		int cell_type = heading ? SLV_TEXT_CELL_ : [self InqCellTypeAtRow:row_index Col:col];
        
		if(cell_type  == SLV_TEXT_CELL_)
		{
			NSString * text = heading ? [[self GetHeadingAtCol:col] retain] : [[self GetCellTextAtRow:row_index Col:col] retain];
            
			if([text length] > 0)
			{
                
				float text_offset = 3;
                
				float max_width = column_width - text_offset ; // Multi-line only works with left alignment
				
				CGSize sls = [text sizeWithFont:current_font_];
				CGSize mls = [text sizeWithFont:current_font_ constrainedToSize:CGSizeMake(max_width, 300)];
				
				float thisRowHeight = row_height + mls.height - sls.height;
				
				if(thisRowHeight > maxHeight)
					maxHeight = thisRowHeight;
			}
            
            [text release];
		}
	}
	
	if(row >= 0 && row < SLV_MAX_ROWS)
		maxRowHeightCache[row] = maxHeight;
	
	return maxHeight;
}


- (int) ExpansionRowHeight:(int)row;
{
	if(expansionAllowed && [self RowExpanded:row])
		return expansionRowHeight;
	else
		return 0;
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
	return SLV_COL_STANDALONE_;
}

- (int) ColumnUse:(int)col;
{
	return TD_USE_FOR_BOTH;
}

- (int) GetFontAtRow:(int)row Col:(int)col
{
	return font_;
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

- (NSString *) GetRowTag:(int)row
{
	return nil;
}


///////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////
// User interaction routines

- (bool) FindCellAtX:(float)x Y:(float)y RowReturn:(int *)row_return ColReturn:(int *)col_return
{
	float table_height = [self TableHeight];
	float table_width = [self TableWidth];
	
	if(x < 0 || y < 0 || x > table_width || y > table_height)
	{
		return false;
	}
	
	int h = 0;
	int row = 0;
	for ( int i = 0 ; i < [self RowCount] ; i++)
	{
		h += [self RowHeight:i];
		if(h >= y)
		{
			row = i;
			break;
		}
	}
    
	int w = 0;
	int col = 0;
	for ( int i = 0 ; i < [self ColumnCount] ; i++)
	{
		// Do we draw this column
		if([self ColumnUse:i] == TD_USE_FOR_NONE)
			continue;
		else if(portraitMode && [self ColumnUse:i] == TD_USE_FOR_LANDSCAPE)
			continue;
		else if(!portraitMode && [self ColumnUse:i] == TD_USE_FOR_PORTRAIT)
			continue;
        
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
