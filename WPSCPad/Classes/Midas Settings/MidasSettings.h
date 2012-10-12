//
//  MidasSettings.h
//  Midas
//
//  Created by Daniel Tull on 29/08/2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
	MidasSettingsServerLocal = 0,
	MidasSettingsServerRemote
} MidasSettingsServer;

@interface MidasSettings : NSObject

+ (MidasSettings *)sharedSettings;
- (void)waitForSettings:(void(^)())handler;

@property (nonatomic, copy, readonly) NSString *hashtag;
@property (nonatomic, copy, readonly) NSString *facebookPostID;
@property (nonatomic, copy, readonly) NSDate *raceStartDate;
@property (nonatomic, copy, readonly) NSDictionary *logins;
@property (nonatomic, copy, readonly) NSString *IPAddress;

@property (nonatomic, copy, readonly) NSURL *VIPEddieJordanVideoURL;
@property (nonatomic, copy, readonly) NSURL *VIPMarussiaVideoURL;
@property (nonatomic, copy, readonly) NSURL *VIPSoftbankVideoURL;

@property (nonatomic, readonly) MidasSettingsServer server;

@end
