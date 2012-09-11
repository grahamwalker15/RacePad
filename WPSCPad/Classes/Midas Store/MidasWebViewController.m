//
//  MidasWebViewController.m
//  MidasDemo
//
//  Created by Daniel Tull on 07/09/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "MidasWebViewController.h"

@interface MidasWebViewController ()
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *backBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *forwardBarButtonItem;
@end

@implementation MidasWebViewController {
	__strong NSURL *_URL;
}

#pragma mark - NSObject

- (id)init {
	return [self initWithNibName:@"MidasWebViewController" bundle:nil];
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.navigationItem.rightBarButtonItem = self.navigationBar.topItem.rightBarButtonItem;
	[self.navigationBar setItems:@[self.navigationItem] animated:NO];
	[self _updateButtonStates];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.webView loadRequest:[NSURLRequest requestWithURL:_URL]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

#pragma mark - MidasWebViewController

- (id)initWithURL:(NSURL *)URL {
	self = [self init];
	if (!self) return nil;
	_URL = [URL copy];
	_backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(webViewBack:)];
	_forwardBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Forward" style:UIBarButtonItemStyleBordered target:self action:@selector(webViewForward:)];
	self.navigationItem.leftBarButtonItems = @[ _backBarButtonItem, _forwardBarButtonItem ];
	return self;
}

- (IBAction)webViewBack:(id)sender {
	[self.webView goBack];
}

- (IBAction)webViewForward:(id)sender {
	[self.webView goForward];
}

- (IBAction)dismiss:(id)sender {
	[self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}

- (void)_updateButtonStates {
	self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	self.backBarButtonItem.enabled = self.webView.canGoBack;
	self.forwardBarButtonItem.enabled = self.webView.canGoForward;
}

#pragma mark - UIWebViewDelegate

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[self _updateButtonStates];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self _updateButtonStates];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	[self _updateButtonStates];
}

@end
