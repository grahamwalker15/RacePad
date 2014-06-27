//
//  FileDataStream.m
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "OutputStream.h"

@implementation OutputStream

-(id) initWithPath: (NSString *) path
{
	saveFile = fopen ( [path UTF8String], "wb" );
	return self;
}

- (void) dealloc {
	if ( saveFile )
		fclose ( saveFile );
	[super dealloc];
}

- (void) closeStream {
	if ( saveFile )
		fclose(saveFile);
	saveFile = nil;
}

- (void)saveBool :(bool) v
{
	unsigned char c;
    if ( v )
        c = 1;
    else
        c = 0;
	if ( saveFile )
		fwrite(&c, 1, 1, saveFile);
}

- (void)saveUnsignedChar :(unsigned char) v
{
	if ( saveFile )
		fwrite(&v, 1, 1, saveFile);
}

- (void)saveInt :(int) v
{
	if ( saveFile )
	{
        int t = ntohl(v);
		fwrite(&t, 1, sizeof(int), saveFile);
	}
}

- (void)saveFloat :(float) v
{
	if ( saveFile )
	{
		int t = *(int *)(&v);
        t = ntohl(t);
		fwrite(&t, 1, sizeof(int), saveFile);
	}
}

- (void)saveString :(NSString *) v
{
    [self saveInt:[v length]];
    if ( saveFile )
    {
        const char *s = [v UTF8String];
        
        fwrite(s, 1, strlen(s), saveFile);
    }
}

- (void)saveRGB :(UIColor *)v
{
	CGFloat r, g, b, a;
    [v getRed:&r green:&g blue:&b alpha:&a];
    unsigned char ur, ug, ub, ua;
    ur = 255 * r;
    ug = 255 * g;
    ub = 255 * b;
    ua = 255 * a;
    [self saveUnsignedChar:ur];
    [self saveUnsignedChar:ug];
    [self saveUnsignedChar:ub];
}

- (void)saveRGBA :(UIColor *)v
{
	CGFloat r, g, b, a;
    [v getRed:&r green:&g blue:&b alpha:&a];
    unsigned char ur, ug, ub, ua;
    ur = 255 * r;
    ug = 255 * g;
    ub = 255 * b;
    ua = 255 * a;
    [self saveUnsignedChar:ur];
    [self saveUnsignedChar:ug];
    [self saveUnsignedChar:ub];
    [self saveUnsignedChar:ua];
}

@end
	

