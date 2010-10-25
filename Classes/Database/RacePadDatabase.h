//
//  RacePadDatabase.h
//  RacePad
//
//  Created by Mark Riches on 11/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TableData.h"
#import "TrackMap.h"
#import "ImageListStore.h"

@interface RacePadDatabase : NSObject
{
	NSString *eventName;
	TableData *driverListData;
	TableData *driverData;
	TrackMap *trackMap;
	ImageListStore *imageListStore;
}

@property (retain) NSString *eventName;

+ (RacePadDatabase *)Instance;

- (TableData *) driverListData;
- (TableData *) driverData;
- (TrackMap *) trackMap;
- (ImageListStore *) imageListStore;

@end
