//
//  MidasTwitterViewController.m
//  Midas
//
//  Created by Daniel Tull on 10/08/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasTwitterViewController.h"
#import <DCTTextFieldValidator/DCTTextFieldValidator.h>
#import <DCTPullToRefresh/DCTPullToRefresh.h>
#import <DCTTableViewDataSources/DCTTableViewDataSources.h>
#import <DCTCoreDataStack/DCTCoreDataStack.h>
#import "TestFlight.h"

#import "MidasTwitter.h"
#import "MidasTweetTableViewCell.h"
#import "MidasSocialViewController.h"
#import "MidasTwitterProfileImageCache.h"
#import "MidasSettings.h"

@interface MidasTwitterViewController () <UITableViewDelegate, DCTPullToRefreshControllerDelegate>
@property (strong, nonatomic) IBOutlet DCTTextFieldValidator *textFieldValidator;
@property (strong, nonatomic) IBOutlet DCTPullToRefreshController *pullToRefreshController;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *tweetIndicator;
@end

@implementation MidasTwitterViewController {
	__strong MidasTwitter *_twitter;
	__strong DCTCoreDataStack *_coreDataStack;
	__strong DCTFetchedResultsTableViewDataSource *_dataSource;
	NSUInteger _unreadCount;
}
@synthesize tweetIndicator = _tweetIndicator;

- (id)init {
	return [self initWithNibName:@"MidasTwitterViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
	
	_coreDataStack = [[DCTCoreDataStack alloc] initWithStoreURL:[[self _applicationDocumentsDirectory] URLByAppendingPathComponent:@"MidasTwitter"]
													  storeType:NSInMemoryStoreType
												   storeOptions:nil
											 modelConfiguration:nil
													   modelURL:[[NSBundle mainBundle] URLForResource:@"MidasTwitter" withExtension:@"momd"]];
	
	_twitter = [MidasTwitter sharedTwitter];
	
	self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Twitter"
													image:[UIImage imageNamed:@"SocialMenuTabTwitter"]
													  tag:0];
	
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
		
	_dataSource = [DCTFetchedResultsTableViewDataSource new];
	_dataSource.managedObjectContext = _coreDataStack.managedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[MidasTwitterTweet entityName]];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:MidasTwitterTweetAttributes.date ascending:NO]];
	_dataSource.fetchRequest = fetchRequest;
	
	_dataSource.cellClass = [MidasTweetTableViewCell class];
	_dataSource.tableView = self.commentTableView;
	_dataSource.insertionAnimation = UITableViewRowAnimationNone;
	self.commentTableView.dataSource = _dataSource;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.midas_socialViewController.loginButton = self.loginButton;
	self.midas_socialViewController.backgroundImage = self.backgroundImageView.image;
	[self _refreshComments];
	[self _updateLoginState];
}


- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[TestFlight passCheckpoint:@"Twitter"];
}


#pragma mark - IBActions

- (IBAction)toggleLogin:(id)sender {
	
	if (_twitter.loggedIn) {
		[_twitter logout];
		[self _updateLoginState];
	} else
		[_twitter loginWithCompletion:^{
			[self _updateLoginState];
		}];
}

- (IBAction)comment:(id)sender {

	NSString *text = self.commentTextField.text;
	if ([text length] == 0) return;

	self.commentTextField.enabled = NO;

	void (^postComment)() = ^{
		NSURL *URL = [NSURL URLWithString:@"http://api.twitter.com/1/statuses/update.json"];
		NSString *status = [NSString stringWithFormat:@"%@ #f1", text];
		[self.tweetIndicator startAnimating];
		[[MidasTwitter sharedTwitter] postURL:URL parameters:@{@"status":status} handler:^(id tweetDictionary, NSError *error) {
			
			[self.tweetIndicator stopAnimating];
			
			self.commentTextField.enabled = YES;
			if (error) {
				[self _presentError:error];
				return;
			}

			NSManagedObjectContext *context = _coreDataStack.managedObjectContext;

			MidasTwitterTweet *tweet = [MidasTwitterTweet dct_objectFromDictionary:tweetDictionary
													insertIntoManagedObjectContext:context];

			tweet.readValue = YES;
			self.commentTextField.text = nil;
			[context dct_save];
		}];
	};
	
	if (_twitter.loggedIn) {
		postComment();
	} else
		[_twitter loginWithCompletion:^{
			[self _updateLoginState];
			postComment();
		}];
}

#pragma mark - DCTPullToRefreshControllerDelegate

