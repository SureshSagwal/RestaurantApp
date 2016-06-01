 

#import "InvalidTooltipView.h"
#import "TooltipViewPrivate.h"


@implementation InvalidTooltipView


#pragma mark - Update user interface

- (void)_buildUserInterface
{
    [super _buildUserInterface];
    
    // Set image
    self.image = [[UIImage imageNamed:@"image_tooltip_invalid.png"] stretchableImageWithLeftCapWidth:48.0 topCapHeight:18.0];
}

@end
