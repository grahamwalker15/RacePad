//
//  MidasCountdownTimer.h
//  Midas
//
//  Created by Daniel Tull on 12.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidasCountdownTimer : NSObject

- (id)initWithTimeIntervalToEvent:(NSTimeInterval)timeInterval;

@property (nonatomic, copy) void(^timeChangedHandler) (NSUInteger days, NSUInteger hours, NSUInteger minutes, NSUInteger seconds);
@property (nonatomic, copy) void(^eventDateHandler) ();

@end