//
//  DataStream.m
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DataStream.h"

@implementation DataStream

@synthesize versionNumber;

-(id) init
{
	index = 0;
	versionNumber = 0;
	return self;
}

- (int) inqIndex {
	return index;
}

- (void *)inqBuffer {
	return nil;
}

- (void) setPos: (int)pos {
	// Do nothing
}

- (void) closeStream {
	// Override me
}

- (bool) canPop: (int)size {
	return false;
}

- (bool) PopBool {
	return false;
}

- (unsigned char) PopUnsignedChar {
	return 0;
}

- (short) PopShort {
    return 0;
}

- (int) PopInt {
	return 0;
}

- (float) PopFloat {
	return 0;
}
- (NSString *) PopString {
	return nil;
}

- (UIColor *)PopRGB
{
	unsigned char r = [self PopUnsignedChar];
	unsigned char g = [self PopUnsignedChar];
	unsigned char b = [self PopUnsignedChar];
	
	return [[[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:1.0] autorelease];
}

- (UIColor *)PopRGBA
{
	unsigned char r = [self PopUnsignedChar];
	unsigned char g = [self PopUnsignedChar];
	unsigned char b = [self PopUnsignedChar];
	unsigned char a = [self PopUnsignedChar];
	
	return [[[UIColor alloc] initWithRed:(CGFloat)r/255.0 green:(CGFloat)g/255.0 blue:(CGFloat)b/255.0 alpha:(CGFloat)a/255.0] autorelease];
}

- (void) PopBuffer: (unsigned char *)buffer Length:(int)length {
}

- (NSData *) PopData: (int)size {
	return nil;
}
@end
	

