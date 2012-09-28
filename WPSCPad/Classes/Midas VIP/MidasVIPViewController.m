//
//  MidasVIPViewController.m
//  Midas
//
//  Created by Daniel Tull on 09/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasVIPViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "TestFlight.h"
#import "MidasSettings.h"

@interface MidasVIPViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *videoScrollView;
@property (strong, nonatomic) IBOutlet UIView *videoContent;
@end

@implementation MidasVIPViewController {
	__strong MPMoviePlayerController *_moviePlayer;
	__strong NSArray *_videos;
}

- (id)init {
	return [self initWithNibName:@"MidasVIPViewController" bundle:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	MidasSettings *settings = [MidasSettings sharedSettings];
	[settings waitForSettings:^{
		_videos = @[
			settings.VIPEddieJordanVideoURL,
			settings.VIPMarussiaVideoURL,
			settings.VIPSoftbankVideoURL
		];
	}];
	
	UIImage *image = [self.titleImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)];
	self.titleImageView.image = image;
	self.titleLabel.text = NSLocalizedString(@"midas.vip.title", @"VIP popup title");
	
	self.videoScrollView.contentSize = self.videoContent.bounds.size;
	[self.videoScrollView addSubview:self.videoContent];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[TestFlight passCheckpoint:@"VIP"];
}


- (IBAction)play:(UIControl *)sender {
	
	[self _removeMoviePlayer];
	
	NSURL *URL = [_videos objectAtIndex:sender.tag];
	_moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:URL];
	_moviePlayer.view.frame = sender.superview.bounds;
	[sender.superview addSubview:_moviePlayer.view];
	
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter addObserver:self
					  selector:@selector(moviePlayerDidExitFullscreenNotification:)
						  name:MPMoviePlayerDidExitFullscreenNotification
						object:_moviePlayer];
	[defaultCenter addObserver:self
					  selector:@selector(moviePlayerPlaybackDidFinishNotification:)
						  name:MPMoviePlayerPlaybackDidFinishNotification
						object:_moviePlayer];
	
	[_moviePlayer play];
}

- (void)_removeMoviePlayer {
	NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self name:MPMoviePlayerDidExitFullscreenNotification object:_moviePlayer];
	[defaultCenter removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:_moviePlayer];
	[_moviePlayer stop];
	[_moviePlayer.view removeFromSuperview];
	_moviePlayer = nil;
}

- (void)moviePlayerDidExitFullscreenNotification:(NSNotification *)notification {
	
	if (_moviePlayer.currentPlaybackTime != _moviePlayer.playableDuration)
		return;
	
	if (_moviePlayer.playbackState == MPMoviePlaybackStatePaused || _moviePlayer.playbackState == MPMoviePlaybackStateStopped)
		[self _removeMoviePlayer];
}

- (void)moviePlayerPlaybackDidFinishNotification:(NSNotification *)notification {
	if (![_moviePlayer isFullscreen])
		[self _removeMoviePlayer];
	else
		[_moviePlayer setFullscreen:NO animated:YES];
}

@end
