//
//  ElapsedTime.m
//  RacePad
//
//  Created by Mark Riches on 20/10/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "ElapsedTime.h"
#include <sys/time.h>


@implementation ElapsedTime

- (id) init {
	[self reset];
	return self;
}

- (void) reset {
	struct timeval t;
	gettimeofday ( &t, NULL );
	start = (double)t.tv_sec + (double)t.tv_usec * 0.000001f;
}

- (double) value {
	struct timeval t;
	gettimeofday ( &t, NULL );
	double current = (double)t.tv_sec + (double)t.tv_usec * 0.000001f;
	double d = current - start;
	return d;
}

@end
