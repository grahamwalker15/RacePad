//
//  MidasStandingsViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "MidasBaseViewController.h"
#import "TableDataView.h"

@interface MidasStandingsView : TableDataView
{
}
@end

@interface MidasStandingsViewController : MidasBaseViewController 
{
	IBOutlet MidasStandingsView * standingsView;
}

@end
