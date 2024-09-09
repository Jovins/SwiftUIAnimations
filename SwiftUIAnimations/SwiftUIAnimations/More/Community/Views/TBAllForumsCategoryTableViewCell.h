#import <UIKit/UIKit.h>

@interface TBAllForumsCategoryTableViewCell : UITableViewCell

- (void)setupCellWithName:(NSString *)categoryName;

- (void)setExpanded:(BOOL)expanded withAnimation:(BOOL)animation;

@property (nonatomic, strong) UILabel *categoryTitleLabel;
@property (nonatomic, strong) UIImageView *expansionArrow;

@end
