//
//  MidasMasterMenuViewController.m
//  MidasDemo
//
//  Created by Daniel Tull on 11.09.2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasMasterMenuViewController.h"
#import "MidasWebViewController.h"
#import "TestFlight.h"

NSString *const MidasMasterMenuViewControllerF1StoreURLString = @"http://f1store.formula1.com/stores/f1/default.aspx?";
NSString *const MidasMasterMenuViewControllerMarussiaURLString = @"http://www.marussiaf1team.com/";
NSString *const MidasMasterMenuViewControllerSoftBankURLString = @"http://mb.softbank.jp/mb/customer.html";

@implementation MidasMasterMenuViewController : MidasBaseViewController

- (id)init {
	return [self initWithNibName:@"MidasMasterMenuView" bundle:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[TestFlight passCheckpoint:@"Main Menu"];
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
	[self _openURL:[NSURL URLWithString:MidasMasterMenuViewControllerF1StoreURLString]];
	[TestFlight passCheckpoint:@"F1 Store"];
}

- (IBAction)marussiaTapped:(id)sender {
	[self _openURL:[NSURL URLWithString:MidasMasterMenuViewControllerMarussiaURLString]];
	[TestFlight passCheckpoint:@"Marussia Website"];
}

- (IBAction)softbankTapped:(id)sender {
	[self _openURL:[NSURL URLWithString:MidasMasterMenuViewControllerSoftBankURLString]];
	[TestFlight passCheckpoint:@"SoftBank Website"];
}

- (void)_openURL:(NSURL *)URL {

	if ([associatedManager parentViewController]) {
		MidasWebViewController *viewController = [[MidasWebViewController alloc] initWithURL:URL];
		viewController.modalPresentationStyle = UIModalPresentationPageSheet;
		viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
		[[associatedManager parentViewController] presentViewController:viewController animated:YES completion:NULL];
	}
}

@end
