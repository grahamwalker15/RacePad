//
//  MidasTabViewController.h
//  Midas
//
//  Created by Daniel Tull on 14.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "BaseSocialmediaViewController.h"

@interface MidasSocialViewController : BaseSocialmediaViewController

- (id)initWithViewControllers:(NSArray *)viewControllers;

@property (nonatomic, readonly) NSArray *viewControllers;

@property (nonatomic, strong) UIButton *loginButton;
@property (nonatomic, strong) UIImage *backgroundImage;

@end


@interface UIViewController (MidasSocialViewController)
@property (nonatomic, readonly) MidasSocialViewController *midas_socialViewController;
@end
