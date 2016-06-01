//
//  FilterTableView.h
//  RestoOrder
//
//  Created by Suresh Kumar on 03/11/15.
//
//

#import <UIKit/UIKit.h>
#import "FilterObject.h"

@protocol FilterTableDelegate <NSObject>

@optional

-(void)didSelectItem:(id)item;

@end

@interface FilterTableView : UITableView<UITableViewDelegate, UITableViewDataSource>
{
    FilterObject *filterObj;
}
@property(nonatomic,weak) id <FilterTableDelegate> filterDelegate;
-(void)reloadTable;
@end
