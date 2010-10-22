//
//  DriverListController.h
//  RacePad
//
//  Created by Gareth Griffith on 10/11/10.
//  Copyright 2010 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleListViewController.h"
#import "TableDataView.h"


@interface DriverListController : SimpleListViewController
{
	TableDataView * driver_list_view_;
}


@end