- (void)pullToRefreshControllerDidChangeState:(DCTPullToRefreshController *)controller {
	
	if (controller.state == DCTPullToRefreshStateReleased)
		[self _refreshComments];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	id object = [_dataSource objectAtIndexPath:indexPath];
	return [MidasTweetTableViewCell heightForObject:object width:tableView.bounds.size.width];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

	MidasTwitterTweet *tweet = [_dataSource objectAtIndexPath:indexPath];

	if (!tweet.readValue) {
		[self _decrementUnreadCount];
		tweet.readValue = YES;
	}

	if (![cell isKindOfClass:[MidasTweetTableViewCell class]]) return;

	__weak MidasTwitterViewController *weakSelf = self;
	MidasTweetTableViewCell *tweetCell = (MidasTweetTableViewCell *)cell;
	tweetCell.retweetHandler = ^{
		[weakSelf _retweetTweet:tweet];
	};
}

#pragma mark - Private

- (void)_presentError:(NSError *)error {
	[[[UIAlertView alloc] initWithTitle:[error localizedDescription]
								message:[error localizedFailureReason]
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_retweetTweet:(MidasTwitterTweet *)tweet {

	NSManagedObjectContext *context = tweet.managedObjectContext;
	NSString *URLString = [NSString stringWithFormat:@"http://api.twitter.com/1/statuses/retweet/%@.json", tweet.tweetID];
	NSURL *URL = [NSURL URLWithString:URLString];
	
	[_twitter loginWithCompletion:^{
		[self _updateLoginState];
		[_twitter postURL:URL parameters:nil handler:^(id object, NSError *error) {
			
			if (error) {
				[self _presentError:error];
				return;
			}
			
			[context performBlock:^{
				tweet.userRetweeted = @(YES);
				[context dct_save];
			}];
		}];
	}];
}

- (void)_updateLoginState {
	
	if (_twitter.loggedIn) {
		[self.loginButton setTitle:@"Log Out" forState:UIControlStateNormal];
		[_twitter fetchUserWithHandler:^(id JSONObject, NSError *error) {

			NSManagedObjectContext *context = _coreDataStack.managedObjectContext;

			[context performBlock:^{
				[MidasTwitterUser dct_objectFromDictionary:JSONObject insertIntoManagedObjectContext:context];
				[context dct_save];
			}];

			NSString *username = [JSONObject objectForKey:@"screen_name"];
			
			CGFloat scale = [UIScreen mainScreen].scale;
			CGSize size = CGSizeMake(self.userImageView.bounds.size.width* scale, self.userImageView.bounds.size.height * scale);

			[[MidasTwitterProfileImageCache sharedCache] fetchImageForUsername:username size:size handler:^(UIImage *image) {
				dispatch_async(dispatch_get_main_queue(), ^{
					self.userImageView.image = image;
				});
			}];
		}];
		
	} else {
		[self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
		self.userImageView.image = nil;
	}
}

- (void)_refreshComments {
	
	if (self.pullToRefreshController.state == DCTPullToRefreshStateRefreshing)
		return;
	
	[self.pullToRefreshController startRefreshing];
	
	void (^handler)(id, NSError *) = ^(id JSONObject, NSError *error) {
		
		NSManagedObjectContext *context = _coreDataStack.managedObjectContext;
		
		[context performBlock:^{
			
			if (![JSONObject isKindOfClass:[NSDictionary class]]) {
				[self.pullToRefreshController stopRefreshing];
				return;
			}
				
			NSArray *tweets = [JSONObject objectForKey:@"results"];
			
			[tweets enumerateObjectsUsingBlock:^(NSDictionary *tweetDictionary, NSUInteger idx, BOOL *stop) {
				
				MidasTwitterTweet *tweet = [MidasTwitterTweet dct_objectFromDictionary:tweetDictionary
														insertIntoManagedObjectContext:context];
				tweet.user = [MidasTwitterUser dct_objectFromDictionary:tweetDictionary
													  insertIntoManagedObjectContext:context];
				
				if ([tweet isInserted]) [self _incrementUnreadCount];
			}];
			
			[context dct_saveWithCompletionHandler:^(BOOL success, NSError *error) {
				dispatch_async(dispatch_get_main_queue(), ^{
					[self.pullToRefreshController stopRefreshing];
				});
			}];
		}];
	};
	
	MidasSettings *settings = [MidasSettings sharedSettings];
	[settings waitForSettings:^{
		[_twitter getURL:[NSURL URLWithString:@"http://search.twitter.com/search.json"]
			  parameters:@{ @"q" : settings.hashtag }
				 handler:handler];
	}];
}

- (void)_incrementUnreadCount {
	dispatch_async(dispatch_get_main_queue(), ^{
		_unreadCount++;
		[self _updateBadge];
	});
}

- (void)_decrementUnreadCount {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (_unreadCount == 0) return;
		_unreadCount--;
		[self _updateBadge];
	});
}

- (void)_updateBadge {
	if (_unreadCount == 0)
		self.tabBarItem.badgeValue = nil;
	else
		self.tabBarItem.badgeValue = [NSString stringWithFormat:@"%i", _unreadCount];
}

- (NSURL *)_applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)viewDidUnload {
	[self setTweetIndicator:nil];
	[super viewDidUnload];
}
@end
