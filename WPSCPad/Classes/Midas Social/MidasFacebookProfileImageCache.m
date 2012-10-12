//
//  MidasFacebookProfileImageCache.m
//  Midas
//
//  Created by Daniel Tull on 22.08.2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasFacebookProfileImageCache.h"
#import <DCTImageCache/DCTImageCache.h>
#import <DCTImageSizing/DCTImageSizing.h>
#import <Facebook/Facebook.h>

@implementation MidasFacebookProfileImageCache {
	__strong DCTImageCache *_imageCache;
}

+ (MidasFacebookProfileImageCache *)sharedCache {
	static MidasFacebookProfileImageCache *sharedInstance = nil;
	static dispatch_once_t sharedToken;
	dispatch_once(&sharedToken, ^{
		sharedInstance = [MidasFacebookProfileImageCache new];
	});
	return sharedInstance;
}

- (id)init {
	
	self = [super init];
	if (!self) return nil;
	
	_imageCache = [DCTImageCache imageCacheWithName:NSStringFromClass([self class])];
	
	__weak DCTImageCache *weakImageCache = _imageCache;
	[_imageCache setImageFetcher:^(NSString *userID, CGSize size) {
		
		if (!CGSizeEqualToSize(size, CGSizeZero)) {
			[weakImageCache fetchImageForKey:userID size:CGSizeZero handler:^(UIImage *image) {
				UIImage *resizedImage = [image dct_imageWithSize:size contentMode:UIViewContentModeScaleAspectFill];
				[weakImageCache setImage:resizedImage forKey:userID size:size];
			}];
			return;
		}
	
		
		NSString *graphPath = [NSString stringWithFormat:@"%@/picture?type=large", userID];
		
		dispatch_async(dispatch_get_main_queue(), ^{ // Facebook calls need to be made on the main thread
			[[Facebook shared] requestWithGraphPath:graphPath finalize:^(FBRequest *request) {
				[request addRawHandler:^(FBRequest *request, NSData *data) {
					UIImage *image = [UIImage imageWithData:data];
					if (!image) return;
					[weakImageCache setImage:image forKey:userID size:CGSizeZero];
				}];
			}];
		});
	}];

	return self;
}

- (BOOL)hasImageForUserID:(NSString *)userID size:(CGSize)size {
	return [_imageCache hasImageForKey:userID size:size];
}

- (UIImage *)imageForUserID:(NSString *)userID size:(CGSize)size {
	return [_imageCache imageForKey:userID size:size];
}

- (void)fetchImageForUserID:(NSString *)userID size:(CGSize)size handler:(void(^)(UIImage *image))handler {
	[_imageCache fetchImageForKey:userID size:size handler:handler];
}

@end
