//
//  DataHandler.h
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DataStream;

@interface DataHandler : NSObject
{
	DataStream *stream;
}


- (id)init;
- (id)initWithPath: (NSString *)path;

- (DataStream *) getStream;

- (void) newTransfer: (int) size;
- (void) setStreamPos: (int) pos;
- (void) handleCommand;

@end
