//
//  MidasHelpViewController.m
//  MidasDemo
//
//  Created by Daniel Tull on 07/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasHelpViewController.h"
#import "MidasHelpTableViewCell.h"
#import "TestFlight.h"

@interface MidasHelpViewController () <UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *titleImageView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end

@implementation MidasHelpViewController {
	__strong NSArray *_helpArray;
	__strong DCTHorizontalTableViewDataSource *_dataSource;
}

#pragma mark - UIViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (!self) return nil;
	_helpArray = [self _fetchMidasHelp];
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIImage *image = [self.titleImageView.image resizableImageWithCapInsets:UIEdgeInsetsMake(0.0f, 13.0f, 0.0f, 13.0f)];
	self.titleImageView.image = image;
	self.titleLabel.text = NSLocalizedString(@"midas.help.title", @"Help popup title");
	
	DCTArrayTableViewDataSource *dataSource = [DCTArrayTableViewDataSource new];
	dataSource.array = _helpArray;
	dataSource.cellClass = [MidasHelpTableViewCell class];
	
	_dataSource = [DCTHorizontalTableViewDataSource new];
	_dataSource.childTableViewDataSource = dataSource;
	
	self.tableView.dataSource = _dataSource;
	_dataSource.tableView = self.tableView;
	
	self.pageControl.numberOfPages = [_helpArray count];

	[TestFlight passCheckpoint:@"Help"];
}

- (IBAction)pageControlDidChangeValue:(id)sender {
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.pageControl.currentPage inSection:0];
	[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	self.pageControl.currentPage = (NSUInteger)(self.tableView.contentOffset.y / self.tableView.bounds.size.height);
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return self.tableView.bounds.size.height;
}


#pragma mark - Private

- (NSArray *)_fetchMidasHelp {
	NSURL *JSONURL = [[NSBundle mainBundle] URLForResource:@"MidasHelp" withExtension:@"json"];
	NSData *JSONData = [NSData dataWithContentsOfURL:JSONURL];
	return [NSJSONSerialization JSONObjectWithData:JSONData options:0 error:NULL];
}

@end
