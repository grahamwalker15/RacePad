//
//  MidasTwitterProfileImageCache.h
//  Midas
//
//  Created by Daniel Tull on 28/08/2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MidasTwitterProfileImageCache : NSObject

+ (MidasTwitterProfileImageCache *)sharedCache;

- (BOOL)hasImageForUsername:(NSString *)username size:(CGSize)size;
- (UIImage *)imageForUsername:(NSString *)username size:(CGSize)size;
- (void)fetchImageForUsername:(NSString *)username size:(CGSize)size handler:(void(^)(UIImage *image))handler;

@end
