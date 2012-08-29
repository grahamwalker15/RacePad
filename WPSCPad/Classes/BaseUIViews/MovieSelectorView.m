//
//  MovieSelectorView.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/22/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieSelectorView.h"

@implementation MovieSelectorView

@synthesize vertical;

- (id)initWithCoder:(NSCoder*)coder
{    
    if ((self = [super initWithCoder:coder]))
    {
		vertical = false;
	}
	
    return self;
}

//If we create it ourselves, we use -initWithFrame:
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		vertical = false;
    }
    return self;
}

- (void)dealloc
{	
    [super dealloc];
}

- (int) RowCount
{
	if(vertical)
		return [[BasePadMedia Instance] movieSourceCount];
	else
		return 2;
}

- (int) ColumnCount
{
	if(vertical)
		return 1;
	else
		return [[BasePadMedia Instance] movieSourceCount];
}

- (int) RowHeight:(int)row
{
	if(vertical)
	{
		return 150;
	}
	else 
	{
		if(row == 0)
			return 50;
		else
			return 20;
	}
}

- (int) ContentRowHeight:(int)row
{
	if(vertical)
	{
		return (int) self.bounds.size.width * 3 / 4 + 20;
	}
	else 
	{
		if(row == 0)
			return 50;
		else
			return 20;
	}
}

- (int) ColumnWidth:(int)col;
{
	if(vertical)
		return self.bounds.size.width;
	else
		return 80;
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
	return DW_CONTROL_FONT_;
}

- (int) InqCellTypeAtRow:(int)row Col:(int)col
{
	if(vertical)
	{
		return SLV_CUSTOM_DRAW_;
	}
	else
	{
		if(row == 0)
			return SLV_IMAGE_CELL_;
		else
			return SLV_TEXT_CELL_;
	}
}

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{	
	[self SetTextColour:light_grey_];
	[self SetAlignment:SLV_TEXT_CENTRE_];
	
	if(vertical)
	{
		BasePadVideoSource * movieSource = [[BasePadMedia Instance] movieSource:row];
		if(movieSource)
		{
			return [movieSource movieTag];
		}
	}
	else
	{
		if(row == 1)
		{
			BasePadVideoSource * movieSource = [[BasePadMedia Instance] movieSource:col];
			if(movieSource)
			{
				return [movieSource movieTag];
			}
		}
	}

	return nil;
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	{
		int index = vertical ? row : col;
		
		BasePadVideoSource * movieSource = [[BasePadMedia Instance] movieSource:index];
		if(row < 3 && movieSource)
		{
			UIImage * thumbnail = [movieSource movieThumbnail];
			
			if(thumbnail)
				return thumbnail;
		}
	}

	return [UIImage imageNamed:@"NoCameraThumbnail.png"];
}

-(void)	CustomDrawCellForRow:(int)row Col:(int)col AtX:(float)x Y:(float)y WithRowHeight:(float)row_height ColumnWidth:(int)column_width AndLineHeight:(float)line_height
{
	// Used only for vertical lists
	
	// Set colours and draw background
	bool selected = [self IsRowSelected:row];
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
	
	[self FillRectangleX0:x Y0:y X1:x + column_width Y1:y + row_height];
	
	// First draw text heading
	NSString * text = [[self GetCellTextAtRow:row Col:col] retain];
	
	float text_y = y - 4;
	
	if([text length] > 0)
	{				
		float w, h;
		[self GetStringBox:text WidthReturn:&w HeightReturn:&h];
			
		float xpos ;
		float text_offset = 3;
			
		if(alignment_ == SLV_TEXT_LEFT_)
			xpos = x + text_offset ;
		else if(alignment_ == SLV_TEXT_RIGHT_)
			xpos = x + column_width - w - text_offset ;
		else
			xpos = x + (column_width / 2) - (w / 2) ;
			
		if (xpos < x + text_offset)
			xpos = x + text_offset;
			
		float max_width = column_width - (xpos - x) ;					
			
		[self DrawClippedString:text AtX:xpos Y:text_y MaxWidth:max_width];
		
		text_y += h;
	}
	
	[text release];

	// Then image
	UIImage * image = [[self GetCellImageAtRow:row Col:col] retain];
				
	if(image)
	{
		float image_w = [image size].width;
		float image_h = [image size].height;
		
		if(image_w > 0 && image_h > 0)
		{
			float w = column_width - 10;
			float h = w * 3 / 4;;
			
			float xpos = x + (column_width / 2) - (w / 2) ;
			float ypos = text_y + 4;
			[self DrawImage:image InRect:CGRectMake(xpos, ypos, w, h)];
		}
			
		[image release];
	}
}

- (BasePadVideoSource *) GetMovieSourceAtIndex:(int)index
{	
	return [[BasePadMedia Instance] movieSource:index];
}


@end
