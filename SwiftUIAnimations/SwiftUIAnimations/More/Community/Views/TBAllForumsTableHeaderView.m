#import "TBAllForumsTableHeaderView.h"
#import <TheBump-Swift.h>

@interface TBAllForumsTableHeaderView ()

@property (nonatomic, strong) UILabel *headerTitle;

@end

@implementation TBAllForumsTableHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        // This is necessary because of how iOS7 treats autolayout for table view cells. The size of the content view is not adjusted until after the constraints are applied, so all the constratins will assume a height of 44 for the content view, which leads to unstatisfiable constraints if there are fixed heights that add up to more than 44. So we give the content view an autoresizing mask to account for this.
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;

        self.contentView.backgroundColor = UIColor.OffWhite;
        
        _headerTitle = [[UILabel alloc] init];
        _headerTitle.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_headerTitle];
        
        _headerButton = [[UIButton alloc] init];
        _headerButton.translatesAutoresizingMaskIntoConstraints = NO;
        _headerButton.backgroundColor = UIColor.OffWhite;
        _headerButton.titleLabel.font = UIDevice.isPad ? UIFont.mulishLink1 : UIFont.mulishLink3;
        _headerButton.titleLabel.backgroundColor = UIColor.OffWhite;
        [_headerButton setTitleColor:UIColor.Magenta forState:UIControlStateNormal];
        [self.contentView addSubview:_headerButton];
        
        [self setupAllForumsTableHeaderConstraints];
    }
    return self;
}

- (void)setupHeaderWithTitle:(NSString *)title
              andButtonTitle:(NSString *)buttonTitle {
    NSMutableAttributedString *titleText = [NSMutableAttributedString tb_header4WithText:[title capitalizedString] andAlignment:NSTextAlignmentLeft];
    [titleText addAttribute:NSForegroundColorAttributeName value:[UIColor tb_secondaryCopy] range:NSMakeRange(0, [titleText length])];
    [titleText removeAttribute:NSParagraphStyleAttributeName range:NSMakeRange(0, [titleText length])];
    self.headerTitle.attributedText = titleText;

    [self.headerButton setTitle:[buttonTitle capitalizedString] forState:UIControlStateNormal];
    self.headerButton.hidden = !buttonTitle || [buttonTitle length] == 0;
}

-(void)setupHeaderWithTitle:(NSString *)title {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.minimumLineHeight = [UIFont header4LineHeight];
    style.maximumLineHeight = [UIFont header4LineHeight];

    NSDictionary *titleAttributes = @{NSFontAttributeName: [UIFont header4],
                                 NSForegroundColorAttributeName: [UIColor tb_secondaryCopy],
                                 NSParagraphStyleAttributeName: style};

    NSMutableAttributedString *titleText = [[NSMutableAttributedString alloc] initWithString: [title capitalizedString]
                                                                                  attributes: titleAttributes];
    self.headerTitle.attributedText = titleText;
    self.headerButton.hidden = YES;
}

- (void)setupAllForumsTableHeaderConstraints {
    CGFloat width = [UIDevice isPad]? 100 : 62;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(_headerTitle, _headerButton);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[_headerTitle]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:viewsDictionary]];

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_headerTitle][_headerButton(headerButtonWidth)]|"
                                                                             options:NSLayoutFormatAlignAllBaseline
                                                                             metrics:@{@"headerButtonWidth": @(width)}
                                                                               views:viewsDictionary]];
}

@end
