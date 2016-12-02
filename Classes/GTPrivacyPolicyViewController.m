//
//  TAPrivacyPolicyViewController.m
//  goTogether
//
//  Created by shirish on 06/03/13.
//  Copyright (c) 2013 gotogether. All rights reserved.
//

#import "GTPrivacyPolicyViewController.h"

@interface GTPrivacyPolicyViewController ()

@property (nonatomic, strong) IBOutlet UIWebView *webView;

@end

@implementation GTPrivacyPolicyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadPrivacyPolicy];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self trackScreenName:@"PrivacyPolicy"];
}


- (void)loadPrivacyPolicy {
    NSString *urlAddress = @"http://www.gotogether.mobi/terms.html";
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

- (IBAction)cancelButtonTouched:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
