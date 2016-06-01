//
//  CALayer+RunTimeAttributes.m
//  Hugo
//
//  Created by Mayank Vyas on 21/05/15.
//  Copyright (c) 2015 hugo. All rights reserved.
//

#import "CALayer+RunTimeAttributes.h"

@implementation CALayer (IBConfiguration)

-(void)setBorderIBColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderIBColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

-(void)setIsCircularRadius:(BOOL)isCircularRadius
{
    if (isCircularRadius)
    {
        self.cornerRadius = CGRectGetWidth(self.frame) / 2.0;
    }
}

-(BOOL)isCircularRadius
{
    return self.isCircularRadius;
}

@end
