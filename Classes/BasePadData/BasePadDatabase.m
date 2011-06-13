//
//  BasePadDatabase.m
//  BasePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "BasePadDatabase.h"

@implementation BasePadDatabase

static BasePadDatabase *instance = nil;

+ (BasePadDatabase *)Instance
{
	return instance;
}

@synthesize eventName;
@synthesize imageListStore;

- (BasePadDatabase *)init
{
	if ( [super init] == self )
	{
		instance = self;
	
		imageListStore = [[ImageListStore alloc] init];
	}

	return self;
}

- (void) dealloc
{
	[imageListStore release];
	
	[super dealloc];
}

-(void) clearStaticData
{
	// Override Me
}

@end
