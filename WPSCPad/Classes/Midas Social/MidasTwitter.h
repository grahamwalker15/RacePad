//
//  MidasTwitter.h
//  Midas
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MidasTwitterUser.h"
#import "MidasTwitterTweet.h"

@interface MidasTwitter : NSObject

+ (MidasTwitter *)sharedTwitter;

@property (nonatomic, readonly, getter = isLoggedIn) BOOL loggedIn;

- (void)logout;
- (void)loginWithCompletion:(void(^)())completion;

- (void)fetchUserWithHandler:(void(^)(id object, NSError *error))handler;
- (void)getURL:(NSURL *)URL parameters:(NSDictionary *)parameters handler:(void(^)(id object, NSError *error))handler;
- (void)postURL:(NSURL *)URL parameters:(NSDictionary *)parameters handler:(void(^)(id object, NSError *error))handler;

@end
