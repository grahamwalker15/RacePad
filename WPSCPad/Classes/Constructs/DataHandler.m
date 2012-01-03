//
//  DataHandler.m
//  RacePad
//
//  Created by Mark Riches
//  Oct 2010
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "DataHandler.h"
#import "BufferedDataStream.h"
#import "FileDataStream.h"

@implementation DataHandler

- (id) init {
	stream = nil;
	return self;
}

- (id) initWithPath: (NSString *) path {
	stream = [[FileDataStream alloc] initWithPath:path];
	return self;
}

- (void) dealloc {
	[stream release];
	[super dealloc];
}

- (void) closeStream {
	[stream closeStream];
}

- (void) newTransfer:(int)size {
	[stream release];
	stream = [[BufferedDataStream alloc] initWithSize:size];
	stream.versionNumber = versionNumber;
}

- (void) setStreamPos: (int) pos {
	[stream setPos:pos];
}

- (DataStream *) getStream {
	return stream;
}

- (void) handleCommand {
	// Override me
}

@end
	

