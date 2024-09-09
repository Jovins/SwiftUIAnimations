#import "TBAllForumsCategoryTableViewCell.h"
#import <TheBump-Swift.h>

@implementation TBAllForumsCategoryTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = UIColor.OffWhite;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _categoryTitleLabel = [[UILabel alloc] init];
        _categoryTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _categoryTitleLabel.font = UIFont.mulishBody1;
        _categoryTitleLabel.textColor = [UIColor tb_primaryCopy];
        [self.contentView addSubview:_categoryTitleLabel];
        
        _expansionArrow = [[UIImageView alloc] initWithImage:[UIImage caretRight]];
        _expansionArrow.translatesAutoresizingMaskIntoConstraints = NO;
        _expansionArrow.contentMode = UIViewContentModeScaleAspectFit;
        _expansionArrow.backgroundColor = [UIColor clearColor];
        _expansionArrow.transform = CGAffineTransformMakeRotation(M_PI / 2);
        [self.contentView addSubview:_expansionArrow];
        
        [self setupAllForumsCategoryCellConstraints];
    }
    return self;
}

- (void)setupCellWithName:(NSString *)categoryName {
    self.categoryTitleLabel.text = [categoryName capitalizedString];
}

- (void)setExpanded:(BOOL)expanded withAnimation:(BOOL)animation {
    if (animation) {
        [UIView animateWithDuration:0.3
                         animations:^{
            self.contentView.backgroundColor = expanded ? [UIColor tb_linesWithAlpha:0.5f] : UIColor.OffWhite;
                             self.expansionArrow.transform = expanded ? CGAffineTransformMakeRotation((3 * M_PI) / 2) : CGAffineTransformMakeRotation(M_PI / 2);
                         }];
    } else {
        self.contentView.backgroundColor = expanded ? [UIColor tb_linesWithAlpha:0.5f] : UIColor.OffWhite;
        self.expansionArrow.transform = expanded ? CGAffineTransformMakeRotation((3 * M_PI) / 2) : CGAffineTransformMakeRotation(M_PI / 2);
    }
}

@end
