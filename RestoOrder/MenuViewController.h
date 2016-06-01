//
//  MenuViewController.h
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import <UIKit/UIKit.h>
#import "Restaurant.h"

@interface MenuViewController : UIViewController
{
    
}
@property(nonatomic, strong)Restaurant *restaurantDict;
@property(nonatomic, strong)NSString *categoryId;
@end
