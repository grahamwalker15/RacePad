//
//  MidasMasterMenuViewController.m
//  MidasDemo
//
//  Created by Daniel Tull on 11.09.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasMasterMenuViewController.h"
#import "MidasWebViewController.h"

NSString *const MidasMasterMenuViewControllerF1StoreURLString = @"http://f1store.formula1.com/stores/f1/";

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

- (IBAction)f1Tapped:(id)sender {
	
	if ([associatedManager parentViewController]) {
		MidasWebViewController *viewController = [[MidasWebViewController alloc] initWithURL:[NSURL URLWithString:MidasMasterMenuViewControllerF1StoreURLString]];
		viewController.modalPresentationStyle = UIModalPresentationPageSheet;
		viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[[associatedManager parentViewController] presentViewController:viewController animated:YES completion:NULL];
	}
}

@end
