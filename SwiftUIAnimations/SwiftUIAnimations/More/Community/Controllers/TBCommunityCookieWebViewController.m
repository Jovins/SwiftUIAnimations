//
//  TBCommunityCookieWebViewController.m
//  TheBump
//
//  Created by Goran Svorcan on 9/29/15.
//  Copyright (c) 2015 xo group. All rights reserved.
//

#import "TBCommunityCookieWebViewController.h"
#import <TheBump-Swift.h>

@interface TBCommunityCookieWebViewController ()

@property (nonatomic, strong) UIBarButtonItem *backButton;

@end

@implementation TBCommunityCookieWebViewController

- (void)loadView {
    [super loadView];
    
    if (self.shouldBecomeWebviewNavigationBarDelegate) {
        self.webNavigationBarDelegate = self;
    }
}

- (void)setupURLRequest {
    [self setupSharedCookieStorageAndRequestToAcceptCookies];
}

- (void)setupSharedCookieStorageAndRequestToAcceptCookies {
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    self.requestToLoad = [NSMutableURLRequest requestWithURL:self.urlToLoad];
    
    [self.requestToLoad setHTTPShouldHandleCookies:YES];
}

- (void)createCookieWithTheAuthTokenInSharedCookieStorage {
    NSString *authToken = [[TBMemberDataManager sharedInstance] authenticationToken] ? [[TBMemberDataManager sharedInstance] authenticationToken] : @"";
    
    NSHTTPCookieStorage *sharedCookieSTorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
#ifdef DEBUG
    NSDictionary *properties = @{NSHTTPCookieName : @"TMPAUTHTIX-qa",
                                 NSHTTPCookieValue : authToken,
                                 NSHTTPCookieDomain : @".thebump.com",
                                 NSHTTPCookiePath : @"/"};
#else
    NSDictionary *properties = @{NSHTTPCookieName : @"TMPAUTHTIX",
                                 NSHTTPCookieValue : authToken,
                                 NSHTTPCookieDomain : @".thebump.com",
                                 NSHTTPCookiePath : @"/"};
#endif
    
    NSHTTPCookie *cookie = [[NSHTTPCookie alloc] initWithProperties:properties];
    [sharedCookieSTorage setCookie:cookie];

    
}

#pragma mark - TBWebViewNavigationBar Delegate Methods

- (void)placeBackButtonForWebView {
    self.navigationItem.leftBarButtonItem = self.backButton;
}

- (void)removeBackButtonForWebView {
    self.navigationItem.leftBarButtonItem = nil;
    self.backButton = nil;
}

- (void)backButtonPressed:(UIBarButtonItem *)button {
    if (self.wkWebView.canGoBack) {
        [self.wkWebView goBack];
    }
}

#pragma mark - Properties

- (UIBarButtonItem *)backButton {
    if (!_backButton) {
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 44.0, 44.0)];
        [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:NavigationBarStyle.backButtonImage forState:UIControlStateNormal];
        backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -30.0, 0, 0);
        _backButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _backButton;
}

@end
