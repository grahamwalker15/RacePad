//
//  ImageListStore.m
//  RacePad
//
//  Created by Mark Riches on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageListStore.h"
#import "RacePadClientSocket.h"

@implementation ImageList

- (id) init
{
	dictionary = [[NSMutableDictionary alloc] init];
	return [super init];	
}

- (void) dealloc
{
	[dictionary release];
	[super dealloc];
}

- (void) loadItem: (RacePadClientSocket *)socket
{
	NSString *itemName = [[socket PopString] retain];
	int size = [socket PopInt];
	unsigned char *buffer = malloc(size);
	[socket PopBuffer:buffer Length:size];
	NSData *data = [NSData dataWithBytesNoCopy:buffer length:size];
	
	UIImage *item = [[UIImage alloc] initWithData:data];
	
	// [data release];
	
	[dictionary setObject:item forKey:itemName];
	[itemName release];
}

- (UIImage *)findItem:(NSString *)key
{
	return [dictionary objectForKey:key];
}

@end

@implementation ImageListStore

- (id) init
{
	dictionary = [[NSMutableDictionary alloc] init];
	return [super init];	
}

- (void) dealloc
{
	[dictionary release];
	[super dealloc];
}

- (void) loadItem: (RacePadClientSocket *)socket
{
	NSString *listName = [[socket PopString] retain];
	
	ImageList *list = [dictionary objectForKey:listName];
	if ( list == nil )
	{
		list = [[ImageList alloc] init];
		[dictionary setObject: list forKey:listName];
		[list autorelease];
	}
	
	[list loadItem:socket];
	[listName release];
}

- (ImageList *)findList:(NSString *)key
{
	return [dictionary objectForKey:key];
}

@end
