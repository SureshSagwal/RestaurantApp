//
//  CALayer+RunTimeAttributes.h
//  Hugo
//
//  Created by Mayank Vyas on 21/05/15.
//  Copyright (c) 2015 hugo. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer (IBConfiguration)

@property (nonatomic, assign) UIColor* borderIBColor;
@property (nonatomic, assign) BOOL isCircularRadius;

@end
