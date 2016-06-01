

#import <UIKit/UIKit.h>
#import "Rule.h"

@interface TooltipView : UIImageView
{
@protected
    UILabel  *_textLabel;
    NSString *_text;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic,retain) Rule *rule;
@end
