//
//  MidasFacebookViewController.m
//  Midas
//
//  Created by Daniel Tull on 17.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasFacebookViewController.h"

#import <DCTTextFieldValidator/DCTTextFieldValidator.h>
#import <Facebook/Facebook.h>
#import <DCTCoreDataStack/DCTCoreDataStack.h>
#import <DCTTableViewDataSources/DCTTableViewDataSources.h>
#import <DCTPullToRefresh/DCTPullToRefresh.h>
#import "TestFlight.h"

#import "MidasSocialViewController.h"
#import "MidasFacebookProfileImageCache.h"
#import "MidasFacebookComment.h"
#import "MidasFacebookTableViewCell.h"
#import "MidasSettings.h"

@interface MidasFacebookViewController () <UITableViewDelegate, DCTPullToRefreshControllerDelegate>
@property (strong, nonatomic) IBOutlet DCTTextFieldValidator *textFieldValidator;
@property (strong, nonatomic) IBOutlet DCTPullToRefreshController *pullToRefreshController;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (strong, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (weak, nonatomic) IBOutlet UIImageView *commentTextFieldBackground;
@property (weak, nonatomic) IBOutlet UIButton *commentUsingButton;
@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@end

@implementation MidasFacebookViewController {
	__strong DCTCoreDataStack *_coreDataStack;
	__strong DCTFetchedResultsTableViewDataSource *_dataSource;
	NSUInteger _unreadCount;
}

- (id)init {
	return [self initWithNibName:@"MidasFacebookViewController" bundle:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (!self) return nil;
		
	_coreDataStack = [[DCTCoreDataStack alloc] initWithStoreURL:[[self _applicationDocumentsDirectory] URLByAppendingPathComponent:@"MidasFacebook"]
													  storeType:NSInMemoryStoreType
												   storeOptions:nil
											 modelConfiguration:nil
													   modelURL:[[NSBundle mainBundle] URLForResource:@"MidasFacebook" withExtension:@"momd"]];
	
	self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Facebook"
													image:[UIImage imageNamed:@"SocialMenuTabFacebook"]
													  tag:0];
	
    return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIImage *image = self.commentTextFieldBackground.image;
	image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f)];
	self.commentTextFieldBackground.image = image;

	image = [self.commentUsingButton backgroundImageForState:UIControlStateNormal];
	image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(1.0f, 1.0f, 1.0f, 1.0f)];
	[self.commentUsingButton setBackgroundImage:image forState:UIControlStateNormal];
	
	_dataSource = [DCTFetchedResultsTableViewDataSource new];
	_dataSource.managedObjectContext = _coreDataStack.managedObjectContext;
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:[MidasFacebookComment entityName]];
	fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:MidasFacebookCommentAttributes.date ascending:NO]];
	_dataSource.fetchRequest = fetchRequest;
	
	_dataSource.cellClass = [MidasFacebookTableViewCell class];
	_dataSource.tableView = self.commentTableView;
	_dataSource.insertionAnimation = UITableViewRowAnimationNone;
	self.commentTableView.dataSource = _dataSource;

	[TestFlight passCheckpoint:@"Facebook"];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.midas_socialViewController.loginButton = self.loginButton;
	self.midas_socialViewController.backgroundImage = self.backgroundImageView.image;
	[self _refreshComments];
	[self _updateLoginState];
}

#pragma mark - IBActions

- (IBAction)toggleLogin:(id)sender {
	Facebook *facebook = [Facebook shared];

	if([facebook isSessionValid]) {
		[facebook logout];
		[self _updateLoginState];
	} else
		[self _authorizeFacebookWithCompletion:NULL];
}

- (IBAction)comment:(id)sender {
	Facebook *facebook = [Facebook shared];
	BOOL isLoggedIn = [facebook isSessionValid];
	if (!isLoggedIn) {
		[self toggleLogin:sender];
		return;
	}
	
	[self _authorizeFacebookWithCompletion:^{
		[facebook usingPermissions:@[@"publish_actions"] request:^(BOOL success) {
			
			MidasSettings *settings = [MidasSettings sharedSettings];
			[settings waitForSettings:^{
				NSString *graphPath = [NSString stringWithFormat:@"%@/comments", settings.facebookPostID];
				
				[facebook requestWithGraphPath:graphPath parameters:@{@"message" : self.commentTextField.text} requestMethod:@"POST" finalize:^(FBRequest *request) {
					
					[request addCompletionHandler:^(FBRequest *request, id result) {
						NSString *commentID = [result objectForKey:@"id"];
						[self _getCommentWithID:commentID];
						self.commentTextField.text = nil;
					}];
					
					[request addErrorHandler:^(FBRequest *request, NSError *error) {
						NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), error);
					}];
				}];
			}];
		}];
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
	return [MidasFacebookTableViewCell heightForObject:object width:tableView.bounds.size.width];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	MidasFacebookComment *comment = [_dataSource objectAtIndexPath:indexPath];
	
	if (!comment.readValue) {
		[self _decrementUnreadCount];
		comment.readValue = YES;
	}
	
	if (![cell isKindOfClass:[MidasFacebookTableViewCell class]]) return;
	
	__weak MidasFacebookViewController *weakSelf = self;
	MidasFacebookTableViewCell *commentCell = (MidasFacebookTableViewCell
											   *)cell;
	commentCell.likeHandler = ^{
		[weakSelf _likeComment:comment];
	};
}

