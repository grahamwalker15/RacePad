//
//  RacePadPrefs.m
//  RacePad
//
//  Created by Mark Riches on 04/11/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RacePadPrefs.h"


@implementation RacePadPrefs

static RacePadPrefs *instance = nil;

+ (RacePadPrefs *)Instance
{
	if ( instance == nil )
		instance = [[RacePadPrefs alloc] init];
	return instance;
}

- (id) init
{
	if ( [super init] == self )
	{
		NSString *errorDesc = nil;
		NSPropertyListFormat format;
		NSString *plistPath;
		NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
																  NSUserDomainMask, YES) objectAtIndex:0];
		plistPath = [rootPath stringByAppendingPathComponent:@"Preferences.plist"];
		NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
		prefs = (NSMutableDictionary *)[[NSPropertyListSerialization
														   propertyListFromData:plistXML
														   mutabilityOption:NSPropertyListMutableContainersAndLeaves
														   format:&format
														   errorDescription:&errorDesc] retain];
		if (!prefs) {
			NSLog(@"Error reading plist: %@, format: %d", errorDesc, format);
			prefs = [[NSMutableDictionary alloc] init];
		}
	}
	
	return self;
}

- (void) dealloc 
{
	[prefs release];
	[super dealloc];
}

- (void) setPref:(NSString *)key Value:(id)value
{
	[prefs setObject:value forKey:key];
}

- (id) getPref:(NSString *)key
{
	return [prefs objectForKey:key];
}

- (void) save
{
    NSString *error;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"Preferences.plist"];
	
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:prefs
																   format:NSPropertyListXMLFormat_v1_0
														 errorDescription:&error];
    if(plistData) {
        [plistData writeToFile:plistPath atomically:YES];
    }
    else {
        [error release];
    }
}


@end
