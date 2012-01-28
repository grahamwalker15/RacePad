    //
//  BaseSocialmediaViewController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 1/15/12.
//  Copyright 2012 SBG Racing Services Ltd. All rights reserved.
//

#import "BaseSocialmediaViewController.h"


@implementation BaseSocialmediaViewController

@synthesize tableBackgroundView;
@synthesize tableContainerView;

#pragma mark BaseSocialmediaViewDelegate methods

- (void)baseSocialmediaAboutToShow:(BaseSocialmediaView *)controller
{
}


- (void)baseSocialmediaShown:(BaseSocialmediaView *)controller
{
}


- (void)baseSocialmediaAboutToHide:(BaseSocialmediaView *)controller
{
	[self performSelector:@selector(autoDismiss) withObject:nil afterDelay: 1.5];
}


- (void)baseSocialmediaHidden:(BaseSocialmediaView *)controller
{
}

- (void)autoDismiss
{
	if(associatedManager)
		[associatedManager hideAnimated:true Notify:true];
}

@end
