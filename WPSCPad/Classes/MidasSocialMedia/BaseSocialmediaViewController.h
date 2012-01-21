//
//  BaseSocialmediaViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/15/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MidasBaseViewController.h"
#import "BaseSocialmediaView.h"

@interface BaseSocialmediaViewController : MidasBaseViewController <BaseSocialmediaViewDelegate>
{
    IBOutlet UIView *tableBackgroundView;
    IBOutlet UIView *tableContainerView;
}

@property (readonly) UIView *tableBackgroundView;
@property (readonly) UIView *tableContainerView;

@end
