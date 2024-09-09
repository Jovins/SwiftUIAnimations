//
//  TBCommunityViewController.h
//  TheBump
//
//  Created by Goran Svorcan on 7/17/14.
//  Copyright (c) 2014 xo group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBCommunityNavigationDelegate.h"
#import "TBCommunityAllForumsViewController.h"

@interface TBCommunityViewController : UIViewController <TBCommunityNavigationDelegate>

- (void)prepareCommunityToLoadURLString:(NSString *)url withName:(NSString *)name;

@end
