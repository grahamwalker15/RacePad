//
//  MidasHelpViewController.m
//  MidasDemo
//
//  Created by Daniel Tull on 07/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasHelpViewController.h"

@interface MidasHelpViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation MidasHelpViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIImage *image = [self.titleImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)];
	self.titleImageView.image = image;
	self.titleLabel.text = NSLocalizedString(@"midas.help.title", @"Help popup title");
}

@end
