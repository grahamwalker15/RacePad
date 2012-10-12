//
//  MidasLoginController.h
//  MidasDemo
//
//  Created by Daniel Tull on 05/09/2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidasLoginController : NSObject

- (void)loginWithUsername:(NSString *)username
				 password:(NSString *)password
				  handler:(void(^)(BOOL success, NSError *error))handler;

@property (nonatomic, readonly, getter=isLoggedIn) BOOL loggedIn;

@end
