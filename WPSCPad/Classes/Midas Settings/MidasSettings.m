//
//  MidasSettings.m
//  Midas
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasSettings.h"
#import "TestFlight.h"

typedef enum : NSUInteger {
	MidasSettingsStatusNoSettings,
	MidasSettingsStatusFetching,
	MidasSettingsStatusHasSettings
} MidasSettingsStatus;

NSString *const MidasVLSFilename = @"LiveVideoConnection.vls";

NSString *const MidasSettingsPath = @"/settings";
NSString *const MidasSettingsLocalServerHost = @"192.168.5.143";
NSString *const MidasSettingsRemoteServerHost = @"31.221.40.202";

NSString *const MidasSettingsFacebookKey = @"fb_url";
NSString *const MidasSettingsTwitterKey = @"tw_hash";
NSString *const MidasSettingsCountdownKey = @"countdown";
NSString *const MidasSettingsIPAddressKey = @"data_host";
NSString *const MidasSettingsVideoPathKey = @"videofile";
NSString *const MidasSettingsVIPEddieJordanVideoKey = @"eddie_jordan_video";
NSString *const MidasSettingsVIPSoftbankVideoKey = @"softbank_video";
NSString *const MidasSettingsVIPMarussiaVideoKey = @"marussia_video";

NSTimeInterval const MidasSettingsCountdownDefault = 8.0;
NSString *const MidasSettingsFacebookDefault = @"296502463790309";
NSString *const MidasSettingsTwitterDefault = @"#f1";
NSString *const MidasSettingsIPAddressDefault = @"192.168.1.133";
NSString *const MidasSettingsVideoPathDefault = @"/videofile";
NSString *const MidasSettingsVIPEddieJordanVideoDefault = @"https://dl.dropbox.com/s/b4cz9m0aj5hiwfp/Eddie%20Jordan.mov";
NSString *const MidasSettingsVIPSoftbankVideoDefault = @"https://dl.dropbox.com/s/6jf9yyyfrp5vft5/Softbank.mov";
NSString *const MidasSettingsVIPMarussiaVideoDefault = @"https://dl.dropbox.com/s/immbs552106421n/Marussia.mp4";

