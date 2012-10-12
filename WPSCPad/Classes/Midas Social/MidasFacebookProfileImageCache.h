//
//  MidasFacebookProfileImageCache.h
//  Midas
//
//  Created by Daniel Tull on 22.08.2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidasFacebookProfileImageCache : NSObject

+ (MidasFacebookProfileImageCache *)sharedCache;

- (BOOL)hasImageForUserID:(NSString *)userID size:(CGSize)size;
- (UIImage *)imageForUserID:(NSString *)userID size:(CGSize)size;
- (void)fetchImageForUserID:(NSString *)userID size:(CGSize)size handler:(void(^)(UIImage *image))handler;

@end
