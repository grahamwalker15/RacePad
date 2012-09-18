//
//  MidasHomeViewController.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/4/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "BasePadViewController.h"

#import "BackgroundView.h"

@interface MidasHomeViewController : BasePadViewController
{
	IBOutlet BackgroundView * backgroundView;
	
	IBOutlet UIButton * archiveButton;
	IBOutlet UIButton * liveButton;
}

-(IBAction)loadArchive:(id)sender;
-(IBAction)loadLive:(id)sender;

@end

