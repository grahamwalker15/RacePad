//
//  MidasTabViewController.m
//  Midas
//
//  Created by Daniel Tull on 14.08.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasSocialViewController.h"
#import "MidasSocialTableViewCell.h"

@interface MidasSocialViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *buttonContainer;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITableView *tabTableView;
@property (weak, nonatomic) IBOutlet UIImageView *topBackgroundImageView;
@end

@implementation MidasSocialViewController {
	__strong NSArray *_viewControllers;
	__strong DCTArrayTableViewDataSource *_tableViewDataSource;
}

- (id)initWithViewControllers:(NSArray *)viewControllers {
	self = [self init];
	if (!self) return nil;
	_viewControllers = viewControllers;
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	_tableViewDataSource = [DCTArrayTableViewDataSource new];
	_tableViewDataSource.array = self.viewControllers;
	_tableViewDataSource.cellClass = [MidasSocialTableViewCell class];
	_tableViewDataSource.cellConfigurer = ^(MidasSocialTableViewCell *cell, NSIndexPath *indexPath, UIViewController *viewController) {
		cell.imageView.image = viewController.tabBarItem.image;
	};
	self.tabTableView.dataSource = _tableViewDataSource;
	_tableViewDataSource.tableView = self.tabTableView;
	
	UIImage *image = [self.titleImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)];
	self.titleImageView.image = image;
	self.titleLabel.text = NSLocalizedString(@"social", @"Social popup title");
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	[self.tabTableView selectRowAtIndexPath:indexPath
								   animated:NO
							 scrollPosition:UITableViewScrollPositionTop];
	[self tableView:self.tabTableView didSelectRowAtIndexPath:indexPath];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage {
	_backgroundImage = backgroundImage;
	self.topBackgroundImageView.image = _backgroundImage;
}

- (void)setLoginButton:(UIButton *)loginButton {
	_loginButton = loginButton;
	[self.buttonContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.buttonContainer addSubview:loginButton];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView
didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {

	UIViewController *viewController = [_tableViewDataSource objectAtIndexPath:indexPath];
	[viewController willMoveToParentViewController:nil];
	[viewController.view removeFromSuperview];
	[viewController removeFromParentViewController];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UIViewController *viewController = [_tableViewDataSource objectAtIndexPath:indexPath];
	BOOL viewControllerHasParent = (viewController.parentViewController != nil);

	if (!viewControllerHasParent)
		[self addChildViewController:viewController];

	viewController.view.frame = self.contentView.bounds;
	[self.contentView addSubview:viewController.view];

	if (!viewControllerHasParent)
		[viewController didMoveToParentViewController:self];
}

@end

@implementation  UIViewController (MidasSocialViewController)

- (MidasSocialViewController *)midas_socialViewController {

	if ([self isKindOfClass:[MidasSocialViewController class]])
		return (MidasSocialViewController *)self;

	return [self.parentViewController midas_socialViewController];
}

@end
