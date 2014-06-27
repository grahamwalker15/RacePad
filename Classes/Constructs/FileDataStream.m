//
//  FileDataStream.m
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "FileDataStream.h"

@implementation FileDataStream

-(id) initWithPath: (NSString *) path
{
	file = fopen ( [path UTF8String], "rb" );
	return self;
}

- (void) dealloc {
	if ( file )
		fclose ( file );
	[super dealloc];
}

- (void) closeStream {
	if ( file )
		fclose(file);
	file = nil;
}

- (void *)inqBuffer {
	return nil;
}

- (void) setPos: (int) pos {
	if (file) {
		fseek(file, pos, SEEK_SET);
	}
}

- (bool)canPop:(int)size {
	if ( file && !feof(file) )
		return true;
	
	return false;
}

- (bool)PopBool
{
	bool t = false;
	unsigned char c;
	if ( file )
	{
		fread(&c, 1, 1, file);
		t = c > 0;
	}
	index += 1;
	
	return t;
}

- (unsigned char)PopUnsignedChar 
{
	unsigned char c = 0;
	if ( file )
		fread(&c, 1, 1, file);
	index += 1;
	
	return c;
}

- (int)PopInt 
{
	int t = 0;
	if ( file )
	{
		fread(&t, 1, sizeof(int), file);
		t = ntohl ( t );
	}
	index += sizeof ( int );
	
	return t;
}

- (short)PopShort
{
	short t = 0;
	if ( file )
	{
		fread(&t, 1, sizeof(short), file);
		t = ntohs ( t );
	}
	index += sizeof ( short );
	
	return t;
}

- (float)PopFloat
{
	float t = 0;
	if ( file )
	{
		int i;
		fread(&i, 1, sizeof(int), file);
		i = ntohl ( i );
		t = *(float *)(&i);
	}
	index += sizeof ( float );
	
	return t;
}

- (NSString *)PopString
{
	int size = [self PopInt];
	char *s = malloc ( size + 1 );
	if ( file ) {
		fread ( s, 1, size, file );
		s[size] = 0;
	}
	else {
		s[0] = 0;
	}

	NSString *t = [NSString stringWithUTF8String:s];
	free ( s );
	return t;
}

- (void) PopBuffer: (unsigned char *)buffer Length:(int)length
{
	if (file) {
		fread(buffer, 1, length, file);
	}
	index += length;
}

- (NSData *) PopData: (int)size
{
	unsigned char *buffer = malloc(size);
	[self PopBuffer:buffer Length:size];
	NSData *data = [NSData dataWithBytesNoCopy:buffer length:size];
	
	return data;
}


@end
	

