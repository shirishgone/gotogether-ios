//
//  GTFacebookPublicProfileViewController.m
//  goTogether
//
//  Created by shirish gone on 05/11/14.
//  Copyright (c) 2014 gotogether. All rights reserved.
//

#import "GTFacebookPublicProfileViewController.h"

@interface GTFacebookPublicProfileViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation GTFacebookPublicProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Facebook Profile";

    [self setupWebView];
    [self loadFacebookProfile];
}

- (void)setupWebView {
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"FacebookPublicProfile"];
}

- (void)loadFacebookProfile {
    NSString *urlAddress = [NSString stringWithFormat:@"http://www.facebook.com/%@",self.facebookId];
    NSURL *url = [NSURL URLWithString:urlAddress];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:requestObj];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self displayLoadingView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self hideStatusMessage];
}


@end
