//
//  MidasHelpTableViewCell.m
//  MidasDemo
//
//  Created by Daniel Tull on 07/09/2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasHelpTableViewCell.h"

@implementation MidasHelpTableViewCell

- (void)configureWithObject:(NSDictionary *)dictionary {
	self.helpTitleLabel.text = NSLocalizedString([dictionary objectForKey:@"title"], @"title");
	self.helpImageView.image = [UIImage imageNamed:[dictionary objectForKey:@"image"]];
	self.helpTextView.text = [dictionary objectForKey:@"text"];
}

@end
