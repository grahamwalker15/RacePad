//
//  MovieSelectorView.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/22/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "MovieSelectorView.h"

@implementation MovieSelectorView

- (void)dealloc
{	
    [super dealloc];
}

- (int) RowCount
{
	return 2;
}

- (int) ColumnCount
{
	return [[BasePadMedia Instance] movieSourceCount];
}

- (int) RowHeight:(int)row
{
	if(row == 0)
		return 50;
	else
		return 20;
}

- (int) ContentRowHeight:(int)row
{
	if(row == 0)
		return 50;
	else
		return 20;
}

- (int) ColumnWidth:(int)col;
{
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
	if(row == 0)
		return SLV_IMAGE_CELL_;
	else
		return SLV_TEXT_CELL_;
}

- (NSString *) GetCellTextAtRow:(int)row Col:(int)col
{	
	if(row == 1)
	{
		[self SetTextColour:light_grey_];
		[self SetAlignment:SLV_TEXT_CENTRE_];
		
		BasePadVideoSource * movieSource = [[BasePadMedia Instance] movieSource:col];
		if(movieSource)
		{
			return [movieSource movieTag];
		}
	}
	
	return nil;
}

- (UIImage *) GetCellImageAtRow:(int)row Col:(int)col
{
	{
		BasePadVideoSource * movieSource = [[BasePadMedia Instance] movieSource:col];
		if(movieSource)
		{
			return [movieSource movieThumbnail];
		}
	}
	
	return nil;
}

- (BasePadVideoSource *) GetMovieSourceAtCol:(int)col
{	
	return [[BasePadMedia Instance] movieSource:col];
}


@end
