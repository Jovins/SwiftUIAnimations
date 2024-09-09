#import <UIKit/UIKit.h>

@interface TBAllForumsTableHeaderView : UITableViewHeaderFooterView

@property (nonatomic, strong) UIButton *headerButton;

- (void)setupHeaderWithTitle:(NSString *)title
              andButtonTitle:(NSString *)buttonTitle;

-(void)setupHeaderWithTitle:(NSString *)title;

@end
