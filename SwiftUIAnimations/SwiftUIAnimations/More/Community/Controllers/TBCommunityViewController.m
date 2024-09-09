//
//  TBCommunityViewController.m
//  TheBump
//
//  Created by Goran Svorcan on 7/17/14.
//  Copyright (c) 2014 xo group. All rights reserved.
//

#import "TBCommunityViewController.h"
#import "TBBirthClubSelectionViewController.h"
#import "TBCommunityDataManager.h"
#import "UIViewController+TheBump.h"
#import "UINavigationController+DefaultStyle.h"
#import <TheBump-Swift.h>
#import <FullStory/FullStory.h>

static NSString *const kCommunityRulesLink = @"https://pregnant.thebump.com/extras/the-bump-community-extras/articles/community-rules.aspx";

static NSTimeInterval const kCommunityControllerAnimationDuration = 0.2;

@interface TBCommunityViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) TBBirthClubSelectionViewController *birthClubViewController;
@property (nonatomic, strong) TBCommunityAllForumsViewController *allForumsViewController;

@property (nonatomic, strong) UIViewController *currentViewController;

// Properties to load from different tabs.
@property (nonatomic, assign) BOOL isPreparedToLoadExternalLink;
@property (nonatomic, strong) NSString *externalUrlToLoad;
@property (nonatomic, strong) NSString *screenTitleWhileLoadingExternalUrl;

@end

@implementation TBCommunityViewController

#pragma mark - UIAlertViewDelegate Methods

- (void)registerScreenshot {
    [TBAnalyticsManager logEventNamed:kAnalyticsEventTakeScreenshot
                       withProperties:@{kAnalyticsKeyScreenName: @"community"}];
}

- (NSString *)descriptionGA {
    return @"Community Landing Screen View";
}

- (NSString *)screenName {
    return @"Community Landing Screen";
}

- (void)loadView {
    [super loadView];
    
    _allForumsViewController = [[TBCommunityAllForumsViewController alloc] init];
    _allForumsViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    _allForumsViewController.communityNavigationDelegate = self;
    [self addChildViewController:_allForumsViewController];
    [self.view addSubview:_allForumsViewController.view];
    [_allForumsViewController didMoveToParentViewController:self];
    
    _birthClubViewController = [[TBBirthClubSelectionViewController alloc] init];
    _birthClubViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    _birthClubViewController.communityNavigationDelegate = self;
    
    [self setupAllForumsViewConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationItem.title = [@"COMMUNITY" capitalizedWithoutPrepositionObjc];
    [self showCommunityOnboardingIfNeeded];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self screenViewed];

    if (self.isPreparedToLoadExternalLink) {
        self.isPreparedToLoadExternalLink = NO;
        [self.allForumsViewController navigateToForumURLString:self.externalUrlToLoad
                                                      withName:self.screenTitleWhileLoadingExternalUrl];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(registerScreenshot)
                                                 name:UIApplicationUserDidTakeScreenshotNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.birthClubViewController.parentViewController) {
        [self performAlphaTransitionFromViewController:self.birthClubViewController
                                      toViewController:self.allForumsViewController
                                          withDuration:kCommunityControllerAnimationDuration
                                    andCompletionBlock:^{
                                        [self.allForumsViewController endAppearanceTransition];
                                    }];
        
        [self setupAllForumsViewConstraints];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationUserDidTakeScreenshotNotification
                                                  object:nil];
}

- (void)setupAllForumsViewConstraints {
    NSDictionary *viewsDictionary = @{@"_allForumsViewController" : self.allForumsViewController.view};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_allForumsViewController]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_allForumsViewController]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

- (void)setupBirthClubSelectionViewConstraints {
    NSDictionary *viewsDictionary = @{@"_birthClubViewController" : self.birthClubViewController.view};
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_birthClubViewController]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_birthClubViewController]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}

- (void)showCommunityOnboardingIfNeeded {
    if ([[TBCommunityDataManager sharedInstance] doesUserNeedToSeeOnboarding]) {
        TBCommunityWelcomeViewController *communityWelcomeViewController = [[TBCommunityWelcomeViewController alloc] init];
        communityWelcomeViewController.modalPresentationStyle = UIModalPresentationFullScreen;
        [FS removeClass:communityWelcomeViewController.view className:FSViewClassMask];
        [FS addClass:communityWelcomeViewController.view className:FSViewClassUnmask];
        [self presentViewController:communityWelcomeViewController
                           animated:NO
                         completion:nil];
    }
}

#pragma mark - TBCommunityNavigationDelegate Methods

- (void)presentBirthClubSelectionViewWithList:(NSArray *)birthClubs
                       andSelectedBirthClubId:(NSNumber *)birthClubId {
    self.birthClubViewController.bClubListArray = birthClubs;
    self.birthClubViewController.selectedBirthClub = birthClubId;
    [self performAlphaTransitionFromViewController:self.allForumsViewController
                                  toViewController:self.birthClubViewController
                                      withDuration:kCommunityControllerAnimationDuration
                                andCompletionBlock:^{
                                    [self.birthClubViewController endAppearanceTransition];
                                }];
    
    [self setupBirthClubSelectionViewConstraints];
}

- (void)presentAllForumsViewAndHasBirthClubSelectionChanged:(BOOL)hasChanged {
    [self performAlphaTransitionFromViewController:self.birthClubViewController
                                  toViewController:self.allForumsViewController
                                      withDuration:kCommunityControllerAnimationDuration
                                andCompletionBlock:^{
                                    [self.allForumsViewController endAppearanceTransition];
                                    if (hasChanged) {
                                        [self.allForumsViewController presentBirthClubSelectionConfirmation];
                                    }
                                }];
    
    [self setupAllForumsViewConstraints];
}

#pragma mark - External Methods

- (void)prepareCommunityToLoadURLString:(NSString *)url withName:(NSString *)name {
    self.isPreparedToLoadExternalLink = YES;
    self.externalUrlToLoad = url;
    self.screenTitleWhileLoadingExternalUrl = name;
}

@end
