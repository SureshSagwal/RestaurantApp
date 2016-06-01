//
//  RatingView.h
//  Delivery
//
//  Created by Suresh Kumar on 10/03/15.
//  Copyright (c) 2015 WebSnoox Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RatingViewDelegate;
typedef enum {
    RateViewAlignmentLeft,
    RateViewAlignmentCenter,
    RateViewAlignmentRight
} RateViewAlignment;


@interface RatingView : UIView{
    
    UIImage *_fullStarImage;
    UIImage *_emptyStarImage;
    CGPoint _origin;
    NSInteger _numOfStars;
}

@property(nonatomic, assign) RateViewAlignment alignment;
@property(nonatomic, assign) CGFloat rate;
@property(nonatomic, assign) CGFloat padding;
@property(nonatomic, assign) BOOL editable;
@property(nonatomic, retain) UIImage *fullStarImage;
@property(nonatomic, retain) UIImage *emptyStarImage;
@property(nonatomic, assign) NSObject<RatingViewDelegate> *delegate;

- (RatingView *)initWithFrame:(CGRect)frame;
- (RatingView *)initWithFrame:(CGRect)rect fullStar:(UIImage *)fullStarImage emptyStar:(UIImage *)emptyStarImage;

@end

@protocol RatingViewDelegate

- (void)rateView:(RatingView *)rateView changedToNewRate:(NSNumber *)rate;

@end
