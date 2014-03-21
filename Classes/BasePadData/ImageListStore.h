//
//  ImageListStore.h
//  RacePad
//
//  Created by Mark Riches on 13/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;

@interface ImageList : NSObject {
	
	NSMutableDictionary *dictionary;
	
}

- (void) loadItem: (DataStream *)stream;
- (UIImage *) findItem: (NSString *)key;

@end

@interface ImageListStore : NSObject {

	NSMutableDictionary *dictionary;
	
}

- (void) loadItem: (DataStream *)stream;
- (ImageList *) findList: (NSString *) key;

@end
