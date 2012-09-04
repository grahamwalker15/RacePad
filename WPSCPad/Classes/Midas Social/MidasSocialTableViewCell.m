//
//  MidasTabTableViewCell.m
//  Midas
//
//  Created by Daniel Tull on 14.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasSocialTableViewCell.h"

void *MidasTabTableViewCellContext = &MidasTabTableViewCellContext;

@interface MidasSocialTableViewCell ()
@property (weak, nonatomic) IBOutlet UIView *badgeView;
@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation MidasSocialTableViewCell {
	__weak UITabBarItem *_tabBarItem;
}

- (void)dealloc {
	[_tabBarItem removeObserver:self forKeyPath:@"badgeValue" context:MidasTabTableViewCellContext];
}

- (void)configureWithObject:(UIViewController *)viewController {
	[_tabBarItem removeObserver:self forKeyPath:@"badgeValue" context:MidasTabTableViewCellContext];
	_tabBarItem = viewController.tabBarItem;
	[_tabBarItem addObserver:self forKeyPath:@"badgeValue" options:0 context:MidasTabTableViewCellContext];
	[self _updateBadge];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	
	if (context != MidasTabTableViewCellContext)
		return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	
	[self _updateBadge];
}

- (void)_updateBadge {
	self.badgeView.hidden = [_tabBarItem.badgeValue length] < 1;
	self.badgeLabel.text = _tabBarItem.badgeValue;
}

@end
