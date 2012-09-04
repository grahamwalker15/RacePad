//
//  _DCTAuth2Account.m
//  DCTAuth
//
//  Created by Daniel Tull on 26/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTOAuth2Account.h"
#import "_DCTAuthAccount.h"
#import "_DCTAuthURLOpener.h"
#import "NSString+DCTAuth.h"
#import "NSURL+DCTAuth.h"

NSString *const _DCTOAuth2AccountAuthorizeResponseKey = @"AuthorizeResponse";
NSString *const _DCTOAuth2AccountAccessTokenResponseKey = @"AccessTokenResponse";

@implementation _DCTOAuth2Account {
	
	__strong NSURL *_authorizeURL;
	__strong NSURL *_accessTokenURL;
	
	__strong NSString *_clientID;
	__strong NSString *_clientSecret;
	
	__strong NSArray *_scopes;
	
	__strong NSString *_code;
	__strong NSString *_accessToken;
	__strong NSString *_refreshToken;
	
	__strong NSString *_state;
}

- (id)initWithType:(NSString *)type
	  authorizeURL:(NSURL *)authorizeURL
	accessTokenURL:(NSURL *)accessTokenURL
		  clientID:(NSString *)clientID
	  clientSecret:(NSString *)clientSecret
			scopes:(NSArray *)scopes {
	
	self = [super initWithType:type];
	if (!self) return nil;
	
	_authorizeURL = [authorizeURL copy];
	_accessTokenURL = [accessTokenURL copy];
	_clientID = [clientID copy];
	_clientSecret = [clientSecret copy];
	_scopes = [scopes copy];
	_state = [[NSProcessInfo processInfo] globallyUniqueString];
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];
	if (!self) return nil;
	
	_authorizeURL = [coder decodeObjectForKey:@"_authorizeURL"];
	_accessTokenURL = [coder decodeObjectForKey:@"_accessTokenURL"];
	
	_clientID = [self _secureValueForKey:@"_clientID"];
	_clientSecret = [self _secureValueForKey:@"_clientSecret"];
	
	_scopes = [coder decodeObjectForKey:@"_scopes"];
	
	_code = [self _secureValueForKey:@"_code"];
	_accessToken = [self _secureValueForKey:@"_accessToken"];
	_refreshToken = [self _secureValueForKey:@"_refreshToken"];
	
	_state = [self _secureValueForKey:@"_state"];
	
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];
	
	[coder encodeObject:_authorizeURL forKey:@"_authorizeURL"];
	[coder encodeObject:_accessTokenURL forKey:@"_accessTokenURL"];
	
	[self _setSecureValue:_clientID forKey:@"_clientID"];
	[self _setSecureValue:_clientSecret forKey:@"_clientSecret"];
	
	[coder encodeObject:_scopes forKey:@"_scopes"];
	
	[self _setSecureValue:_code forKey:@"_code"];
	[self _setSecureValue:_accessToken forKey:@"_accessToken"];
	[self _setSecureValue:_refreshToken forKey:@"_refreshToken"];
	
	[self _setSecureValue:_state forKey:@"_state"];
}

- (void)authenticateWithHandler:(void(^)(NSDictionary *responses, NSError *error))handler {
	
	[self _nilCurrentOAuthValues];
	NSMutableDictionary *responses = [NSMutableDictionary new];
	
	void (^completion)(NSError *) = ^(NSError *error) {
		if (handler != NULL) handler([responses copy], error);
	};
	
	void (^accessTokenHandler)(NSDictionary *, NSError *) = ^(NSDictionary *response, NSError *error) {
		if (response) [responses setObject:response forKey:_DCTOAuth2AccountAccessTokenResponseKey];
		completion(error);
	};
	
	void (^authorizeHandler)(NSDictionary *, NSError *) = ^(NSDictionary *response, NSError *error) {
		if (response) [responses setObject:response forKey:_DCTOAuth2AccountAuthorizeResponseKey];
		
		// If there's no access token URL, skip it.
		// This is the "Implicit Authentication Flow"
		if (error || !_accessTokenURL) {
			completion(error);
			return;
		}
	
		[self _fetchAccessTokenWithHandler:accessTokenHandler];
	};
	
	[self _authorizeWithHandler:authorizeHandler];
}

