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
	
	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://danieltull.co.uk/Midas/settings.json"]];
	_status = MidasSettingsStatusFetching;
	[NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
		NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
		
		_facebookPostID = [dictionary objectForKey:@"facebookPostID"];
		_hashtag = [dictionary objectForKey:@"hashtag"];
		
		NSNumber *timeIntervalNumber = [dictionary objectForKey:@"raceStartTimeInterval"];
		_raceStartDate = [NSDate dateWithTimeIntervalSinceNow:[timeIntervalNumber doubleValue]];
		
		[_handlers enumerateObjectsUsingBlock:^(void(^handler)(), NSUInteger idx, BOOL *stop) {
			handler();
		}];
		_status = MidasSettingsStatusHasSettings;
	}];
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