#pragma mark - Private

- (void)_authorizeFacebookWithCompletion:(void(^)())completion {
	Facebook *facebook = [Facebook shared];
	
	if ([facebook isSessionValid]) {
		if (completion != NULL)
			completion();
		return;
	}
	
	[facebook authorize:@[@"user_about_me", @"publish_actions"] granted:^(Facebook *facebook) {
		[self _updateLoginState];
		if (completion != NULL) completion();
	} denied:^(Facebook *facebook) {}];
}

- (void)_likeComment:(MidasFacebookComment *)comment {
	
	Facebook *facebook = [Facebook shared];
	NSManagedObjectContext *context = comment.managedObjectContext;
	NSString *graphPath = [NSString stringWithFormat:@"%@/likes", comment.commentID];
	
	[self _authorizeFacebookWithCompletion:^{
		[facebook usingPermissions:@[@"publish_actions"] request:^(BOOL success) {
			[facebook requestWithGraphPath:graphPath parameters:nil completion:^(FBRequest *request, id result) {
				
				[context performBlock:^{
					comment.likesCountValue++;
					comment.userLiked = @(YES);
					[comment.managedObjectContext dct_save];
				}];
			}];
		}];
	}];
}

- (void)_updateLoginState {
	Facebook *facebook = [Facebook shared];
	BOOL isLoggedIn = [facebook isSessionValid];

	dispatch_async(dispatch_get_main_queue(), ^{
		if (isLoggedIn) {
			[self.loginButton setTitle:@"Log Out" forState:UIControlStateNormal];
			[self.commentUsingButton setTitle:@"Comment" forState:UIControlStateNormal];
			
			[facebook fetchMe:^(NSDictionary *me) {
				NSString *userID = [me objectForKey:@"id"];

				CGFloat scale = [UIScreen mainScreen].scale;
				CGSize size = CGSizeMake(self.userImageView.bounds.size.width* scale, self.userImageView.bounds.size.height * scale);

				[[MidasFacebookProfileImageCache sharedCache] fetchImageForUserID:userID size:size handler:^(UIImage *image) {
					dispatch_async(dispatch_get_main_queue(), ^{
						self.userImageView.image = image;
					});
				}];
			} error:NULL];

		} else {
			[self.loginButton setTitle:@"Log In" forState:UIControlStateNormal];
			[self.commentUsingButton setTitle:@"Log In to Comment" forState:UIControlStateNormal];
			self.userImageView.image = nil;
		}
		self.commentTextField.enabled = isLoggedIn;
	});
}

- (void)_getCommentWithID:(NSString *)commentID {
	
	Facebook *facebook = [Facebook shared];
	[facebook requestWithGraphPath:commentID parameters:nil completion:^(FBRequest *request, id result) {
		
		if (![result isKindOfClass:[NSDictionary class]]) return;
		
		NSManagedObjectContext *context = _coreDataStack.managedObjectContext;
		
		[context performBlock:^{
			
			MidasFacebookComment *comment = [MidasFacebookComment dct_objectFromDictionary:result
															insertIntoManagedObjectContext:context];
			comment.read = @(YES);
			[context dct_save];
		}];
	}];
}

- (void)_refreshComments {

	if (self.pullToRefreshController.state == DCTPullToRefreshStateRefreshing)
		return;

	[self.pullToRefreshController startRefreshing];
	
	void (^completion)(FBRequest *, id) = ^(FBRequest *request, id result) {
		
		NSManagedObjectContext *context = _coreDataStack.managedObjectContext;
		
		[context performBlock:^{
			NSArray *commentArray = [result objectForKey:@"data"];
			
			[commentArray enumerateObjectsUsingBlock:^(NSDictionary *commentDictionary, NSUInteger idx, BOOL *stop) {
				
				MidasFacebookComment *comment = [MidasFacebookComment dct_objectFromDictionary:commentDictionary
																insertIntoManagedObjectContext:context];
				if ([comment isInserted]) [self _incrementUnreadCount];
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
		Facebook *facebook = [Facebook shared];
		NSString *graphPath = [NSString stringWithFormat:@"%@/comments", settings.facebookPostID];
		[facebook requestWithGraphPath:graphPath parameters:nil completion:completion];
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

@end
