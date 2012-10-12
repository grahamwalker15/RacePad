//
//  MidasTimeController.m
//  MidasDemo
//
//  Created by Gareth Griffith on 9/17/12.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasTimeController.h"

#import "MidasVideoViewController.h"
#import "MidasPopupManager.h"

#import "RacePadCoordinator.h"
#import "BasePadMedia.h"
#import "BasePadVideoSource.h"
#import "MovieView.h"

@implementation MidasTimeController

static MidasTimeController * instance_ = nil;

+(MidasTimeController *)Instance
{
	if(!instance_)
		instance_ = [[MidasTimeController alloc] init];
	
	return instance_;
}

-(id)init
{
	if(self = [super init])
	{
		reducedView = true;
	}
	
	return self;
}

- (void)notifyMovieAttachedToView:(MovieView *)movieView	// MovieViewDelegate method
{
}

- (void)notifyMovieReadyToPlayInView:(MovieView *)movieView	// MovieViewDelegate method
{
}

@end
