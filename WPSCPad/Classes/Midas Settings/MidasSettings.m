//
//  MidasSettings.m
//  Midas
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasSettings.h"

typedef enum : NSUInteger {
	MidasSettingsStatusNoSettings,
	MidasSettingsStatusFetching,
	MidasSettingsStatusHasSettings
} MidasSettingsStatus;

NSString *const MidasSettingsServerAddress = @"http://31.221.40.202/settings";
NSString *const MidasSettingsFacebookKey = @"fb_url";
NSString *const MidasSettingsTwitterKey = @"tw_hash";
NSString *const MidasSettingsCountdownKey = @"countdown";

NSTimeInterval const MidasSettingsCountdownDefault = 20.0;
NSString *const MidasSettingsFacebookDefault = @"296502463790309";
NSString *const MidasSettingsTwitterDefault = @"#f1";

@implementation MidasSettings {
	__strong NSMutableArray *_handlers;
	MidasSettingsStatus _status;
}

+ (MidasSettings *)sharedSettings {
	static MidasSettings *settings;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		settings = [MidasSettings new];
	});
	return settings;
}

- (id)init {

	self = [super init];
	if (!self) return nil;
	
	_handlers = [NSMutableArray new];
	[self fetchSettingsWithHandler:NULL];
	return self;
}
	
- (void)fetchSettingsWithHandler:(void(^)())handler {
	if (handler != NULL) [_handlers addObject:handler];
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:MidasSettingsServerAddress]];
	_status = MidasSettingsStatusFetching;
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
		if (data) {
			NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
			
			_facebookPostID = [dictionary objectForKey:MidasSettingsFacebookKey];
			_hashtag = [dictionary objectForKey:MidasSettingsTwitterKey];
			
			id countdownValue = [dictionary objectForKey:MidasSettingsCountdownKey];
			NSNumber *timeIntervalNumber = nil;
			
			if ([countdownValue isKindOfClass:[NSNumber class]])
				timeIntervalNumber = countdownValue;
			else if ([countdownValue isKindOfClass:[NSString class]])
				timeIntervalNumber = [NSNumber numberWithInteger:[countdownValue integerValue]];
			
			_raceStartDate = [NSDate dateWithTimeIntervalSinceNow:[timeIntervalNumber doubleValue]];
		}
		
		if (!_facebookPostID)
			_facebookPostID = MidasSettingsFacebookDefault;
		
		if (!_hashtag)
			_hashtag = MidasSettingsTwitterDefault;
		
		if (!_raceStartDate)
			_raceStartDate = [NSDate dateWithTimeIntervalSinceNow:MidasSettingsCountdownDefault];
		
		[_handlers enumerateObjectsUsingBlock:^(void(^handler)(), NSUInteger idx, BOOL *stop) {
			handler();
		}];
		_status = MidasSettingsStatusHasSettings;
	}];
}

- (NSDictionary *)logins {
	return @{ @"user" : @"password" };
}

- (void)waitForSettings:(void(^)())handler {
	
	if (_status == MidasSettingsStatusNoSettings) {
		[self fetchSettingsWithHandler:handler];
		return;
	}
	
	if (handler == NULL) return;
	
	if (_status == MidasSettingsStatusHasSettings)
		handler();
	
	else if (_status == MidasSettingsStatusFetching)
		[_handlers addObject:handler];
}

@end
