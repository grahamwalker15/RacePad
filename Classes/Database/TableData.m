//
//  DriverListData.m
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "TableData.h"
#import "RacePadClientSocket.h"

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

- (TableCell *) initWithSocket : (RacePadClientSocket *) socket
{
	string = nil;
	fg = nil;
	bg = nil;
	
	[self updateFromSocket:socket];
	
	return self;
}

- (void) updateFromSocket : (RacePadClientSocket *) socket
{
	[string release];
	[fg release];
	[bg release];
	
	string = [[socket PopString] retain];
	fg = [[socket PopRGB] retain];
	bg = [[socket PopRGB] retain];
	alignment = [socket PopUnsignedChar];
}

@end

@implementation TableHeader

@synthesize width;
@synthesize columnUse;
@synthesize columnType;
@synthesize columnContent;
@synthesize imageListName;

- (TableHeader *) initHWithSocket : (RacePadClientSocket *) socket
{
	width = [socket PopInt];
	[super initWithSocket:socket];
	columnUse = [socket PopUnsignedChar];
	columnType = [socket PopUnsignedChar];
	columnContent = [socket PopUnsignedChar];
	if ( columnContent == TD_IMAGES )
		imageListName = [[socket PopString] retain];
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
	
	[super dealloc];
}

- (TableData *)init
{
	columnHeaders = [[NSMutableArray alloc] init];
	cells = [[NSMutableArray alloc] init];
	
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

- (void) loadData : (RacePadClientSocket *) socket
{
	[columnHeaders removeAllObjects];
	[cells removeAllObjects];
	
	cols = [socket PopInt];
	for ( int i = 0; i < cols; i++ )
	{
		TableHeader *header = [[TableHeader alloc] initHWithSocket:socket];
		[columnHeaders addObject:header];
	}
	
	rows = [socket PopInt];
	for ( int r = 0; r < rows; r++ )
		for ( int i = 0; i < cols; i++ )
		{
			TableCell *cell = [[TableCell alloc] initWithSocket:socket];
			[cells addObject:cell];
		}
}

- (void) updateData : (RacePadClientSocket *) socket
{
	while ( true ) {
		int row = [socket PopInt];
		if ( row < 0 )
			break;
		
		int col = [socket PopInt];
		TableCell *cell = [self cell:row Col:col];
		if ( cell != nil )
			[cell updateFromSocket:socket];
	}
}

@end
