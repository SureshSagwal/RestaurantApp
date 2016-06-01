//
//  OrdersViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 17/07/15.
//
//

#import "OrdersViewController.h"
#import "Constants.h"
#import "WebService.h"
#import <MessageUI/MessageUI.h>

@interface OrdersViewController ()<UITableViewDataSource, UITableViewDelegate, WebServiceDelegate, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
{
    __weak IBOutlet UITableView *orderstableView;
    __weak IBOutlet UITableView *orderDetailTableView;
    __weak IBOutlet UILabel *restaurantNameLbl;
    __weak IBOutlet UIImageView *bgImageView;
    __weak IBOutlet UIView *orderDetailView;
    __weak IBOutlet UILabel *checkoutTypeLbl;
    __weak IBOutlet UILabel *totalAmountLbl;
    
    __weak IBOutlet UIView *messageView;
    __weak IBOutlet UITextView *messageTextView;
    __weak IBOutlet NSLayoutConstraint *messageViewBottomConstraint;
    
    NSMutableArray *ordersArray;
    NSMutableArray *orderDetailArray;
    NSInteger cancelOrderIndex;
    
    UIRefreshControl *refreshControl;
}
- (IBAction)backBtnAction:(id)sender;
- (IBAction)closeBtnAction:(id)sender;

- (IBAction)sendMsgBtnAction:(id)sender;
- (IBAction)cancelMsgBtnAction:(id)sender;

@end

@implementation OrdersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (IS_iOS8)
    {
        orderstableView.rowHeight = UITableViewAutomaticDimension;
        orderstableView.estimatedRowHeight = 67.0;
        
        orderDetailTableView.rowHeight = UITableViewAutomaticDimension;
        orderDetailTableView.estimatedRowHeight = 67.0;
    }
    
    ordersArray = [[NSMutableArray alloc] init];
    orderDetailArray = [[NSMutableArray alloc] init];
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshList:) forControlEvents:UIControlEventValueChanged];
    [orderstableView addSubview:refreshControl];
    
    [UIAppDelegate showLoaderWithinteractionDisabled];
    [self loadOrdersList];
    // Do any additional setup after loading the view.
}

-(void)refreshList:(UIRefreshControl *)refreshCtrl
{
    [refreshControl beginRefreshing];
    [self loadOrdersList];
}

-(void)loadOrdersList
{
    WebService *serviceObj = [[WebService alloc] init];
    serviceObj.delegate = self;
    serviceObj.API_TYPE = ORDER_HISTORY_API;
    serviceObj.API_INDEX = ORDER_HISTORY_API;
    
    [serviceObj startOperationWithPostParam:nil];
}

-(void)showOrderDetailsAction
{
    bgImageView.alpha = 0.0;
    orderDetailView.alpha = 0.0;
    bgImageView.hidden = NO;
    orderDetailView.hidden = NO;
    
    [UIView animateWithDuration:0.45 animations:^{
        
        orderDetailView.alpha = 1.0;
        bgImageView.alpha = 0.5;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideOrderDetailsAction
{
    [UIView animateWithDuration:0.45 animations:^{
        
        orderDetailView.alpha = 0.0;
        bgImageView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        bgImageView.hidden = YES;
        orderDetailView.hidden = YES;
        
    }];
}

-(void)showMessageViewAction
{
    [messageTextView becomeFirstResponder];
    bgImageView.alpha = 0.0;
    messageView.alpha = 0.0;
    bgImageView.hidden = NO;
    messageView.hidden = NO;
    
    messageViewBottomConstraint.constant = 250;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.45 animations:^{
        
        [self.view layoutIfNeeded];
        messageView.alpha = 1.0;
        bgImageView.alpha = 0.5;
        
    } completion:^(BOOL finished) {
        
    }];
}

-(void)hideMessageViewAction
{
    [messageTextView resignFirstResponder];
    
    messageViewBottomConstraint.constant = 0;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.45 animations:^{
        
        [self.view layoutIfNeeded];
        messageView.alpha = 0.0;
        bgImageView.alpha = 0.0;
        
    } completion:^(BOOL finished) {
        
        bgImageView.hidden = YES;
        orderDetailView.hidden = YES;
        
    }];
}


#pragma mark - UIButton Action

- (IBAction)backBtnAction:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)closeBtnAction:(id)sender
{
    [self hideOrderDetailsAction];
}

