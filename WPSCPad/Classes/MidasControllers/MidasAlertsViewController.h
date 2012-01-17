//
//  MidasAlertsViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/9/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MidasBaseViewController.h"
#import "AlertView.h"

@interface MidasAlertsView : AlertView
{
}
@end

@interface MidasAlertsViewController : MidasBaseViewController
{
	IBOutlet MidasAlertsView * alertView;
	IBOutlet UIBarButtonItem * closeButton;
	IBOutlet UISegmentedControl * typeChooser;
	
}

- (void) UpdateList;

- (void) dismissTimerExpired:(NSTimer *)theTimer;

- (IBAction) typeChosen:(id)sender;

- (bool) HandleSelectRow:(int)row DoubleClick:(bool)double_click LongPress:(bool)long_press;

@end
