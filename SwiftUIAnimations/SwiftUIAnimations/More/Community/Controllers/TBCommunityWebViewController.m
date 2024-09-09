//
//  TBCommunityWebViewController.m
//  TheBump
//
//  Created by Goran Svorcan on 9/29/15.
//  Copyright (c) 2015 xo group. All rights reserved.
//

#import "TBCommunityWebViewController.h"
#import "NSString+TheBump.h"
#import <TheBump-Swift.h>

@interface TBCommunityWebViewController ()

@property (nonatomic, assign) BOOL didLoadUrl;
@property (nonatomic, assign) BOOL didFinishPreloadingUrl;

@property (nonatomic, strong) NSArray *webViewHorizontalConstraints;
@property (nonatomic, strong) NSArray *webViewVerticalConstraints;

@property (nonatomic, strong) UIActivityIndicatorView *aLoader;
@property (nonatomic, strong) NSLayoutConstraint *loaderVerticalConstraint;
@property (nonatomic, strong) NSLayoutConstraint *loaderHorizontalConstraint;

@property (nonatomic, strong) WKProcessPool *sharedProcessPool;
@property (nonatomic, strong) WKWebViewConfiguration* webViewConfig;

@end

@implementation TBCommunityWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupOneTrustObserver];

        _webViewConfig = WKWebViewConfiguration.new;
        if (@available(iOS 13.0, *)) {
            _webViewConfig.defaultWebpagePreferences.preferredContentMode = WKContentModeMobile;
        }
        _webViewConfig.allowsInlineMediaPlayback = YES;
        _webViewConfig.processPool = self.sharedProcessPool;

        _wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:_webViewConfig];
        _wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
        _wkWebView.navigationDelegate = self;
        _wkWebView.opaque = NO;
        _wkWebView.backgroundColor = UIColor.OffWhite;
        _wkWebView.scrollView.backgroundColor = UIColor.OffWhite;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    self.navigationItem.title = self.titleString;
    
    // If being presented modally, we need a done button to dismiss it. Otherwise if it was just pushed onto a navigation stack, it'll have the back button for dismissal.
    if (self.presentingViewController) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(doneButtonPressed:)];
    }
    
    [self.view addSubview:_wkWebView];
    
    _aLoader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _aLoader.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:_aLoader];
    
    [self.view bringSubviewToFront:_aLoader];
    
    [self setupAndResetWebViewConstraints];

    [self observerConsentUpdate];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (!self.didFinishPreloadingUrl && !self.didLoadUrl) {
        self.didLoadUrl = YES;
        [self setupURLRequest];
        
        [self.wkWebView loadRequest:self.requestToLoad];
        
        [self showLoader:YES];
    } else if (self.didFinishPreloadingUrl && !self.didLoadUrl) {
        self.didLoadUrl = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self screenViewed];
}

- (NSString *)descriptionGA {
    if (_titleString == nil) {
        return @"Page View";;
    } else {
        return [NSString stringWithFormat:@"%@ Page View", _titleString];
    }
}

// On any subclass of this view controller, put any URL request setup procedures here.
- (void)setupURLRequest {
    self.requestToLoad = [NSMutableURLRequest requestWithURL:self.urlToLoad];
}

- (void)explicitlyLoadUrlInWebview:(NSURL *)url {
    self.requestToLoad = [NSMutableURLRequest requestWithURL:url];
    
    [self.wkWebView loadRequest:self.requestToLoad];
    
    [self showLoader:YES];
}

- (void)preloadUrl:(NSURL *)url {
    self.urlToLoad = url;
    [self setupURLRequest];
    
    [self.wkWebView loadRequest:self.requestToLoad];
    
    [self showLoader:YES];
}

- (void)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupAndResetWebViewConstraints {
    if (self.webViewHorizontalConstraints && [self.webViewHorizontalConstraints count] > 0) [self.view removeConstraints:self.webViewHorizontalConstraints];
    if (self.webViewVerticalConstraints && [self.webViewVerticalConstraints count] > 0) [self.view removeConstraints:self.webViewVerticalConstraints];
    if (self.loaderHorizontalConstraint) [self.view removeConstraint:self.loaderHorizontalConstraint];
    if (self.loaderVerticalConstraint) [self.view removeConstraint:self.loaderVerticalConstraint];
    
    self.loaderHorizontalConstraint = [NSLayoutConstraint constraintWithItem:_aLoader
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0f
                                                                    constant:0.0f];
    
    self.loaderVerticalConstraint = [NSLayoutConstraint constraintWithItem:_aLoader
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self.view
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1.0f
                                                                  constant:0.0f];
    
    self.webViewHorizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_wkWebView]|"
                                                                                options:0
                                                                                metrics:nil
                                                                                  views:NSDictionaryOfVariableBindings(_wkWebView)];

    self.webViewVerticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_wkWebView]|"
                                                                              options:0
                                                                              metrics:nil
                                                                                views:NSDictionaryOfVariableBindings(_wkWebView)];
    
    [self.view addConstraints:self.webViewHorizontalConstraints];
    [self.view addConstraints:self.webViewVerticalConstraints];
    [self.view addConstraint:self.loaderHorizontalConstraint];
    [self.view addConstraint:self.loaderVerticalConstraint];
}

