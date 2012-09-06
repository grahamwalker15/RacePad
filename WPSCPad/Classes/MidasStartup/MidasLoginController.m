//
//  MidasLoginController.m
//  MidasDemo
//
//  Created by Daniel Tull on 05/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasLoginController.h"
#import <Security/Security.h>
#import "MidasSettings.h"

NSString *const MidasLoginControllerPasswordKey = @"MidasLoginControllerPasswordKey";
NSString *const MidasLoginControllerUsernameKey = @"MidasLoginControllerUsernameKey";

@implementation MidasLoginController

- (BOOL)isLoggedIn {
	return ([self _secureValueForKey:MidasLoginControllerUsernameKey] != nil);
}

- (void)loginWithUsername:(NSString *)username
				 password:(NSString *)password
				  handler:(void(^)(BOOL success, NSError *error))handler {

	if (handler == NULL) return;
	
	MidasSettings *settings = [MidasSettings sharedSettings];
	[settings waitForSettings:^{
		
		NSDictionary *logins = [settings logins];
		if ([password isEqualToString:[logins objectForKey:username]]) {
			[self _setSecureValue:username forKey:MidasLoginControllerUsernameKey];
			[self _setSecureValue:password forKey:MidasLoginControllerPasswordKey];
			handler(YES, nil);
			return;
		}
		
		NSError *error = [NSError errorWithDomain:@"MidasLogin" code:404 userInfo:@{ NSLocalizedDescriptionKey : NSLocalizedString(@"midas.login.failure", @"Please try again") }];
		handler(NO, error);		
	}];
}

- (void)_setSecureValue:(NSString *)value forKey:(NSString *)key {
	[self _removeSecureValueForKey:key];
	NSMutableDictionary *query = [self _queryForKey:key];
	[query setObject:[value dataUsingEncoding:NSUTF8StringEncoding] forKey:(__bridge id)kSecValueData];
	[query setObject:(__bridge id)kSecAttrAccessibleAfterFirstUnlock forKey:(__bridge id)kSecAttrAccessible];
	SecItemAdd((__bridge CFDictionaryRef)query, NULL);
}

- (NSString *)_secureValueForKey:(NSString *)key {	
	NSMutableDictionary *query = [self _queryForKey:key];
	[query setObject:(__bridge id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
	[query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
	CFTypeRef result = NULL;
	SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
	if (!result) return nil;
	return [[NSString alloc] initWithData:(__bridge_transfer NSData *)result encoding:NSUTF8StringEncoding];
}

- (void)_removeSecureValueForKey:(NSString *)key {
	NSMutableDictionary *query = [self _queryForKey:key];
    SecItemDelete((__bridge CFDictionaryRef)query);
}

- (NSMutableDictionary *)_queryForKey:(NSString *)key {
	NSMutableDictionary *query = [NSMutableDictionary new];
    [query setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
	[query setObject:@"Midas" forKey:(__bridge id)kSecAttrService];
	[query setObject:key forKey:(__bridge id)kSecAttrAccount];
	return query;
}

@end
