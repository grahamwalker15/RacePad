//
//  BufferedDataStream.m
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "BufferedDataStream.h"

@implementation BufferedDataStream

-(id) initWithSize: (int) size
{
	[super init];
	data = [[NSMutableData alloc]initWithLength:size];
	return self;
}

- (void) dealloc {
	[data release];
	[super dealloc];
}

- (void *)inqBuffer {
	return [data mutableBytes];
}

- (bool)canPop:(int)size {
	if ( [data length] - index >= size )
		return true;
	
	return false;
}

- (bool)PopBool
{
	bool t = ((UInt8 *)[data mutableBytes])[index] > 0;
	index += 1;
	
	return t;
}

- (unsigned char)PopUnsignedChar 
{
	int t = ((unsigned char *)[data mutableBytes])[index];
	index += 1;
	
	return t;
}

- (int)PopInt 
{
	int *buf = (int *)([data mutableBytes] + index);
	int t = ntohl ( *buf );
	index += sizeof ( int );
	
	return t;
}

- (float)PopFloat
{
	float *buf = (float *)([data mutableBytes] + index);
	unsigned int *ip = (unsigned int *)([data mutableBytes] + index);
	*ip = ntohl ( *ip);
	float t = ( *buf );
	index += sizeof ( float );
	
	return t;
}

- (NSString *)PopString
{
	int size = [self PopInt];
	char *s = malloc ( size + 1 );
	memcpy ( s, [data mutableBytes] + index, size );
	index += size;
	s[size] = 0;
	NSString *t = [NSString stringWithUTF8String:s];
	free ( s );
	return t;
}

- (void) PopBuffer: (unsigned char *)buffer Length:(int)length
{
	memcpy ( buffer, [data mutableBytes] + index, length );
	index += length;
}

- (NSData *) PopData: (int) size
{
	NSData *d = [NSData dataWithBytes:[data mutableBytes] + index length: size];
	index = [data length];
	
	return d;
}

@end
	