- (void)resetWebView {
    [self.wkWebView removeFromSuperview];

    WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;
    if (@available(iOS 13.0, *)) {
       webViewConfig.defaultWebpagePreferences.preferredContentMode = WKContentModeMobile;
    }
    webViewConfig.allowsInlineMediaPlayback = YES;
    webViewConfig.processPool = self.sharedProcessPool;

    self.wkWebView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:webViewConfig];
    self.wkWebView.translatesAutoresizingMaskIntoConstraints = NO;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.opaque = NO;
    self.wkWebView.backgroundColor = UIColor.OffWhite;
    self.wkWebView.scrollView.backgroundColor = UIColor.OffWhite;
    [self.view addSubview:self.wkWebView];
    
    [self.view bringSubviewToFront:self.aLoader];
    
    [self setupAndResetWebViewConstraints];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}

- (void)showLoader:(BOOL)show {
    self.aLoader.hidden = !show;
    if (show) {
        [self.aLoader startAnimating];
        
        [self performSelector:@selector(showLoader:)
                   withObject:nil
                   afterDelay:10];
    } else {
        [self.aLoader stopAnimating];
    }
}

- (WKProcessPool *)sharedProcessPool {
    if (!_sharedProcessPool) {
        _sharedProcessPool = [[WKProcessPool alloc] init];
    }
    return _sharedProcessPool;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    [self.wkWebView evaluateJavaScript:@"document.body.style.webkitTouchCallout='none';" completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self showLoader:NO];
    
    if (!self.didFinishPreloadingUrl) {
        self.didFinishPreloadingUrl = YES;
    }
    
    if (webView.canGoBack && [self.webNavigationBarDelegate respondsToSelector:@selector(placeBackButtonForWebView)]) {
        [self.webNavigationBarDelegate placeBackButtonForWebView];
    } else if (!webView.canGoBack && [self.webNavigationBarDelegate respondsToSelector:@selector(removeBackButtonForWebView)]) {
        [self.webNavigationBarDelegate removeBackButtonForWebView];
    }
    
    if (webView.canGoForward && [self.webNavigationBarDelegate respondsToSelector:@selector(placeForwardButtonForWebView)]) {
        [self.webNavigationBarDelegate placeForwardButtonForWebView];
    } else if (!webView.canGoForward && [self.webNavigationBarDelegate respondsToSelector:@selector(removeForwardButtonForWebView)]) {
        [self.webNavigationBarDelegate removeForwardButtonForWebView];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self showLoader:NO];
    
    if (webView.canGoBack && [self.webNavigationBarDelegate respondsToSelector:@selector(placeBackButtonForWebView)]) {
        [self.webNavigationBarDelegate placeBackButtonForWebView];
    } else if (!webView.canGoBack && [self.webNavigationBarDelegate respondsToSelector:@selector(removeBackButtonForWebView)]) {
        [self.webNavigationBarDelegate removeBackButtonForWebView];
    }
    
    if (webView.canGoForward && [self.webNavigationBarDelegate respondsToSelector:@selector(placeForwardButtonForWebView)]) {
        [self.webNavigationBarDelegate placeForwardButtonForWebView];
    } else if (!webView.canGoForward && [self.webNavigationBarDelegate respondsToSelector:@selector(removeForwardButtonForWebView)]) {
        [self.webNavigationBarDelegate removeForwardButtonForWebView];
    }
}

#pragma mark - One Trust SDK
- (void)setupOneTrustObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(observerConsentUpdate)
                                                 name:[OneTrustSDK.shared observerName]
                                               object:nil];
}

- (void)observerConsentUpdate {
    __weak typeof(self) weakSelf = self;
    [OneTrustSDK.shared sentConsentToWebView:self.webViewConfig.userContentController completion:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            [strongSelf.wkWebView reload];
        }
    }];
}

@end
