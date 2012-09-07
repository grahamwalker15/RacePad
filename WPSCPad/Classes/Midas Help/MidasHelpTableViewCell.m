//
//  MidasHelpTableViewCell.m
//  MidasDemo
//
//  Created by Daniel Tull on 07/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasHelpTableViewCell.h"

@implementation MidasHelpTableViewCell

- (void)configureWithObject:(NSDictionary *)dictionary {
	self.helpImageView.image = [UIImage imageNamed:[dictionary objectForKey:@"image"]];
	self.helpTextLabel.text = [dictionary objectForKey:@"text"];
}

@end
