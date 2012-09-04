//
//  MidasTwitterProfileImageCache.m
//  Midas
//
//  Created by Daniel Tull on 28/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasTwitterProfileImageCache.h"
#import <DCTImageCache/DCTImageCache.h>
#import <DCTImageSizing/DCTImageSizing.h>
#import "MidasTwitter.h"

@implementation MidasTwitterProfileImageCache {
	__strong DCTImageCache *_imageCache;
}

+ (MidasTwitterProfileImageCache *)sharedCache {
	static MidasTwitterProfileImageCache *cache;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		cache = [MidasTwitterProfileImageCache new];
		
	});
	return cache;
}

- (id)init {
	
	self = [super init];
	if (!self) return nil;
	
	_imageCache = [DCTImageCache imageCacheWithName:NSStringFromClass([self class])];
	
	__weak DCTImageCache *weakImageCache = _imageCache;
	[_imageCache setImageFetcher:^(NSString *username, CGSize size) {
		
		if (!CGSizeEqualToSize(size, CGSizeZero)) {
			[weakImageCache fetchImageForKey:username size:CGSizeZero handler:^(UIImage *image) {
				UIImage *resizedImage = [image dct_imageWithSize:size contentMode:UIViewContentModeScaleAspectFill];
				[weakImageCache setImage:resizedImage forKey:username size:size];
			}];
			return;
		}
		
		dispatch_async(dispatch_get_main_queue(), ^{
			
			NSURL *URL = [NSURL URLWithString:@"https://api.twitter.com/1/users/profile_image"];
			NSDictionary *parameters = @{ @"screen_name" : username, @"size" : @"bigger" };
			
			[[MidasTwitter sharedTwitter] getURL:URL parameters:parameters handler:^(NSData *data, NSError *error) {
				UIImage *image = [UIImage imageWithData:data];
				if (!image) return;
				[weakImageCache setImage:image forKey:username size:CGSizeZero];
			}];
		});
	}];
	
	return self;
}

- (BOOL)hasImageForUsername:(NSString *)username size:(CGSize)size {
	return [_imageCache hasImageForKey:username size:size];
}

- (UIImage *)imageForUsername:(NSString *)username size:(CGSize)size {
	return [_imageCache imageForKey:username size:size];
}

- (void)fetchImageForUsername:(NSString *)username size:(CGSize)size handler:(void(^)(UIImage *image))handler {
	[_imageCache fetchImageForKey:username size:size handler:handler];
}

@end
