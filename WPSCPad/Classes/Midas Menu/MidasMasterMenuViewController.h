//
//  MidasMasterMenuViewController.h
//  MidasDemo
//
//  Created by Daniel Tull on 11.09.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasBaseViewController.h"

@interface MidasMasterMenuViewController : MidasBaseViewController
{
	IBOutlet UIButton * circuitButton;
	IBOutlet UIButton * pitsButton;
	IBOutlet UIButton * shopButton;
	IBOutlet UIButton * settingsButton;
}

-(IBAction) buttonPressed:(id)sender;

@end
