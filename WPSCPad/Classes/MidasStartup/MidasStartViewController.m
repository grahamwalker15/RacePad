//
//  MidasStartViewController.m
//  Midas
//
//  Created by Daniel Tull on 11.08.2012.
//  Copyright (c) 2012 SBG Sports Software Ltd.. All rights reserved.
//

#import "MidasStartViewController.h"
#import "MidasCountdownTimer.h"
#import "MidasSocialViewController.h"
#import "MidasTwitterViewController.h"
#import "MidasFacebookViewController.h"
#import "MidasSettings.h"
#import "RacePadCoordinator.h"
#import "BasePadMedia.h"
#import "MidasLoginController.h"
#import <DCTTextFieldValidator/DCTTextFieldValidator.h>

#define LOAD_ARCHIVE

CGPoint const LogoEndPoint;

@interface MidasStartViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *manView;
@property (weak, nonatomic) IBOutlet UIImageView *carView;

@property (weak, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *logoWatchLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoShareLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoPlayLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoChatLabel;

@property (weak, nonatomic) IBOutlet UILabel *countdownDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownHourLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownMinuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownSecondLabel;
@property (weak, nonatomic) IBOutlet UIView *countdownView;
@property (weak, nonatomic) IBOutlet UIView *particleView;

@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet DCTTextFieldValidator *loginTextFieldValidator;

@property (weak, nonatomic) IBOutlet UILabel *serverLabel;
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
	
	MidasSettings *settings = [MidasSettings sharedSettings];
	[[MidasSettings sharedSettings] waitForSettings:^{
		if (settings.server == MidasSettingsServerRemote) {
			self.serverLabel.alpha = 0.0f;
			self.serverLabel.text = @"Remote Server";
			[UIView animateWithDuration:1.0f/3.0f animations:^{
				self.serverLabel.alpha = 1.0f;
			}];
		}
	}];
	
	_canAnimateOffScreenCount++;
	__weak MidasStartViewController *weakSelf = self;
	self.loginTextFieldValidator.returnHandler = ^{
		[weakSelf login:nil];
	};

	self.logoChatLabel.text = NSLocalizedString(@"midas.start.logo.chat", @"Chat label in start up");
	self.logoPlayLabel.text = NSLocalizedString(@"midas.start.logo.play", @"Play label in start up");
	self.logoWatchLabel.text = NSLocalizedString(@"midas.start.logo.watch", @"Watch label in start up");
	self.logoShareLabel.text = NSLocalizedString(@"midas.start.logo.share", @"Share label in start up");
}

- (void)viewWillAppear:(BOOL)animated
{
	// Register the view controller
	[[RacePadCoordinator Instance] RegisterViewController:self WithTypeMask:0];
    [[BasePadCoordinator Instance] setConnectionFeedbackDelegate:self];

}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[[RacePadCoordinator Instance] ReleaseViewController:self];
    [[BasePadCoordinator Instance] setConnectionFeedbackDelegate:nil];

	[self.particleView removeFromSuperview];
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
	
    // For loading archive
	[self _animateObjectsOffScreenWithDelay:0.5f completion:^(BOOL finished) {
#ifdef LOAD_ARCHIVE
		[self loadArchive:nil]; // For loading archive
#else
		[self connectLive:nil]; // For connecting to live server
#endif
	}];
}

- (void)_animateCountdownTimerCompletion:(void(^)(BOOL finished))completion {
	MidasSettings *settings = [MidasSettings sharedSettings];
	[settings waitForSettings:^{
		
		NSDate *raceStartDate = settings.raceStartDate;
		NSTimeInterval timeInterval = [raceStartDate timeIntervalSinceNow];
		_countdownTimer = [[MidasCountdownTimer alloc] initWithTimeIntervalToEvent:timeInterval];
		
		__weak MidasStartViewController *weakSelf = self;
		_countdownTimer.timeChangedHandler = ^(NSInteger days, NSInteger hours, NSInteger minutes, NSInteger seconds) {
			weakSelf.countdownDayLabel.text = [NSString stringWithFormat:@"%.2d", days];
			weakSelf.countdownHourLabel.text = [NSString stringWithFormat:@"%.2d", hours];
			weakSelf.countdownMinuteLabel.text = [NSString stringWithFormat:@"%.2d", minutes];
			weakSelf.countdownSecondLabel.text = [NSString stringWithFormat:@"%.2d", seconds];
		};
		
		_countdownTimer.eventDateHandler = ^{
			[weakSelf _showLoginView];
		};
		
		[UIView animateWithDuration:0.6 animations:^{
			CGRect frame = self.countdownView.frame;
			frame.origin = _countdownEndPoint;
			self.countdownView.frame = frame;
		}];
	}];
}

- (void)_showLoginView {
	
	if ([[MidasLoginController new] isLoggedIn]) {
		[self _checkToAnimateOffScreen];
		return;
	}
	
	self.loginView.alpha = 0.0f;
	self.loginView.hidden = NO;
	[UIView animateWithDuration:1.0f/3.0f animations:^{
		self.loginView.alpha = 1.0f;
	} completion:^(BOOL finished) {
		[self.usernameField becomeFirstResponder];
	}];
}

- (IBAction)login:(id)sender {
	NSString *username = self.usernameField.text;
	NSString *password = self.passwordField.text;
	[[MidasLoginController new] loginWithUsername:username password:password handler:^(BOOL success, NSError *error) {

		if (success) {
			[self _checkToAnimateOffScreen];
			return;
		}

		[self _shakeView:self.usernameField];
		[self _shakeView:self.passwordField];
		self.passwordField.text = @"";
		self.passwordField.placeholder = [error localizedDescription];
	}];
}

- (void)_shakeView:(UIView *)view {

	CGRect frame = view.frame;
	__block NSUInteger shakes = 10;
	__block NSInteger amount = 5;
	__block void (^animate)() = ^{};

	void (^completion)(BOOL success) = ^(BOOL success) {
		shakes--;
		if (shakes == 0) {
			[UIView animateWithDuration:0.05f animations:^{
				view.frame = frame;
			}];
			return;
		}
		animate();
	};

	animate = ^{
		[UIView animateWithDuration:0.05f animations:^{
			CGRect rect = frame;
			rect.origin.x += amount;
			view.frame = rect;
			amount *= -1;
		} completion:completion];
	};
	
	animate();
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
		self.loginView.alpha = 0.0f;
		
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

-(IBAction)connectLive:(id)sender {
	MidasSettings *settings = [MidasSettings sharedSettings];
	[settings waitForSettings:^{
		
		NSString *server = settings.IPAddress;
		
		if (!server)
            server = @"10.0.1.165";
        /*
        {
			[self loadArchive:self];
			return;
		}
             */
		
		[[RacePadCoordinator Instance] SetServerAddress:server ShowWindow:YES LightRestart:false];
	}];
}

- (void)viewDidUnload
{
	[self setServerLabel:nil];
	[super viewDidUnload];
}

// ConnectionFeedbackDelegate methods

- (void)notifyConnectionSucceeded
{
    [[BasePadMedia Instance] connectToVideoServer];
    [[BasePadMedia Instance] resetConnectionCounts];
}

- (void)notifyConnectionRetry
{
}

- (void)notifyConnectionTimeout
{
}

- (void)notifyConnectionFailed
{
}

@end
