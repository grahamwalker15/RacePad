//
//  MidasMasterMenuViewController.m
//  MidasDemo
//
//  Created by Daniel Tull on 11.09.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasMasterMenuViewController.h"

@implementation MidasMasterMenuViewController : MidasBaseViewController

- (id)init {
	return [self initWithNibName:@"MidasMasterMenuView" bundle:nil];
}

-(IBAction) buttonPressed:(id)sender
{
	if(associatedManager)
	{
		if(sender == settingsButton && [associatedManager parentViewController])
		{
			//[[associatedManager parentViewController] presentModalViewController:[MidasSetupViewController Instance] animated:true];
		}
		else
		{
			[associatedManager hideAnimated:true Notify:true];
		}
	}
}

@end
