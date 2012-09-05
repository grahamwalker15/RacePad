//
//  MidasLoginController.m
//  MidasDemo
//
//  Created by Daniel Tull on 05/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasLoginController.h"

@implementation MidasLoginController

- (NSDictionary *)logins {
	return @{ @"user" : @"password" };
}

- (void)loginWithUsername:(NSString *)username
				 password:(NSString *)password
				  handler:(void(^)(BOOL success, NSError *error))handler {

	if (handler == NULL) return;

	NSDictionary *logins = [self logins];
	if ([password isEqualToString:[logins objectForKey:username]]) {
		handler(YES, nil);
		return;
	}

	NSError *error = [NSError errorWithDomain:@"MidasLogin" code:404 userInfo:@{ NSLocalizedDescriptionKey :NSLocalizedString(@"MidasLoginFail", @"Please try again") }];

	handler(NO, error);
}

@end
