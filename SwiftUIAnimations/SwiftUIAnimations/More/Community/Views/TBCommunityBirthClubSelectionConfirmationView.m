#import "TBCommunityBirthClubSelectionConfirmationView.h"

@interface TBCommunityBirthClubSelectionConfirmationView ()

@property (nonatomic, strong) UIImageView *confirmationCheckbox;
@property (nonatomic, strong) UILabel *confirmationLabel;

@end

@implementation TBCommunityBirthClubSelectionConfirmationView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor tb_alertsAndTimestamps];
        
        _confirmationCheckbox = [[UIImageView alloc] init];
        _confirmationCheckbox.translatesAutoresizingMaskIntoConstraints = NO;
        _confirmationCheckbox.contentMode = UIViewContentModeCenter;
        _confirmationCheckbox.image = [UIImage imageNamed:@"ConfirmationAlertSymbol"];
        [self addSubview:_confirmationCheckbox];
        
        _confirmationLabel = [[UILabel alloc] init];
        _confirmationLabel.translatesAutoresizingMaskIntoConstraints = NO;
        NSMutableAttributedString *confirmationText = [NSMutableAttributedString tb_tbVoiceWithText:@"Default Birth Club saved!\nYou can change it at any time on the All Forums screen."
                                                                                        andAlignment:NSTextAlignmentLeft];
        [confirmationText addAttribute:NSForegroundColorAttributeName
                                 value:[UIColor whiteColor]
                                 range:NSMakeRange(0, [confirmationText length])];
        _confirmationLabel.attributedText = confirmationText;
        _confirmationLabel.numberOfLines = 0;
        [_confirmationLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_confirmationLabel];
        
        CGRect textHeight = [_confirmationLabel.attributedText boundingRectWithSize:CGSizeMake(kDeviceWidth - 48.0f - _confirmationCheckbox.image.size.width, CGFLOAT_MAX)
                                                                            options:NSStringDrawingUsesLineFragmentOrigin
                                                                            context:nil];
        self.minHeight = CGRectGetHeight(textHeight) + 20.0f;
        
        [self setupCommunityBirthClubSelectionConfirmationViewConstraints];
    }
    return self;
}

- (void)setupCommunityBirthClubSelectionConfirmationViewConstraints {
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_confirmationCheckbox, _confirmationLabel);
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[_confirmationCheckbox]-[_confirmationLabel]-20-|"
                                                                 options:NSLayoutFormatAlignAllCenterY
                                                                 metrics:nil
                                                                   views:viewsDictionary]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:_confirmationCheckbox
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
}

@end
