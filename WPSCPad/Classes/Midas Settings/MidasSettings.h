//
//  MidasSettings.h
//  Midas
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidasSettings : NSObject

+ (MidasSettings *)sharedSettings;
- (void)waitForSettings:(void(^)())handler;

@property (nonatomic, readonly) NSArray *hashtag;
@property (nonatomic, readonly) NSString *facebookPostID;
@property (nonatomic, readonly) NSDate *raceStartDate;
@property (nonatomic, readonly) NSDictionary *logins;

@end
