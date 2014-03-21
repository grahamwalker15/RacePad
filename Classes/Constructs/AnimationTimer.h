//
//  AnimationTimer.h
//  RacePad
//
//  Created by Gareth Griffith on 12/7/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ElapsedTime;

@interface AnimationTimer : NSObject
{
	NSTimer * animationTimer;
	float duration;
	id target;
	SEL loopSelector;
	SEL finishSelector;
	
	ElapsedTime * elapsedTime;
}

- (id) initWithDuration:(float)durationIn Target:(id)targetIn LoopSelector:(SEL)loopSelectorIn FinishSelector:(SEL)finishSelectorIn;
- (void) animationTimerCallback: (NSTimer *)theTimer;
- (void) kill;

@end
