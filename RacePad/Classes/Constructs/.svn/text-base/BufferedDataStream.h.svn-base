//
//  BufferedDataStream.h
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStream.h"

@interface BufferedDataStream : DataStream
{
	NSMutableData *data;
}


- (id)initWithSize: (int) size;
- (void *)inqBuffer;

- (bool) canPop: (int)size;
- (bool) PopBool;
- (unsigned char) PopUnsignedChar;
- (int) PopInt;
- (float) PopFloat;
- (NSString *) PopString;
- (void) PopBuffer: (unsigned char *)buffer Length:(int)length;
- (NSData *) PopData: (int)size;

- (void) SaveToFile: (NSString *)path;

@end
