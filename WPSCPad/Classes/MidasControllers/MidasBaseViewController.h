//
//  MidasBaseViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BasePadViewController.h"
#import "MidasPopupManager.h"

@interface MidasBaseViewController : BasePadViewController <BasePadPopupManagerDelegate>
{
	IBOutlet UIImageView * container;
	IBOutlet UIImageView * heading;
	
	BasePadPopupManager * associatedManager;
}

@property (readonly) UIImageView * container;
@property (readonly) UIImageView * heading;
@property (nonatomic,retain) BasePadPopupManager * associatedManager;

@end
