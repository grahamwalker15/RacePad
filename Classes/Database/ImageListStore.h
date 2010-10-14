//
//  ImageListStore.h
//  RacePad
//
//  Created by Mark Riches on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RacePadClientSocket;

@interface ImageList : NSObject {
	
	NSMutableDictionary *dictionary;
	
}

- (void) loadItem: (RacePadClientSocket *)socket;
- (UIImage *) findItem: (NSString *)key;

@end

@interface ImageListStore : NSObject {

	NSMutableDictionary *dictionary;
	
}

- (void) loadItem: (RacePadClientSocket *)socket;
- (ImageList *) findList: (NSString *) key;

@end
