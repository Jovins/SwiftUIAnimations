#import "TBCommunityEducationView.h"

@implementation TBCommunityEducationView

- (instancetype)init {
    self = [super init];
    if (self) {
        _educationScrollView = [[UIScrollView alloc] init];
        _educationScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        _educationScrollView.pagingEnabled = YES;
        _educationScrollView.showsHorizontalScrollIndicator = NO;
        _educationScrollView.bounces = NO;
        [self addSubview:_educationScrollView];
        
        _educationPageControl = [[UIPageControl alloc] init];
        _educationPageControl.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_educationPageControl];
        
        _closeButton = [[UIButton alloc] init];
        _closeButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_closeButton setImage:[UIImage imageNamed:@"iconCloseKO"] forState:UIControlStateNormal];
        [self addSubview:_closeButton];
        
        [self setupCommunityEducationViewConstraints];
    }
    return self;
}

- (void)setupCommunityEducationViewConstraints {
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_educationScrollView, _educationPageControl, _closeButton);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_educationScrollView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_educationScrollView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_educationPageControl]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_educationPageControl
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%f-[_closeButton]", [[UIApplication sharedApplication] statusBarFrame].size.height]
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_closeButton]-10-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:viewsDictionary]];
}

@end
