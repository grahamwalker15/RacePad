//
//  MidasTweetTableViewCell.m
//  Midas
//
//  Created by Daniel Tull on 17.08.2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasTweetTableViewCell.h"
#import "MidasTwitterTweet.h"
#import "MidasTwitterUser.h"
#import "MidasTwitterProfileImageCache.h"

@interface MidasTweetTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetLabel;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *retweetIndicator;
@end

@implementation MidasTweetTableViewCell {
	__strong NSString *_currentUsername;
}
@synthesize retweetButton = _retweetButton;
@synthesize retweetIndicator = _retweetIndicator;

- (void)prepareForReuse {
	[super prepareForReuse];
	[self.retweetButton setTitle:@"Retweet" forState:UIControlStateNormal];
	self.retweetButton.enabled = YES;
	[self.retweetIndicator stopAnimating];
}

- (void)configureWithObject:(MidasTwitterTweet *)tweet {

	_currentUsername = tweet.user.username;
	self.nameLabel.text = tweet.user.name;
	self.tweetLabel.text = tweet.text;
	self.userImageView.image = nil;
	
	if (tweet.userRetweetedValue) {
		[self.retweetButton setTitle:@"Retweeted" forState:UIControlStateNormal];
		self.retweetButton.enabled = NO;
	}
	
	NSString *username = tweet.user.username;
	CGFloat scale = [UIScreen mainScreen].scale;
	CGSize imageViewSize = self.userImageView.bounds.size;
	CGSize size = CGSizeMake(imageViewSize.width*scale, imageViewSize.height*scale);
	
	MidasTwitterProfileImageCache *imageCache = [MidasTwitterProfileImageCache sharedCache];
	[imageCache fetchImageForUsername:username size:size handler:^(UIImage *image) {
		
		if (![username isEqualToString:_currentUsername])
			return;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.userImageView.image = image;
		});
	}];
}

+ (CGFloat)heightForObject:(MidasTwitterTweet *)tweet width:(CGFloat)width {
	
	CGFloat widthDifference = 70.0f;
	CGFloat heightDifference = 65.0f;
	
	width -= widthDifference; // Insets in the cell
	CGSize tweetSize = [tweet.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
	return tweetSize.height + heightDifference;
}

- (IBAction)retweet:(id)sender {
	self.retweetButton.enabled = NO;
	[self.retweetIndicator startAnimating];
	if (self.retweetHandler != NULL)
		self.retweetHandler();
}

@end
