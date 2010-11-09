//
//  TableDataView.m
//  RacePad
//
//  Created by Gareth Griffith on 10/12/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "TableDataView.h"

#import "RacePadDatabase.h"
#import "ImageListStore.h"
#import "TableData.h"


@implementation TableDataView

@synthesize table_data_;

- (void)dealloc
{
	[table_data_ release];
	
    [super dealloc];
}

- (int) RowCount
{
	if(table_data_)
		return [self IfHeading] ? [table_data_ rows] + 1 :  [table_data_ rows];
	else
		return [super RowCount];
}

- (int) ColumnCount
{
	if(table_data_)
		return [table_data_ cols];
	else
		return [super ColumnCount];
}

- (int) ColumnWidth:(int)col;
{
	if(table_data_)
	{
		TableHeader *columnHeader = [table_data_ columnHeader:col];
		
		if ( columnHeader )
			return [columnHeader width];
		else
			return 30;	// Sensible default even though it should never be called
	}
	else
	{
		return [super ColumnWidth:col];
	}

}

- (int) ColumnType:(int)col;
{
	if(table_data_)
	{
		TableHeader *columnHeader = [table_data_ columnHeader:col];
		if (columnHeader)
		{
			return [columnHeader columnType];
		}
	}
	
	// Reach here if data could not be found in table
	return SLV_COL_STANDALONE_;
}

- (int) ColumnUse:(int)col;
{
	if(table_data_)
	{
		TableHeader *columnHeader = [table_data_ columnHeader:col];
		if (columnHeader)
		{
			return [columnHeader columnUse];
		}
	}
	
	// Reach here if data could not be found in table
	return TD_USE_FOR_BOTH;
}

- (int) InqCellTypeAtRow:(int)row Col:(int)col
{
	if(table_data_)
	{
		TableHeader *columnHeader = [table_data_ columnHeader:col];
		if (columnHeader)
		{
			return [columnHeader columnContent];
		}
	}
	
	// Reach here if data could not be found in table
	return SLV_TEXT_CELL_;
}

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{
	if(table_data_)
	{
		[self SetTextColour:white_];
		[self SetBackgroundColour:black_];
		
		TableCell *cell = [table_data_ cell:row Col:col];
		
		if ( cell )
		{
			[self SetTextColour:[cell fg]];
			[self SetBackgroundColour:[cell	bg]];
			[self SetAlignment:[cell alignment]];
			return [cell string];
		}
	}
	
	return nil;
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	if(table_data_)
	{
		[self SetBackgroundColour:black_];
		
		TableHeader *columnHeader = [table_data_ columnHeader:col];
		TableCell *cell = [table_data_ cell:row Col:col];
		
		if (cell && columnHeader)
		{
			NSString * image_list_name = [columnHeader imageListName];
			NSString * name = [cell string];
			
			[self SetBackgroundColour:[cell	bg]];
			
			if(name && [name length] > 0 && image_list_name && [image_list_name length] > 0)
			{			
				RacePadDatabase *database = [RacePadDatabase Instance];
				ImageListStore * image_store = [database imageListStore];
				
				if (image_store)			
				{
					ImageList *image_list = [image_store findList:image_list_name];
					
					if (image_list)
					{
						UIImage *image = [image_list findItem:name];						
						return image;						
					}
				}
			}
		}
	}
	
	return nil;

}

- (UIImage *) GetCellClientImageAtRow:(int)row Col:(int)col
{
	if(table_data_)
	{
		[self SetBackgroundColour:black_];
		
		TableHeader *columnHeader = [table_data_ columnHeader:col];
		TableCell *cell = [table_data_ cell:row Col:col];
		
		if (cell && columnHeader)
		{
			[self SetBackgroundColour:[cell	bg]];
			
			return [UIImage imageNamed:[cell string]];
		}
	}
	
	return nil;
	
}

- (NSString *) GetHeadingAtCol:(int)col
{
	if(table_data_)
	{
		TableHeader *columnHeader = [table_data_ columnHeader:col];
		if ( columnHeader )
		{
			[self SetTextColour:[columnHeader fg]];
			[self SetBackgroundColour:[columnHeader	bg]];
			[self SetAlignment:[columnHeader alignment]];
			return [columnHeader string];
		}
	}
	
	return nil;
	
}

@end
