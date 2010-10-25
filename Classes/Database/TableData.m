//
//  DriverListData.m
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TableData.h"
#import "DataStream.h"

@implementation TableCell

@synthesize string;
@synthesize fg;
@synthesize bg;
@synthesize alignment;

- (void) dealloc
{
	[string release];
	[fg release];
	[bg release];
	
	[super dealloc];
}

- (TableCell *) initWithStream : (DataStream *) stream
{
	string = nil;
	fg = nil;
	bg = nil;
	
	[self updateFromStream:stream];
	
	return self;
}

- (void) updateFromStream : (DataStream *) stream
{
	[string release];
	[fg release];
	[bg release];
	
	string = [[stream PopString] retain];
	fg = [[stream PopRGB] retain];
	bg = [[stream PopRGB] retain];
	alignment = [stream PopUnsignedChar];
}

@end

@implementation TableHeader

@synthesize width;
@synthesize columnUse;
@synthesize columnType;
@synthesize columnContent;
@synthesize imageListName;

- (TableHeader *) initHWithStream : (DataStream *) stream
{
	width = [stream PopInt];
	[super initWithStream:stream];
	columnUse = [stream PopUnsignedChar];
	columnType = [stream PopUnsignedChar];
	columnContent = [stream PopUnsignedChar];
	if ( columnContent == TD_IMAGES )
		imageListName = [[stream PopString] retain];
	else
		imageListName = nil;

	return self;
}

- (void) dealloc
{
	[imageListName release];
	
	[super dealloc];
}

@end


@implementation TableData

- (void) dealloc
{
	[columnHeaders release];
	[cells release];

	[titleFields release];
	
	[super dealloc];
}

- (TableData *)init
{
	columnHeaders = [[NSMutableArray alloc] init];
	cells = [[NSMutableArray alloc] init];
	
	titleFields = [[NSMutableDictionary alloc] init];

	rows = 0;
	cols = 0;
	
	return self;
}

- (int) rows
{
	return rows;
}

- (int) cols
{
	return cols;
}

- (TableHeader *)columnHeader : (int) col
{
	if ( col < cols )
		return [columnHeaders objectAtIndex:col];
	
	return nil;
}

- (TableCell *)cell : (int) row Col : (int) col
{
	if ( row < rows && col < cols )
		return [cells objectAtIndex : row * cols + col];
	
	return nil;
}

- (NSString *)titleField:(NSString *)name {
	return [titleFields objectForKey:name];
}

- (void) loadData : (DataStream *) stream
{
	[columnHeaders removeAllObjects];
	[cells removeAllObjects];
	
	int titleCount = [stream PopInt];
	[titleFields removeAllObjects];
	for ( int t = 0; t < titleCount; t++ ) {
		NSString *key = [[stream PopString] retain];
		NSString *value = [[stream PopString] retain];
		[titleFields setObject:value forKey: key];
		[key release];
		[value release];
	}
	
	cols = [stream PopInt];
	for ( int i = 0; i < cols; i++ )
	{
		TableHeader *header = [[TableHeader alloc] initHWithStream:stream];
		[columnHeaders addObject:header];
	}
	
	rows = [stream PopInt];
	for ( int r = 0; r < rows; r++ )
		for ( int i = 0; i < cols; i++ )
		{
			TableCell *cell = [[TableCell alloc] initWithStream:stream];
			[cells addObject:cell];
		}
}

- (void) updateData : (DataStream *) stream
{
	while ( true ) {
		int row = [stream PopInt];
		if ( row < 0 )
			break;
		
		int col = [stream PopInt];
		TableCell *cell = [self cell:row Col:col];
		if ( cell != nil )
			[cell updateFromStream:stream];
	}
}

@end
