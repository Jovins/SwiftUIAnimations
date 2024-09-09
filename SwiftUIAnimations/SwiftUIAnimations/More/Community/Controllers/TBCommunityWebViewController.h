//
//  TBCommunityWebViewController.h
//  TheBump
//
//  Created by Goran Svorcan on 9/29/15.
//  Copyright (c) 2015 xo group. All rights reserved.
//

#import <UIKit/UIKit.h>

@import WebKit;

@protocol TBCommunityWebViewNavigationBarDelegate <NSObject>
- (void)placeBackButtonForWebView;
- (void)removeBackButtonForWebView;
@optional
- (void)placeForwardButtonForWebView;
- (void)removeForwardButtonForWebView;
@end

@interface TBCommunityWebViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSURL *urlToLoad;
@property (nonatomic, strong) NSMutableURLRequest *requestToLoad;
@property (nonatomic, strong) id<TBCommunityWebViewNavigationBarDelegate> webNavigationBarDelegate;

- (void)setupURLRequest;

- (void)explicitlyLoadUrlInWebview:(NSURL *)url;

- (void)preloadUrl:(NSURL *)url;
- (void)resetWebView;

- (void)showLoader:(BOOL)show;

@end
