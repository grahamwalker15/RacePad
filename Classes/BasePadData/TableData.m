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

- (TableCell *) initWithStream : (DataStream *) stream Colours: (UIColor **)colours ColoursCount: (int)coloursCount
{
	string = nil;
	fg = nil;
	bg = nil;
	
	[self updateFromStream:stream Colours:colours ColoursCount:coloursCount];
	
	return self;
}

- (void) updateFromStream : (DataStream *) stream Colours: (UIColor **)colours ColoursCount: (int)coloursCount
{
	[string release];
	[fg release];
	[bg release];
	
	string = [[stream PopString] retain];
	unsigned char index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		fg = [colours[index] retain];
	else
		fg = nil;
	index = [stream PopUnsignedChar];
	if ( index < coloursCount )
		bg = [colours[index] retain];
	else
		bg = nil;
	alignment = [stream PopUnsignedChar];
}

@end

@implementation TableHeader

@synthesize width;
@synthesize columnUse;
@synthesize columnType;
@synthesize columnContent;
@synthesize imageListName;

- (TableHeader *) initHWithStream : (DataStream *) stream Colours: (UIColor **)colours ColoursCount: (int)colourCount
{
	if(self = [super init])
	{
		width = [stream PopInt];
		[super initWithStream:stream Colours:colours ColoursCount:colourCount];
		columnUse = [stream PopUnsignedChar];
		columnType = [stream PopUnsignedChar];
		columnContent = [stream PopUnsignedChar];
		if ( columnContent == TD_IMAGES )
			imageListName = [[stream PopString] retain];
		else
			imageListName = nil;
	}

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
	
	if ( colours )
	{
		for ( int c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}

	[super dealloc];
}

- (TableData *)init
{
	if(self = [super init])
	{
		columnHeaders = [[NSMutableArray alloc] init];
		cells = [[NSMutableArray alloc] init];
	
		titleFields = [[NSMutableDictionary alloc] init];

		rows = 0;
		cols = 0;
	}
	
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
	
	int c;
	if ( colours )
	{
		for ( c = 0; c < coloursCount; c++ )
			[colours[c] release];
		free ( colours );
	}
	
	coloursCount = [stream PopInt];
	colours = malloc ( sizeof (UIColor *) * coloursCount );
	for ( c = 0; c < coloursCount; c++ )
		colours[c] = NULL;
	for ( c = 0; c < coloursCount; c++ ) {
		unsigned char index = [stream PopUnsignedChar];
		UIColor *colour = [[stream PopRGB] retain];
		if ( index < coloursCount )
			colours[index] = colour;
		else
			[colour release];
	}

	cols = [stream PopInt];
	for ( int i = 0; i < cols; i++ )
	{
		TableHeader *header = [[TableHeader alloc] initHWithStream:stream Colours:colours ColoursCount:coloursCount];
		[columnHeaders addObject:header];
		[header release];
	}
	
	rows = [stream PopInt];
	for ( int r = 0; r < rows; r++ )
		for ( int i = 0; i < cols; i++ )
		{
			TableCell *cell = [[TableCell alloc] initWithStream:stream Colours:colours ColoursCount:coloursCount];
			[cells addObject:cell];
			[cell release];
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
			[cell updateFromStream:stream Colours:colours ColoursCount:coloursCount];
	}
}

@end
