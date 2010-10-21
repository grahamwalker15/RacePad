//
//  ImageListStore.m
//  RacePad
//
//  Created by Mark Riches on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ImageListStore.h"
#import "DataStream.h"

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

- (void) loadItem: (DataStream *)stream
{
	NSString *itemName = [[stream PopString] retain];
	int size = [stream PopInt];
	NSData *data = [stream PopData:size];
	
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

- (void) loadItem: (DataStream *)stream
{
	NSString *listName = [[stream PopString] retain];
	
	ImageList *list = [dictionary objectForKey:listName];
	if ( list == nil )
	{
		list = [[ImageList alloc] init];
		[dictionary setObject: list forKey:listName];
		[list autorelease];
	}
	
	[list loadItem:stream];
	[listName release];
}

- (ImageList *)findList:(NSString *)key
{
	return [dictionary objectForKey:key];
}

@end