@implementation MidasSettings {
	__strong NSMutableArray *_handlers;
	MidasSettingsStatus _status;
	__strong NSString *_videoPath;
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

	
	void (^settingsCompletion)(NSURLResponse*, NSData*, NSError*) = ^(NSURLResponse *response, NSData *data, NSError *error) {
		
		TFLog(@"%@ Connected to: %@", self, [self _currentSettingsServerHost]);
		
		if (data) {
			NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
			
			TFLog(@"%@ Received settings: %@", self, dictionary);
			
			_facebookPostID = [dictionary objectForKey:MidasSettingsFacebookKey];
			_hashtag = [dictionary objectForKey:MidasSettingsTwitterKey];
			
			_IPAddress = [dictionary objectForKey:MidasSettingsIPAddressKey];
			if ([_IPAddress isKindOfClass:[NSNull class]]) _IPAddress = nil;
			
			_videoPath = [dictionary objectForKey:MidasSettingsVideoPathKey];
			
			NSString *eddieJordanURLString = [dictionary objectForKey:MidasSettingsVIPEddieJordanVideoKey];
			if ([eddieJordanURLString length] > 0) _VIPEddieJordanVideoURL = [NSURL URLWithString:eddieJordanURLString];

			NSString *marussiaURLString = [dictionary objectForKey:MidasSettingsVIPMarussiaVideoKey];
			if ([marussiaURLString length] > 0) _VIPMarussiaVideoURL = [NSURL URLWithString:marussiaURLString];

			NSString *softbankURLString = [dictionary objectForKey:MidasSettingsVIPSoftbankVideoKey];
			if (softbankURLString) _VIPSoftbankVideoURL = [NSURL URLWithString:softbankURLString];
			
			id countdownValue = [dictionary objectForKey:MidasSettingsCountdownKey];
			NSNumber *timeIntervalNumber = nil;
			
			if ([countdownValue isKindOfClass:[NSNumber class]])
				timeIntervalNumber = countdownValue;
			else if ([countdownValue isKindOfClass:[NSString class]])
				timeIntervalNumber = [NSNumber numberWithInteger:[countdownValue integerValue]];
			
			_raceStartDate = [NSDate dateWithTimeIntervalSinceNow:[timeIntervalNumber doubleValue]];
		} else {
			TFLog(@"%@ Received error: %@", self, [error localizedDescription]);
			TFLog(@"%@ Received error: %@", self, error);
		}
		
		if (!_facebookPostID) _facebookPostID = MidasSettingsFacebookDefault;
		
		if (!_hashtag) _hashtag = MidasSettingsTwitterDefault;
		
		if (!_videoPath) _videoPath = MidasSettingsVideoPathDefault;
		
		if (!_raceStartDate)
			_raceStartDate = [NSDate dateWithTimeIntervalSinceNow:MidasSettingsCountdownDefault];
		
		
		if (!_VIPMarussiaVideoURL) _VIPMarussiaVideoURL = [NSURL URLWithString:MidasSettingsVIPMarussiaVideoDefault];

		if (!_VIPEddieJordanVideoURL) _VIPEddieJordanVideoURL = [NSURL URLWithString:MidasSettingsVIPEddieJordanVideoDefault];
		
		if (!_VIPSoftbankVideoURL) _VIPSoftbankVideoURL = [NSURL URLWithString:MidasSettingsVIPSoftbankVideoDefault];
		
		TFLog(@"%@ hashtag = %@", self, self.hashtag);
		TFLog(@"%@ facebookPostID = %@", self, self.facebookPostID);
		TFLog(@"%@ raceStartDate = %@", self, self.raceStartDate);
		TFLog(@"%@ IPAddress = %@", self, self.IPAddress);
		TFLog(@"%@ VIPMarussiaVideoURL = %@", self, self.VIPMarussiaVideoURL);
		TFLog(@"%@ VIPEddieJordanVideoURL = %@", self, self.VIPEddieJordanVideoURL);
		TFLog(@"%@ VIPSoftbankVideoURL = %@", self, self.VIPSoftbankVideoURL);
		
		NSURLRequest *vlsRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", [self _currentSettingsServerHost], _videoPath]]];
		TFLog(@"%@ Attempting to connect to %@", self, vlsRequest.URL);
		[NSURLConnection sendAsynchronousRequest:vlsRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
			
			if (data) {
				TFLog(@"%@ Received vls:\n%@", self, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
				NSFileManager *fileManager = [NSFileManager defaultManager];
				NSURL *documentsURL = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
				NSURL *URL = [documentsURL URLByAppendingPathComponent:MidasVLSFilename];
				[fileManager removeItemAtURL:URL error:NULL];
				[data writeToURL:URL atomically:YES];
			} else {
				TFLog(@"%@ Received error: %@", self, [error localizedDescription]);
				TFLog(@"%@ Received error: %@", self, error);
			}
			
			[_handlers enumerateObjectsUsingBlock:^(void(^handler)(), NSUInteger idx, BOOL *stop) {
				handler();
			}];
			[_handlers removeAllObjects];
			_status = MidasSettingsStatusHasSettings;
		}];
	};
	
	_status = MidasSettingsStatusFetching;
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", [self _currentSettingsServerHost], MidasSettingsPath]]
												  cachePolicy:NSURLRequestReloadIgnoringCacheData
											  timeoutInterval:5.0f];
	TFLog(@"%@ Attempting to connect to %@", self, request.URL);
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		
		if (data) {
			settingsCompletion(response, data, error);
			return;
		}
		
		TFLog(@"%@ Received error: %@", self, [error localizedDescription]);
		TFLog(@"%@ Received error: %@", self, error);
		
		_server = MidasSettingsServerRemote;
		NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", [self _currentSettingsServerHost], MidasSettingsPath]]];
		TFLog(@"%@ Attempting to connect to %@", self, request.URL);
		[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:settingsCompletion];
	}];
}

- (NSString *)_currentSettingsServerHost {
	
	if (self.server == MidasSettingsServerLocal)
		return MidasSettingsLocalServerHost;
	
	return MidasSettingsRemoteServerHost;
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
