//
//  MidasDemoViewControllers.h
//  MidasDemo
//
//  Created by Gareth Griffith on 1/23/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MidasBaseViewController.h"
#import "TrackMapView.h"
#import "MovieSelectorView.h"

@interface MidasMasterMenuViewController : MidasBaseViewController
{
	IBOutlet UIButton * circuitButton;
	IBOutlet UIButton * pitsButton;
	IBOutlet UIButton * shopButton;
	IBOutlet UIButton * settingsButton;
}

-(IBAction) buttonPressed:(id)sender;

@end

@interface MidasHeadToHeadViewController : MidasBaseViewController
{
}

@end

@interface MidasMyTeamViewController : MidasBaseViewController
{
	IBOutlet UIButton * expandButton;
	IBOutlet UIView * extensionContainer;
		
	bool expanded;
}

- (void) expandView;
- (void) reduceViewAnimated:(bool)animated;

- (void) animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void*)context;

- (IBAction) expandPressed;

@end

@interface MidasVIPViewController : MidasBaseViewController
{
}

@end