-(void)sendMsgBtnAction:(id)sender
{
    NSString *msgText = [messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (msgText.length > 0)
    {
        NSDictionary *orderDict = ordersArray[cancelOrderIndex];

        NSString *orderId = orderDict[@"OrderId"];
        msgText = [msgText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:orderId,@"orderId",msgText,@"message", nil];
        
        [messageTextView resignFirstResponder];
        [UIAppDelegate showLoaderWithinteractionDisabled];
        
        WebService *serviceObj = [[WebService alloc] init];
        serviceObj.delegate = self;
        serviceObj.API_TYPE = SEND_MESSAGE_API;
        serviceObj.API_INDEX = SEND_MESSAGE_API;
        
        [serviceObj startOperationWithPostParam:params];
        
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Please enter message !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    
    
}

-(void)cancelMsgBtnAction:(id)sender
{
    [self hideMessageViewAction];
}

-(void)cancelOrderAction:(id)sender
{
    UIButton *btn = sender;
    NSLog(@"%d",(int)btn.alpha);
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:orderstableView];
    NSIndexPath *indexPath = [orderstableView indexPathForRowAtPoint:buttonPosition];
    cancelOrderIndex = indexPath.row;
    NSDictionary *orderDict = ordersArray[indexPath.row];
    
    if ((int)btn.alpha == 0)
    {
        BOOL check = false;
        
        switch ([orderDict[@"checkoutType"] integerValue])
        {
            case 1:     // pickup
            {
                if ([orderDict[@"OrderStatus"] integerValue] == 8)
                {
                    check = true;
                }
            }
                break;
            case 2:        // delivery
            {
                if ([orderDict[@"OrderStatus"] integerValue] == 8)
                {
                    check = true;
                }

            }
                break;
            case 3:     // reserve a table
            {
                if ([orderDict[@"OrderStatus"] integerValue] == 4)
                {
                    check = true;
                }

            }
                break;
                
            case 4:     // In store now
            {
                if ([orderDict[@"OrderStatus"] integerValue] == 7)
                {
                    check = true;
                }
                
            }
                break;
                
            default:
                break;
        }
        
        NSString *messageStr;
        if (check)
        {
            messageStr = @"Order has already been cancelled !";
        }
        else
        {
            messageStr = @"Order can only be cancelled during status \"Order Placed\" !";
        }
        
        [[[UIAlertView alloc] initWithTitle:@"" message:messageStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Do you really want to cancel this order !" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        alert.tag = 111;
        [alert show];
    }
    
}

-(void)callOrderAction:(id)sender
{
    UIButton *btn = sender;
    NSLog(@"%d",(int)btn.alpha);
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero
                                           toView:orderstableView];
    NSIndexPath *indexPath = [orderstableView indexPathForRowAtPoint:buttonPosition];
    cancelOrderIndex = indexPath.row;
    NSDictionary *orderDict = ordersArray[indexPath.row];
    
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:orderDict[@"RestaurantContactNo"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)messageOrderAction:(id)sender
{
    UIButton *btn = sender;
    NSLog(@"%d",(int)btn.alpha);
    
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:orderstableView];
    NSIndexPath *indexPath = [orderstableView indexPathForRowAtPoint:buttonPosition];
    cancelOrderIndex = indexPath.row;
    NSDictionary *orderDict = ordersArray[indexPath.row];
    
    NSString *checkoutTypeStr = orderDict[@"checkoutType"];
    NSString *orderStatus = orderDict[@"OrderStatus"];
    
    BOOL check = false;
    NSString *msgStr = @"";
    
    switch ([checkoutTypeStr integerValue])
    {
        case 1:     //  PickUp
        {
            if ([orderStatus integerValue] == 7)
            {
                check = true;
                msgStr = @"Order is already fulfilled !";
            }
            else if ([orderStatus integerValue] == 8)
            {
                check = true;
                msgStr = @"Order is already cancelled !";
            }
        }
            break;
            
        case 2:     // delivery
        {
            if ([orderStatus integerValue] == 7)
            {
                check = true;
                msgStr = @"Order is already fulfilled !";
            }
            else if ([orderStatus integerValue] == 8)
            {
                check = true;
                msgStr = @"Order is already cancelled !";
            }
            
        }
            break;
            
        case 3:     // reserve a table
        {
            if ([orderStatus integerValue] == 3)
            {
                check = true;
                msgStr = @"Order is already fulfilled !";
            }
            else if ([orderStatus integerValue] == 4)
            {
                check = true;
                msgStr = @"Order is already cancelled !";
            }
            
        }
            break;
            
        case 4:     // in store now
        {
            if ([orderStatus integerValue] == 6)
            {
                check = true;
                msgStr = @"Order is already fulfilled !";
            }
            else if ([orderStatus integerValue] == 7)
            {
                check = true;
                msgStr = @"Order is already cancelled !";
            }
            
        }
            break;
        default:
            break;
    }
    
    if (check == true)
    {
        [[[UIAlertView alloc] initWithTitle:@"" message:msgStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        
        return;
    }
    
//    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
//    messageController.messageComposeDelegate = self;
//    messageController.recipients = [NSArray arrayWithObject:orderDict[@"RestaurantContactNo"]];
//
//    [self presentViewController:messageController animated:YES completion:^{
//        
//    }];
    
    [self showMessageViewAction];
}

#pragma mark - UIAlertView Delegates

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111)
    {
        if (buttonIndex == 1)
        {
            NSDictionary *orderDict = ordersArray[cancelOrderIndex];
            
            [UIAppDelegate showLoaderWithinteractionDisabled];
            
            WebService *serviceObj = [[WebService alloc] init];
            serviceObj.delegate = self;
            serviceObj.API_TYPE = CANCEL_ORDER_API;
            serviceObj.API_INDEX = CANCEL_ORDER_API;
            
            NSMutableDictionary *paramDict = [[NSMutableDictionary alloc] init];
            [paramDict setObject:orderDict[@"OrderId"] forKey:@"orderId"];
            [serviceObj startOperationWithPostParam:paramDict];
        }
    }
}

#pragma mark - Message Delegates

-(void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    NSString *mesageStr;
    switch (result) {
        case MessageComposeResultSent:
        {
            mesageStr = @"Message sent successfully !";
        }
            break;
        case MessageComposeResultCancelled:
        {
            mesageStr = @"Message cancelled !";
        }
            break;
        case MessageComposeResultFailed:
        {
            mesageStr = @"Message sending failed !";
        }
            break;
            
        default:
            break;
    }
    
    [[[UIAlertView alloc] initWithTitle:@"" message:mesageStr delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - WebService Delegates

-(void)serviceFinishedWithResult:(id)result API_Index:(NSInteger)index
{
    if (index == ORDER_HISTORY_API)
    {
        if ([refreshControl isRefreshing])
        {
            [refreshControl endRefreshing];
        }
        
        [ordersArray removeAllObjects];
        [ordersArray addObjectsFromArray:result];
        [orderstableView reloadData];
    }
    else if (index == SEND_MESSAGE_API)
    {
        [self hideMessageViewAction];
        [[[UIAlertView alloc] initWithTitle:@"" message:@"message sent successfully !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
    else if (index == CANCEL_ORDER_API)
    {
        NSDictionary *orderDict = ordersArray[cancelOrderIndex];
        NSString *checkoutType = orderDict[@"checkoutType"];
        NSString *orderStatus;
        switch ([checkoutType integerValue])
        {
            case 1:     // take away
            {
                orderStatus = @"8";
            }
                break;
            case 2:     // delivery
            {
                orderStatus = @"8";
            }
                break;
            case 3:     // reserve a table
            {
                orderStatus = @"4";
            }
                break;
                
            case 4:     // In store now
            {
                orderStatus = @"7";
            }
                break;
                
            default:
                break;
        }
        
        [orderDict setValue:orderStatus forKey:@"OrderStatus"];
        [ordersArray replaceObjectAtIndex:cancelOrderIndex withObject:orderDict];
        
        [orderstableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:cancelOrderIndex inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    
    [UIAppDelegate hideLoaderWithinteractionDisabled];
}

-(void)serviceFinishedWithResponse:(id)response API_Index:(NSInteger)index
{
    if ([refreshControl isRefreshing])
    {
        [refreshControl endRefreshing];
    }
    
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate displayAlertWithMessage:response];
}

-(void)serviceFinishedWithError:(id)error API_Index:(NSInteger)index
{
    if ([refreshControl isRefreshing])
    {
        [refreshControl endRefreshing];
    }
    
    [UIAppDelegate hideLoaderWithinteractionDisabled];
    [UIAppDelegate displayAlertWithMessage:error];
}


#pragma mark - UITableView Datasource/Delegates

- (BOOL)respondsToSelector:(SEL)selector
{
    if (selector == @selector(tableView:heightForRowAtIndexPath:))
    {
        if (IS_iOS8)
            return 0;
        else
            return 1;
    }
    
    return [super respondsToSelector:selector];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat rowHeight = 0.0;
    rowHeight = [self heightForBasicCellAtIndexPath:indexPath table:tableView];
    return rowHeight;
}


-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath table:(UITableView *)tableView
{
    static UITableViewCell *sizingCell_job = nil;
    static dispatch_once_t onceToken_job;
    static NSString *jobCellIdentifier = @"OrderCell";
    
    dispatch_once(&onceToken_job, ^{
        
        sizingCell_job = [orderstableView dequeueReusableCellWithIdentifier:jobCellIdentifier];
    });
    
    [self configureBasicCell:sizingCell_job atIndexPath:indexPath table:tableView];
    return [self calculateHeightForConfiguredSizingCell:sizingCell_job table:tableView];
}

- (void)configureBasicCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath table:(UITableView *)tableView
{
    if (tableView == orderstableView)
    {
        [self setCellDetails:cell AtIndexPath:indexPath];
    }
    else
    {
        [self setOrderDetailCell:cell AtIndexPath:indexPath];
    }
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell table:(UITableView *)tableView
{
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == orderstableView)
    {
        return ordersArray.count;
    }
    else
    {
        return orderDetailArray.count;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == orderstableView)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"OrderCell"];
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"OrderDetailCell"];
    }
    
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    if (tableView == orderstableView)
    {
        [self setCellDetails:cell AtIndexPath:indexPath];
    }
    else
    {
        [self setOrderDetailCell:cell AtIndexPath:indexPath];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == orderstableView)
    {
        restaurantNameLbl.text = ordersArray[indexPath.row][@"RestaurantName"];
        double totalPrice = [ordersArray[indexPath.row][@"TotalPrice"] doubleValue];
        totalAmountLbl.text = [NSString stringWithFormat:@"$ %0.2f",totalPrice];
        
        NSInteger checkout = [ordersArray[indexPath.row][@"checkoutType"] integerValue];
        
        if (checkout == 1)
        {
            checkoutTypeLbl.text = @"Take away";
        }
        else if (checkout == 2)
        {
            checkoutTypeLbl.text = @"Delivery";
        }
        else if (checkout == 3)
        {
            checkoutTypeLbl.text = @"Reserve a table";
        }
        else if (checkout == 4)
        {
            checkoutTypeLbl.text = @"In store now";
        }
        
        [orderDetailArray removeAllObjects];
        [orderDetailArray addObjectsFromArray:ordersArray[indexPath.row][@"Items"]];
        [orderDetailTableView reloadData];
        
        [self showOrderDetailsAction];
    }
    
}

-(void)setOrderDetailCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *itemNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *priceLabelLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *qtyLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UILabel *addonLabel = (UILabel *)[cell.contentView viewWithTag:4];
    
    NSDictionary *detailDict = orderDetailArray[indexPath.row];
    itemNameLabel.text = detailDict[@"ItemName"];
    priceLabelLabel.text = [NSString stringWithFormat:@"$ %@",detailDict[@"itemPrice"]];
    qtyLabel.text = [NSString stringWithFormat:@"Qty : %@",detailDict[@"itemQuantity"]];
    
    NSArray *addonArray = detailDict[@"addonItems"];
    if (addonArray.count > 0)
    {
        NSMutableArray *addonJoinedArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < addonArray.count; i ++)
        {
            NSString *addonStr = addonArray[i][@"addonItem"];
            addonStr = [NSString stringWithFormat:@"%@ : $ %@",addonStr,addonArray[i][@"addonPrice"]];
            [addonJoinedArray addObject:addonStr];
        }
        
        addonLabel.text = [addonJoinedArray componentsJoinedByString:@", "];
    }
    
}

-(void)setCellDetails:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath
{
    UILabel *orderNoLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *orderStatusLabel = (UILabel *)[cell.contentView viewWithTag:2];
    UILabel *dateLabel = (UILabel *)[cell.contentView viewWithTag:3];
    UIImageView *statusImageView = (UIImageView *)[cell.contentView viewWithTag:4];
    UILabel *messageLabel = (UILabel *)[cell.contentView viewWithTag:5];
    UIButton *cancelBtn = (UIButton *)[cell.contentView viewWithTag:6];
    UIButton *callBtn = (UIButton *)[cell.contentView viewWithTag:7];
    UIButton *messageBtn = (UIButton *)[cell.contentView viewWithTag:8];
    [cancelBtn addTarget:self action:@selector(cancelOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    [callBtn addTarget:self action:@selector(callOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    [messageBtn addTarget:self action:@selector(messageOrderAction:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *checkoutTypeStr = ordersArray[indexPath.row][@"checkoutType"];
    
    NSString *messageStr = ordersArray[indexPath.row][@"message"];
    if (messageStr.length > 0)
    {
        messageStr = [NSString stringWithFormat:@"Message : %@",messageStr];
        messageLabel.text = messageStr;
    }
    else
    {
        messageLabel.text = @"";
    }
    
    orderNoLabel.text = ordersArray[indexPath.row][@"OrderId"];
    dateLabel.text = ordersArray[indexPath.row][@"orderDate"];
    NSString *orderStatus = ordersArray[indexPath.row][@"OrderStatus"];
    
    if ([orderStatus integerValue] == 1)
    {
        cancelBtn.alpha = 1.0;
    }
    else
    {
        cancelBtn.alpha = 0.4;
    }
    
    switch ([checkoutTypeStr integerValue])
    {
        case 1:     //  PickUp
        {
            switch ([orderStatus integerValue])
            {
                case 1:
                {
                    orderStatusLabel.text = @"Order Placed";
                    statusImageView.image = [UIImage imageNamed:@"order_placed_icon"];
                }
                    break;
                    
                case 2:
                {
                    orderStatusLabel.text = @"Preparing";
                    statusImageView.image = [UIImage imageNamed:@"Preparing_icon"];
                }
                    break;
                    
                case 3:
                {
                    orderStatusLabel.text = @"Cooking";
                    statusImageView.image = [UIImage imageNamed:@"order_cooking_icon"];
                }
                    break;
                    
                case 4:
                {
                    orderStatusLabel.text = @"Cooking Complete";
                    statusImageView.image = [UIImage imageNamed:@"order_cooked_icon"];
                }
                    break;
                    
                case 5:
                {
                    orderStatusLabel.text = @"Packed";
                    statusImageView.image = [UIImage imageNamed:@"order_packed_icon"];
                }
                    break;
                    
                case 6:
                {
                    orderStatusLabel.text = @"Ready for Pick up";
                    statusImageView.image = [UIImage imageNamed:@"order_packed_icon"];
                }
                    break;
                    
                case 7:
                {
                    orderStatusLabel.text = @"Pick up Completed";
                    statusImageView.image = [UIImage imageNamed:@"order_delivered_icon"];
                }
                    break;
                    
                case 8:
                {
                    orderStatusLabel.text = @"Order Cancelled";
                    statusImageView.image = [UIImage imageNamed:@"order_cancel_icon"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        case 2:     // delivery
        {
            switch ([orderStatus integerValue])
            {
                case 1:
                {
                    orderStatusLabel.text = @"Order Placed";
                    statusImageView.image = [UIImage imageNamed:@"order_placed_icon"];
                }
                    break;
                    
                case 2:
                {
                    orderStatusLabel.text = @"Preparing";
                    statusImageView.image = [UIImage imageNamed:@"Preparing_icon"];
                }
                    break;
                    
                case 3:
                {
                    orderStatusLabel.text = @"Cooking";
                    statusImageView.image = [UIImage imageNamed:@"order_cooking_icon"];
                }
                    break;
                    
                case 4:
                {
                    orderStatusLabel.text = @"Cooking Complete";
                    statusImageView.image = [UIImage imageNamed:@"order_cooked_icon"];
                }
                    break;
                    
                case 5:
                {
                    orderStatusLabel.text = @"Packed";
                    statusImageView.image = [UIImage imageNamed:@"order_packed_icon"];
                }
                    break;
                    
                case 6:
                {
                    orderStatusLabel.text = @"Out for Delivery";
                    statusImageView.image = [UIImage imageNamed:@"order_out_icon"];
                }
                    break;
                    
                case 7:
                {
                    orderStatusLabel.text = @"Delivery Completed";
                    statusImageView.image = [UIImage imageNamed:@"order_delivered_icon"];
                }
                    break;
                    
                case 8:
                {
                    orderStatusLabel.text = @"Order Cancelled";
                    statusImageView.image = [UIImage imageNamed:@"order_cancel_icon"];
                }
                    break;
                    
                default:
                    break;
            }

        }
            break;
            
        case 3:     // reserve a table
        {
            switch ([orderStatus integerValue])
            {
                case 1:
                {
                    orderStatusLabel.text = @"Order Placed";
                    statusImageView.image = [UIImage imageNamed:@"order_placed_icon"];
                }
                    break;
                    
                case 2:
                {
                    orderStatusLabel.text = @"Table Reserved";
                    statusImageView.image = [UIImage imageNamed:@"table_reservation_icon"];
                }
                    break;
                    
                case 3:
                {
                    orderStatusLabel.text = @"Order Completed";
                    statusImageView.image = [UIImage imageNamed:@"order_delivered_icon"];
                }
                    break;
                    
                case 4:
                {
                    orderStatusLabel.text = @"Order Cancelled";
                    statusImageView.image = [UIImage imageNamed:@"order_cancel_icon"];
                }
                    break;
                    
                default:
                    break;
            }

        }
            break;
            
        case 4:     // in store now
        {
            switch ([orderStatus integerValue])
            {
                case 1:
                {
                    orderStatusLabel.text = @"Order Placed";
                    statusImageView.image = [UIImage imageNamed:@"order_placed_icon"];
                }
                    break;
                    
                case 2:
                {
                    orderStatusLabel.text = @"Preparing";
                    statusImageView.image = [UIImage imageNamed:@"Preparing_icon"];
                }
                    break;
                    
                case 3:
                {
                    orderStatusLabel.text = @"Cooking";
                    statusImageView.image = [UIImage imageNamed:@"order_cooking_icon"];
                }
                    break;
                    
                case 4:
                {
                    orderStatusLabel.text = @"Cooking Complete";
                    statusImageView.image = [UIImage imageNamed:@"order_cooked_icon"];
                }
                    break;
                    
                case 5:
                {
                    orderStatusLabel.text = @"Waiter on the way";
                    statusImageView.image = [UIImage imageNamed:@"order_out_icon"];
                }
                    break;
                    
                case 6:
                {
                    orderStatusLabel.text = @"Order Fulfilled";
                    statusImageView.image = [UIImage imageNamed:@"order_delivered_icon"];
                }
                    break;
                    
                case 7:
                {
                    orderStatusLabel.text = @"Order Cancelled";
                    statusImageView.image = [UIImage imageNamed:@"order_cancel_icon"];
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
            
        default:
            break;
    }
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
