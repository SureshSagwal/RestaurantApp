

#import "TooltipView.h"
#import "TooltipViewPrivate.h"

static const CGFloat kMargin = 23.0;

@implementation TooltipView

@synthesize text = _text;
@synthesize rule;

#pragma mark - Initialization

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        [self _buildUserInterface];
    }
    
    return self;
}

#pragma mark - Update user interface

- (void)_buildUserInterface
{
    // Let the tooltip resize automatically in width
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.userInteractionEnabled = YES;
    // Add text field
    CGRect textLabelFrame      = CGRectMake(0, 0.0, self.frame.size.width, 50.0);
    _textLabel                 = [[UILabel alloc] initWithFrame:textLabelFrame];
    _textLabel.textColor       = [UIColor redColor];
    _textLabel.font            = [UIFont fontWithName:@"HelveticaNeue-Bold" size: 12.0];
    _textLabel.numberOfLines   = 2;
    _textLabel.textAlignment=NSTextAlignmentRight;
//    _textLabel.minimumFontSize = 11.0;
    _textLabel.backgroundColor = [UIColor clearColor];
//    _textLabel.adjustsFontSizeToFitWidth = YES;
//    _textLabel.lineBreakMode   = UILineBreakModeWordWrap;
    _textLabel.shadowColor     = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.1];
    _textLabel.shadowOffset    = CGSizeMake(0.0, 0.5);
    [self addSubview:_textLabel];
}

#pragma mark - Update user interface

/**
 Update UI
*/
- (void)_updateUserInterface
{
    _textLabel.text = _text;
    
    // Update height of tooltip
    [self _collapseToContent];
}

/**
 Updating height of tooltip depending on label height
*/
- (void)_collapseToContent
{
    CGSize size = [_textLabel.text sizeWithFont:_textLabel.font
                              constrainedToSize:CGSizeMake(self.frame.size.width, 9999)
                                  lineBreakMode:_textLabel.lineBreakMode];
    
    _textLabel.frame = CGRectMake(0, 0.0,  self.frame.size.width, size.height);
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, rule.textField.frame.size.width, size.height + 14.0);
}

#pragma mark - Text

/**
 Set text for presenting on tooltip
*/
- (void)setText:(NSString *)text
{
    _text = [text copy];
    
    [self _updateUserInterface];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    [rule.textField becomeFirstResponder];
    [self removeFromSuperview];
}

@end
