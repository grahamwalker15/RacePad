//
//  AnimationTimer.m
//  RacePad
//
//  Created by Gareth Griffith on 12/7/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import "AnimationTimer.h"
#import "ElapsedTime.h"

@implementation AnimationTimer

- (id) initWithDuration:(float)durationIn Target:(id)targetIn LoopSelector:(SEL)loopSelectorIn FinishSelector:(SEL)finishSelectorIn
{
	if(self = [super init])
	{
		duration = durationIn;
		target = targetIn;
		loopSelector = loopSelectorIn;
		finishSelector = finishSelectorIn;
		
		elapsedTime = [[ElapsedTime alloc] init];
		animationTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0) target:self selector:@selector(animationTimerCallback:) userInfo:nil repeats:YES];
	}
	
	return self;
}

- (void) animationTimerCallback: (NSTimer *)theTimer
{
	float timeNow = [elapsedTime value];
	if(timeNow >= duration)
	{
		[animationTimer invalidate];
		[elapsedTime release];
		[target performSelector:finishSelector];
	}
	else
	{
		float alpha = timeNow / duration;
		[target performSelector:loopSelector withObject:(id)(&alpha)];
	}
}
	   
- (void) kill
{
	[animationTimer invalidate];
	[elapsedTime release];
	[target performSelector:finishSelector];
}

@end
