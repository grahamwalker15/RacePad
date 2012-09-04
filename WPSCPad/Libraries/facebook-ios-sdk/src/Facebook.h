/*
 * Copyright 2012 Chris Ross - hiddenMemory Ltd - chris@hiddenmemory.co.uk
 * Copyright 2012 Kieran Gutteridge - IntoHand Ltd - kieran.gutteridge@intohand.com
 * Copyright 2010 Facebook
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "FBLoginDialog.h"
#import "FBRequest.h"
#import "FBBlockHandler.h"

#define kFBMethodPost   @"POST"
#define kFBMethodGet    @"GET"
#define kFBMethodDelete @"DELETE"

#define kFBLoginBlockHandlerKey @"login"
#define kFBExtendTokenBlockHandlerKey @"extend"
#define kFBLogoutBlockHandlerKey @"logout"
#define kFBSessionBlockHandlerKey @"session"

typedef enum {
	kFBLoginSuccess,
	kFBLoginCancelled,
	kFBLoginFailed,
	kFBLoginRevoked
} FBLoginState;

@class FBFrictionlessRequestSettings;
@protocol FBSessionDelegate;

/**
 * Main Facebook interface for interacting with the Facebook developer API.
 * Provides methods to log in and log out a user, make requests using the REST
 * and Graph APIs, and start user interface interactions (such as
 * pop-ups promoting for credentials, permissions, stream posts, etc.)
 */
@interface Facebook : FBBlockHandler {
    NSMutableSet* _requests;
    FBDialog* _loginDialog;
    FBDialog* _fbDialog;
    NSString* _appId;
    NSDate* _lastAccessTokenUpdate;
    FBFrictionlessRequestSettings* _frictionlessRequestSettings;
}

@property (nonatomic, copy) NSString* accessToken;
@property (nonatomic, copy) NSDate* expirationDate;
@property (nonatomic, copy) NSString* urlSchemeSuffix;
@property (nonatomic, readonly, getter=isFrictionlessRequestsEnabled) BOOL isFrictionlessRequestsEnabled;
@property (nonatomic, assign) BOOL extendTokenOnApplicationActive;
@property (nonatomic, readonly) NSSet *permissions;

@property (copy) void (^requestStarted)(FBRequest*);
@property (copy) void (^requestFinished)(FBRequest*);

+ (Facebook*)bind:(NSString*)appID;
+ (Facebook*)bind;
+ (Facebook*)shared;

- (void)authorize:(NSArray *)permissions;

- (void)authorize:(NSArray *)permissions 
		  granted:(void(^)(Facebook *))_grantedHandler 
		   denied:(void(^)(Facebook*))_deniedHandler;

- (void)usingPermissions:(NSArray*)permissions
				 request:(void(^)(BOOL success))_request;

- (void)usingPermission:(NSString*)permission
				request:(void(^)(BOOL success))_request;

- (void)extendAccessToken;

- (void)extendAccessTokenIfNeeded;

- (BOOL)shouldExtendAccessToken;

- (BOOL)handleOpenURL:(NSURL *)url;

- (void)logout;

- (FBRequest*)requestWithParameters:(NSDictionary *)params
						   finalize:(void(^)(FBRequest*request))finalize;

- (FBRequest*)requestWithMethodName:(NSString *)methodName
						 parameters:(NSDictionary *)params
					  requestMethod:(NSString *)httpMethod
						   finalize:(void(^)(FBRequest*request))finalize;


- (FBRequest*)requestWithMethodName:(NSString *)methodName 
						 parameters:(NSDictionary *)params 
						 completion:(void (^)(FBRequest *request,id result))completion;

- (FBRequest*)requestWithMethodName:(NSString *)methodName 
						 parameters:(NSDictionary *)params 
						 completion:(void (^)(FBRequest*request,id result))completion 
							  error:(void (^)(FBRequest*request,NSError *error))error;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
						  finalize:(void(^)(FBRequest*request))finalize;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
						parameters:(NSDictionary *)params
						  finalize:(void(^)(FBRequest*request))finalize;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
						parameters:(NSDictionary *)params
					 requestMethod:(NSString *)httpMethod
						  finalize:(void(^)(FBRequest*request))finalize;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
						parameters:(NSDictionary *)params
						  completion:(void (^)(FBRequest*request,id result))completion;

- (FBRequest*)requestWithGraphPath:(NSString *)graphPath
						parameters:(NSDictionary *)params
						completion:(void (^)(FBRequest*request,id result))completion 
							 error:(void (^)(FBRequest*request,NSError *error))error;

- (void)dialog:(NSString *)action
	  finalize:(void(^)(FBDialog *dialog))finalize;

- (void)dialog:(NSString *)action
	parameters:(NSDictionary *)params
	  finalize:(void(^)(FBDialog *dialog))finalize;

- (BOOL)isSessionValid;

- (void)enableFrictionlessRequests;

- (void)reloadFrictionlessRecipientCache;

- (BOOL)isFrictionlessEnabledForRecipient:(id)fbid;

- (BOOL)isFrictionlessEnabledForRecipients:(NSArray*)fbids;

- (void)addLoginHandler:(void(^)(Facebook*facebook, FBLoginState state))handler;
- (void)addExtendTokenHandler:(void(^)(Facebook *facebook, NSString *token, NSDate *expiresAt))handler;
- (void)addLogoutHandler:(void(^)(Facebook*facebook))handler;
- (void)addSessionInvalidatedHandler:(void(^)(Facebook*facebook))handler;

@end

////////////////////////////////////////////////////////////////////////////////

#import "Facebook+Graph.h"
