//
//  FilterTableView.m
//  RestoOrder
//
//  Created by Suresh Kumar on 03/11/15.
//
//

#import "FilterTableView.h"

@implementation FilterTableView
@synthesize filterDelegate;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib
{
    filterObj = [FilterObject sharedManager];
    
    self.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.delegate = self;
    self.dataSource = self;
}

-(void)reloadTable
{
    filterObj = [FilterObject sharedManager];
    [self reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 40.0;
    }
    else if(indexPath.section == 1)
    {
        return 50;
    }
    
    return 40.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.frame = CGRectMake(0, 0, self.frame.size.width, 25);
    headerView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
    UILabel *headerName = [[UILabel alloc] init];
    headerName.backgroundColor = [UIColor clearColor];
    headerName.frame = CGRectMake(12, 0, headerView.frame.size.width-12, 25);
    if (section == 0)
    {
        headerName.text = @"CUISINES";
    }
    else if (section == 1)
    {
        headerName.text = @"DISTANCE (In Miles)";
    }
    
    headerName.textColor = [UIColor darkGrayColor];
    headerName.font = [UIFont systemFontOfSize:13];
    [headerView addSubview:headerName];
    
    return headerView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0)
    {
        return filterObj.cuisinesArray.count;
    }
    else if (section == 1)
    {
        return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section ==0)
    {
        static NSString *cellIdentifier = @"filterTableCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (indexPath.section == 0 && indexPath.row != 0)
        {
            cell.indentationLevel = 2;
            cell.indentationWidth = 15.0;
            cell.separatorInset = UIEdgeInsetsMake(0, 30 + 15, 0, 0);
        }
        UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:2];
        UIButton *checkbtn = (UIButton *)[cell.contentView viewWithTag:1];
        
        if ([filterObj.cuisineIndexes containsObject:[NSString stringWithFormat:@"%ld",indexPath.row]])
        {
            checkbtn.selected = YES;
        }
        else
        {
            checkbtn.selected = NO;
        }
        nameLabel.text = filterObj.cuisinesArray[indexPath.row][@"cuisinesName"];
        
        return cell;
    }
    else if (indexPath.section == 1)
    {
        static NSString *cellIdentifier = @"distanceCell";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        UIButton *minusBtn = (UIButton *)[cell.contentView viewWithTag:1];
        UIButton *plusBtn = (UIButton *)[cell.contentView viewWithTag:2];
        UILabel *countLabel = (UILabel *)[cell.contentView viewWithTag:3];
        
        [minusBtn addTarget:self action:@selector(minusBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [plusBtn addTarget:self action:@selector(plusBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        countLabel.text = filterObj.distanceCountStr;
        
        return cell;
    }
    
    return  nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
        {
            [filterObj.cuisineIndexes removeAllObjects];
            [filterObj.cuisineIndexes addObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]];
        }
        else
        {
            if ([filterObj.cuisineIndexes containsObject:@"0"])
            {
                [filterObj.cuisineIndexes removeObject:@"0"];
            }
            
            NSString *selectedIndex = [NSString stringWithFormat:@"%ld",indexPath.row];
            if (![filterObj.cuisineIndexes containsObject:selectedIndex])
            {
                [filterObj.cuisineIndexes addObject:selectedIndex];
            }
            else
            {
                [filterObj.cuisineIndexes removeObject:selectedIndex];
            }
            
            if (filterObj.cuisineIndexes.count == 0)
            {
                [filterObj.cuisineIndexes addObject:@"0"];
            }
        }
        
        NSLog(@"cuisines array :%@",filterObj.cuisinesArray);
        
        if (filterObj.cuisineIndexes.count > 0)
        {
            [filterObj.selectedIds removeAllObjects];
            if (filterObj.cuisineIndexes.count == 1)
            {
                NSInteger index = [[filterObj.cuisineIndexes lastObject] integerValue];
                [filterObj.selectedIds addObject:filterObj.cuisinesArray[index][@"cuisinesId"]];
            }
            else
            {
                for (int i = 0; i < filterObj.cuisineIndexes.count; i ++)
                {
                    NSInteger index = [filterObj.cuisineIndexes[i] integerValue];
                    [filterObj.selectedIds addObject:filterObj.cuisinesArray[index][@"cuisinesId"]];
                }
            }
            
        }
        
        NSLog(@"cuisine selected indexes array :%@",filterObj.cuisineIndexes);
        NSLog(@"selected ids array :%@",filterObj.selectedIds);
        
        NSString *selectedItem = filterObj.cuisinesArray[indexPath.row][@"cuisinesName"];
        if ([self respondsToSelector:@selector(didSelectItemWithValue:)])
        {
            [self didSelectItemWithValue:selectedItem];
        }
    }
    else if (indexPath.section == 1)
    {
        
    }
    
    
    [self reloadData];
}

-(void)minusBtnAction:(id)sender
{
    NSInteger distanceCount = [filterObj.distanceCountStr integerValue];
    if (distanceCount >= 1)
    {
        distanceCount --;
        filterObj.distanceCountStr = [NSString stringWithFormat:@"%ld",(long)distanceCount];
    }
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)plusBtnAction:(id)sender
{
    NSInteger distanceCount = [filterObj.distanceCountStr integerValue];
    if (distanceCount >= 0)
    {
        distanceCount ++;
        filterObj.distanceCountStr = [NSString stringWithFormat:@"%ld",(long)distanceCount];
    }
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForItem:0 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - Delegates

-(void)didSelectItemWithValue:(id)value
{
    [filterDelegate didSelectItem:value];
}


@end
