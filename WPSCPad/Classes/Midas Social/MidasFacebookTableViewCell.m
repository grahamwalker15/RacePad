//
//  MidasFacebookTableViewCell.m
//  Midas
//
//  Created by Daniel Tull on 17/08/2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasFacebookTableViewCell.h"
#import "MidasFacebookComment.h"
#import "MidasFacebookUser.h"
#import "MidasFacebookProfileImageCache.h"

@interface MidasFacebookTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountOfLikesLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *likeIndicator;
@end

@implementation MidasFacebookTableViewCell {
	__strong NSString *_currentUserID;
}

- (void)prepareForReuse {
	[super prepareForReuse];
	[self.likeButton setTitle:@"Like" forState:UIControlStateNormal];
	self.likeButton.enabled = YES;
	[self.likeIndicator stopAnimating];
}

- (void)configureWithObject:(MidasFacebookComment *)comment {
	
	_currentUserID = comment.user.userID;
	self.commentLabel.text = comment.text;
	self.amountOfLikesLabel.text = [comment.likesCount stringValue];
	self.nameLabel.text = comment.user.name;
	self.userImageView.image = nil;
	
	if (comment.userLikedValue) {
		[self.likeButton setTitle:@"Liked" forState:UIControlStateNormal];
		self.likeButton.enabled = NO;
	}
	
	NSString *userID = comment.user.userID;
	CGFloat scale = [UIScreen mainScreen].scale;
	CGSize imageViewSize = self.userImageView.bounds.size;
	CGSize size = CGSizeMake(imageViewSize.width*scale, imageViewSize.height*scale);
		
	MidasFacebookProfileImageCache *imageCache = [MidasFacebookProfileImageCache sharedCache];
	[imageCache fetchImageForUserID:userID size:size handler:^(UIImage *image) {
		
		if (![userID isEqualToString:_currentUserID])
			return;
		
		dispatch_async(dispatch_get_main_queue(), ^{
			self.userImageView.image = image;
		});
	}];
}

+ (CGFloat)heightForObject:(MidasFacebookComment *)comment width:(CGFloat)width {
	
	CGFloat widthDifference = 70.0f;
	CGFloat heightDifference = 56.0f;
	
	width -= widthDifference; // Insets in the cell
	CGSize commentSize = [comment.text sizeWithFont:[UIFont systemFontOfSize:14.0f] constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
	return MAX(commentSize.height + heightDifference, 85.f);
}

- (IBAction)like:(id)sender {
	self.likeButton.enabled = NO;
	[self.likeIndicator startAnimating];
	if (self.likeHandler)
		self.likeHandler();
}

@end
