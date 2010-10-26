//
//  DataStream.h
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DataStream : NSObject
{
	int index;
}


- (id)init;
- (int) inqIndex;
- (void *) inqBuffer;
- (void) setPos: (int) pos;
- (void) closeStream;

- (bool) canPop: (int)size;
- (bool) PopBool;
- (unsigned char) PopUnsignedChar;
- (int) PopInt;
- (float) PopFloat;
- (NSString *) PopString;
- (UIColor *)PopRGB;
- (UIColor *)PopRGBA;
- (void) PopBuffer: (unsigned char *)buffer Length:(int)length;
- (NSData *) PopData: (int)size;

@end
