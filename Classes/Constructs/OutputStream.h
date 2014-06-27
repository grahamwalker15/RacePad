//
//  OutputStream.h
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OutputStream : NSObject
{
	FILE *saveFile;
}


- (id)initWithPath: (NSString *) path;
- (void) saveBool: (bool) v;
- (void) saveUnsignedChar: (unsigned char) v;
- (void) saveInt: (int) v;
- (void) saveFloat: (float) v;
- (void) saveString: (NSString *)v;
- (void) saveRGB :(UIColor *)v;
- (void) saveRGBA :(UIColor *)v;

@end
