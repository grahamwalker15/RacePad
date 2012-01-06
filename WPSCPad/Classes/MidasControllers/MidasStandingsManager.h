//
//  MidasStandingsManager.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/6/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//


#import <Foundation/Foundation.h>

#import "MidasPopupManager.h"

@class MidasStandingsViewController;

@interface MidasStandingsManager : MidasPopupManager

{
	MidasStandingsViewController * standingsViewController;
}

@property (readonly, retain) MidasStandingsViewController *standingsViewController;

+(MidasStandingsManager *)Instance;

@end
