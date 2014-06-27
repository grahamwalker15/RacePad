//
//  RaceMapTitleBarController
//  RaceMap
//
//  Created by Simon Cuff on 17th June 2014
//  Copyright 2014 SBG Sports Software Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BasePadTitleBarController.h"
#import "TitleBarViewController.h"
#import "AlertViewController.h"

@interface RaceMapTitleBarController : BasePadTitleBarController
{
}

+ (RaceMapTitleBarController *)Instance;

- (void) displayInViewController:(UIViewController *)viewController SupportCommentary: (bool) supportCommentary;

@end
