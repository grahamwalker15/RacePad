//
//  MidasTwitter.m
//  Midas
//
//  Created by Daniel Tull on 27/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasTwitter.h"
#import <DCTAuth/DCTAuth.h>

@implementation MidasTwitter {
	__strong DCTAuthAccount *_account;
	__strong DCTAuthAccountStore *_accountStore;
	__strong NSString *_type;
}

+ (MidasTwitter *)sharedTwitter {
	static MidasTwitter *midasTwitter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		midasTwitter = [MidasTwitter new];
	});
	return midasTwitter;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	_type = @"twitter";
	_accountStore = [DCTAuthAccountStore new];
	_account = [[_accountStore accountsWithType:_type] lastObject];
	return self;
}

- (BOOL)isLoggedIn {
	return _account.authorized;
}

- (void)loginWithCompletion:(void (^)())completion {
	
	if (self.isLoggedIn) {
		completion();
		return;
	}
	
	_account = [DCTAuthAccount OAuthAccountWithType:_type
									requestTokenURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"]
									   authorizeURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/authorize"]
									 accessTokenURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"]
										consumerKey:@"5lMw8Ldk2hhnhffI89GKg"
									 consumerSecret:@"vyuPX2BdDTNXi7vaiAuUZatr92b2bG25MEQ1WKuXyI"];
	
	[_account authenticateWithHandler:^(NSDictionary *responses, NSError *error) {
		[self _findScreenNameInDictionary:responses];
		[_accountStore saveAccount:_account];
		completion();
	}];
}

- (void)_findScreenNameInDictionary:(NSDictionary *)responses {

	[responses enumerateKeysAndObjectsUsingBlock:^(NSString *key, id object, BOOL *stop) {

		if ([object isKindOfClass:[NSDictionary class]]) {
			[self _findScreenNameInDictionary:object];
			return;
		}

		if ([key isEqualToString:@"screen_name"])
			_account.accountDescription = object;
	}];
}

- (void)logout {
	[_accountStore deleteAccount:_account];
	_account = nil;
}

- (void)fetchUserWithHandler:(void(^)(id, NSError *error))handler {

	if (!_account.accountDescription) {

		if (handler != NULL) {
			NSError *error = [NSError errorWithDomain:@"MidasTwitter" code:404 userInfo:@{ NSLocalizedDescriptionKey : @"Username is not present." }];
			handler(nil, error);
		}

		return;
	}

	[self getURL:[NSURL URLWithString:@"https://api.twitter.com/1/users/show.json"]
	  parameters:@{ @"screen_name" : _account.accountDescription }
		 handler:handler];
}

- (void)getURL:(NSURL *)URL parameters:(NSDictionary *)parameters handler:(void(^)(id, NSError *error))handler {
	[self _fetchURL:URL requestMethod:DCTAuthRequestMethodGET parameters:parameters handler:handler];
}

- (void)postURL:(NSURL *)URL parameters:(NSDictionary *)parameters handler:(void(^)(id, NSError *error))handler {
	[self _fetchURL:URL requestMethod:DCTAuthRequestMethodPOST parameters:parameters handler:handler];
}

- (void)_fetchURL:(NSURL *)URL
	requestMethod:(DCTAuthRequestMethod)requestMethod
	   parameters:(NSDictionary *)parameters
		  handler:(void(^)(id, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:requestMethod
																		URL:URL
																 parameters:parameters];
	request.account = _account;
	[request performRequestWithHandler:^(NSData *data, NSHTTPURLResponse *urlResponse, NSError *error) {

		if (handler == NULL) return;

		if (!data) {
			handler(nil, error);
			return;
		}

		id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

		if ([object isKindOfClass:[NSDictionary class]]) {
			NSString *errorString = [object valueForKey:@"error"];
			if (errorString) {
				NSString *description = NSLocalizedString(@"Twitter Error", @"Twitter error title");
				NSString *failureReason = errorString;
				NSDictionary *userInfo = @{ NSLocalizedDescriptionKey : description,
									 NSLocalizedFailureReasonErrorKey : failureReason };
				NSError *error = [[NSError alloc] initWithDomain:@"Twitter" code:0 userInfo:userInfo];
				handler(nil, error);
				return;
			}
		}
		
		if (object)
			handler(object, nil);
		else
			handler(data, nil);
	}];
}

@end
