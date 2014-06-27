//
//  FileDataStream.h
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStream.h"

@interface FileDataStream : DataStream
{
	FILE *file;
}


- (id)initWithPath: (NSString *) path;
- (void *)inqBuffer;

- (void) setPos: (int) pos;

- (bool) canPop: (int)size;
- (bool) PopBool;
- (unsigned char) PopUnsignedChar;
- (short) PopShort;
- (int) PopInt;
- (float) PopFloat;
- (NSString *) PopString;
- (void) PopBuffer: (unsigned char *)buffer Length:(int)length;
- (NSData *) PopData: (int) size;

@end
