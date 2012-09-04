//
//  MidasStartViewController.m
//  Midas
//
//  Created by Daniel Tull on 11.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasStartViewController.h"
#import "MidasCountdownTimer.h"
#import "MidasSocialViewController.h"
#import "MidasTwitterViewController.h"
#import "MidasFacebookViewController.h"
#import "MidasSettings.h"
#import "RacePadCoordinator.h"

CGPoint const LogoEndPoint;

@interface MidasStartViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *manView;
@property (weak, nonatomic) IBOutlet UIImageView *carView;
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *countdownDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownMinuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownSecondLabel;
@property (weak, nonatomic) IBOutlet UIView *countdownView;
@property (weak, nonatomic) IBOutlet UIView *particleView;
@end

@implementation MidasStartViewController {
	CGPoint _logoEndPoint;
	CGPoint _carEndPoint;
	CGPoint _countdownEndPoint;
	CGRect _manMidFrame;
	CGRect _manEndFrame;
	__strong MidasCountdownTimer *_countdownTimer;
	NSInteger _canAnimateOffScreenCount;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	_canAnimateOffScreenCount++;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	_logoEndPoint = CGPointMake(79.0f, 289.0f);
	_carEndPoint = CGPointMake(-170.0f, 342.0f);
	_countdownEndPoint = CGPointMake(155.0f, 0.0f);
	_manMidFrame = CGRectMake(577.0f, 52.0f, 558.0f, 1537.0f);
	_manEndFrame = CGRectMake(466.0f, 0.0f, 558.0f, 1537.0f);

	_canAnimateOffScreenCount++;
	[self _animateLogoCompletion:^(BOOL finished) {
		[self _animateAlphaCompletion:NULL];
		
		[self _animateManStage1Completion:^(BOOL finished) {
			[self _animateCountdownTimerCompletion:NULL];
			[self _animateManStage2Completion:^(BOOL finished) {
				[self _checkToAnimateOffScreen];
			}];
		}];
	}];
	
	[self _animateCarCompletion:NULL];
}

- (void)_checkToAnimateOffScreen {
	_canAnimateOffScreenCount--;
	if (_canAnimateOffScreenCount > 0) return;
	
	[self _animateObjectsOffScreenWithDelay:0.5f completion:^(BOOL finished) {
		[self loadLive:nil];
	}];
	
}

- (void)_animateCountdownTimerCompletion:(void(^)(BOOL finished))completion {
	MidasSettings *settings = [MidasSettings sharedSettings];
	[settings waitForSettings:^{
		
		NSDate *raceStartDate = settings.raceStartDate;
		NSTimeInterval timeInterval = [raceStartDate timeIntervalSinceNow];
		_countdownTimer = [[MidasCountdownTimer alloc] initWithTimeIntervalToEvent:timeInterval];
		
		__weak MidasStartViewController *weakSelf = self;
		_countdownTimer.timeChangedHandler = ^(NSUInteger days, NSUInteger hours, NSUInteger minutes, NSUInteger seconds) {
			weakSelf.countdownDayLabel.text = [NSString stringWithFormat:@"%.2d", days];
			weakSelf.countdownHourLabel.text = [NSString stringWithFormat:@"%.2d", hours];
			weakSelf.countdownMinuteLabel.text = [NSString stringWithFormat:@"%.2d", minutes];
			weakSelf.countdownSecondLabel.text = [NSString stringWithFormat:@"%.2d", seconds];
		};
		
		_countdownTimer.eventDateHandler = ^{
			[weakSelf _checkToAnimateOffScreen];
		};
		
		[UIView animateWithDuration:0.6 animations:^{
			CGRect frame = self.countdownView.frame;
			frame.origin = _countdownEndPoint;
			self.countdownView.frame = frame;
		}];
	}];
}

- (void)_animateManStage1Completion:(void(^)(BOOL finished))completion {
	[UIView animateWithDuration:0.4f animations:^{
		self.manView.frame = _manMidFrame;
	} completion:completion];
}

- (void)_animateManStage2Completion:(void(^)(BOOL finished))completion {
	[UIView animateWithDuration:4.24f animations:^{
		self.manView.frame = _manEndFrame;
	} completion:completion];
}

- (void)_animateCarCompletion:(void(^)(BOOL finished))completion {
	[UIView animateWithDuration:5.0f delay:0.0f options:UIViewAnimationOptionCurveLinear animations:^{
		CGRect frame = self.carView.frame;
		frame.origin = _carEndPoint;
		self.carView.frame = frame;
	} completion:completion];
}


- (void)_animateAlphaCompletion:(void(^)(BOOL finished))completion {
	[UIView animateWithDuration:0.4f animations:^{
		self.manView.alpha = 1.0f;
		self.carView.alpha = 1.0f;
		self.backgroundView.alpha = 1.0f;
		self.countdownView.alpha = 1.0f;
		self.particleView.alpha = 1.0f;
	} completion:completion];
}

- (void)_animateLogoCompletion:(void(^)(BOOL finished))completion {
	[UIView animateWithDuration:0.36f animations:^{
		CGRect frame = self.logoView.frame;
		frame.origin = _logoEndPoint;
		self.logoView.frame = frame;
	} completion:completion];
}

- (void)_animateObjectsOffScreenWithDelay:(NSTimeInterval)delay completion:(void(^)(BOOL finished))completion {
	
	[UIView animateWithDuration:0.2f delay:delay options:UIViewAnimationOptionCurveEaseIn animations:^{
		
		CGRect frame = self.carView.frame;
		frame.origin.x = CGRectGetMaxX(frame);
		self.carView.frame = frame;
			
		frame = self.manView.frame;
		frame.origin.x = -frame.size.width;
		self.manView.frame = frame;
		
		self.logoView.alpha = 0.0f;
		self.countdownView.alpha = 0.0f;
		self.particleView.alpha = 0.0f;
		
	} completion:completion];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

-(IBAction)loadArchive:(id)sender {
	[[RacePadCoordinator Instance] loadSession:@"09_11Mza" Session:@"Race"];
}

-(IBAction)loadLive:(id)sender {
	[[RacePadCoordinator Instance] loadSession:@"09_11Lve" Session:@"Race"];
}

@end
