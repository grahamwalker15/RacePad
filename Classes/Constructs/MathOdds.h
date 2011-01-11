//
//  MathOdds.h
//  RacePad
//
//  Created by Gareth Griffith on 1/4/11.
//  Copyright 2011 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <math.h>

#define DegreesToRadians(t) t * M_PI / 180.0
#define RadiansToDegrees(t) t * 180.0 / M_PI

@interface MathOdds : NSObject
{

}

+ (float) Average:(float *) values Count:(int)count;
+ (float) StandardDeviation:(float *) values Count:(int)count;

+ (float) NormalizeValue:(float)x OnScale:(float)x1 To:(float)x2;
+ (float) FromNormalizeValue:(float)x OnScale:(float)x1 To:(float)x2;

+ (float) CalcGradientWithDX:(float)dx DY:(float)dy;

@end

/*
@interface RandomNumber : NSObject
{
	unsigned int x, y, z;	
}

- (void) Init(int seed)
	{
		x = seed * 8 + 3;
		y = seed * 2 + 1;
		z = seed | 1;
	}

	
- (unsigned int) Value
	{
		unsigned int tmp = x * y;
		x = y;
		y = tmp;
		z = (z & 65535) * 30903 + (z >> 16);
		return y + z;
	}
		
	// Return a float in the range 0..1
- (float) FloatValue
	{
		return (Value() & 32767) / 32767.0f;
	}
	
	// Return a vaguely Gaussian-distributed float in the range -1..1
- (float) GaussianValue();
	
@end
*/
	