- (void)_authorizeWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodGET
																		URL:_authorizeURL
																 parameters:[self _OAuthParameters]];
	
	NSURL *authorizeURL = [[request signedURLRequest] URL];
	
	[[_DCTAuthURLOpener sharedURLOpener] openURL:authorizeURL withCallbackURL:self.callbackURL handler:^(NSURL *URL) {
		NSMutableDictionary *dictionary = [NSMutableDictionary new];
		NSDictionary *queryDictionary = [[URL query] dctAuth_parameterDictionary];
		[dictionary addEntriesFromDictionary:queryDictionary];
		NSDictionary *fragmentDictionary = [[URL fragment] dctAuth_parameterDictionary];
		[dictionary addEntriesFromDictionary:fragmentDictionary];
		[self _setValuesFromOAuthDictionary:dictionary];
		NSError *error = [self _errorFromOAuthDictionary:dictionary];
		handler([dictionary copy], error);
	}];
}

- (void)_fetchAccessTokenWithHandler:(void(^)(NSDictionary *response, NSError *error))handler {
	
	DCTAuthRequest *request = [[DCTAuthRequest alloc] initWithRequestMethod:DCTAuthRequestMethodPOST
																		URL:_accessTokenURL
																 parameters:[self _OAuthParameters]];
	
	[request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
		
		if (!responseData) {
			handler(nil, error);
			return;
		}
		
		NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:NULL];
		if (!dictionary) {
			NSString *string= [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
			dictionary = [string dctAuth_parameterDictionary];
		}
		[self _setValuesFromOAuthDictionary:dictionary];
		NSError *oAuthError = [self _errorFromOAuthDictionary:dictionary];
		handler(dictionary, oAuthError);
	}];
}

- (void)signURLRequest:(NSMutableURLRequest *)request forAuthRequest:(DCTAuthRequest *)authRequest {
	NSURL *URL = [request URL];
	URL = [URL dctAuth_URLByAddingQueryParameters:[self _OAuthParameters]];
	request.URL = URL;
}

- (NSError *)_errorFromOAuthDictionary:(NSDictionary *)dictionary {
	
	if ([dictionary count] == 0) {
		return [NSError errorWithDomain:NSStringFromClass([self class]) code:0 userInfo:@{}];
	}
	
	return nil;
}

- (NSDictionary *)_OAuthParameters {
	NSMutableDictionary *parameters = [NSMutableDictionary new];
	
	if (_accessToken) {
		[parameters setObject:_accessToken forKey:@"access_token"];
		[parameters setObject:_accessToken forKey:@"oauth_token"];
		return [parameters copy];
	}
	
	[parameters setObject:_clientID forKey:@"client_id"];
	[parameters setObject:_state forKey:@"state"];
	if ([_scopes count] > 0) [parameters setObject:[_scopes componentsJoinedByString:@","] forKey:@"scope"];
	if (_clientSecret) [parameters setObject:_clientSecret forKey:@"client_secret"];
	if (self.callbackURL) [parameters setObject:[self.callbackURL absoluteString] forKey:@"redirect_uri"];
	
	if (_code) {
		[parameters setObject:_code forKey:@"code"];
		[parameters setObject:@"authorization_code" forKey:@"grant_type"];
	} else {
		
		if (_accessTokenURL)
			[parameters setObject:@"code" forKey:@"response_type"];
		else
			[parameters setObject:@"token" forKey:@"response_type"];
	}
	
	return [parameters copy];
}

- (void)_nilCurrentOAuthValues {
	_code = nil;
	_accessToken = nil;
	_refreshToken = nil;
	[self _setAuthorized:NO];
}

- (void)_setValuesFromOAuthDictionary:(NSDictionary *)dictionary {
	
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id value, BOOL *stop) {
		
		if ([key isEqualToString:@"code"])
			_code = value;
		
		else if ([key isEqualToString:@"refresh_token"])
			_refreshToken = value;

		else if ([key isEqualToString:@"access_token"]) {
			_accessToken = value;
			[self _setAuthorized:YES];
		}
	}];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; type = %@; clientID = %@; has code = %@; has access token = %@>",
			NSStringFromClass([self class]),
			self,
			self.type,
			_clientID,
			_code ? @"YES" : @"NO",
			_accessToken ? @"YES" : @"NO"];
}

@end
