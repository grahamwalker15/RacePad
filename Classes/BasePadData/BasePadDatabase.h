//
//  BasePadDatabase.h
//  BasePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImageListStore.h"
#import "TableData.h"

@interface BasePadDatabase : NSObject
{
	NSString *eventName;
	ImageListStore *imageListStore;
}

@property (retain) NSString *eventName;
@property (readonly) ImageListStore *imageListStore;

+ (BasePadDatabase *)Instance;
- (void) clearStaticData;

@end
