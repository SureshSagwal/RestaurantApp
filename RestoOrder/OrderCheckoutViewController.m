//
//  OrderCheckoutViewController.m
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "OrderCheckoutViewController.h"
#import "PlaceOrderViewController.h"
#import "Constants.h"
#import "Database.h"
#import "UserDetails.h"

@interface OrderCheckoutViewController ()<UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIAlertViewDelegate>
{
    NSMutableArray *orderItemsArray;
    NSDictionary *restaurantDict;
    NSMutableDictionary *orderDict;
    
    NSMutableArray *checkoutTypeArray;
    NSMutableArray *checkoutTypeValuesArray;
    NSMutableArray *intervalArray;
    
    NSInteger canPlaceOrder;
    BOOL isKeyboardShown;
    
    __weak IBOutlet UIButton *checkoutBtn;
    __weak IBOutlet UILabel *restaurantNameLabel;
    __weak IBOutlet UITableView *orderListTableView;
    __weak IBOutlet UILabel *takeAwayTimeLabel;
    __weak IBOutlet UILabel *reserveTableTimeLabel;
    __weak IBOutlet UILabel *deliveryTimeLabel;
    
    
    __weak IBOutlet UILabel *totalPriceLabel;
    __weak IBOutlet UILabel *subTotalPriceLabel;
    __weak IBOutlet UILabel *serviceTaxPriceLabel;
    
    __weak IBOutlet UILabel *serviceTaxPlaceholderLabel;
    __weak IBOutlet UILabel *vatPriceLabel;
    
    __weak IBOutlet UILabel *vatPlaceholderLabel;
    __weak IBOutlet NSLayoutConstraint *orderTableHeightConstraint;
    __weak IBOutlet UIButton *takeAwayBtn;
    __weak IBOutlet UIButton *reserveATableBtn;
    __weak IBOutlet UIButton *deliveryBtn;
    __weak IBOutlet UIButton *inStoreNowBtn;
    
    __weak IBOutlet UILabel *commentsLabel;
    __weak IBOutlet UITextView *commentsTextView;
    __weak IBOutlet UILabel *commentsCountLabel;
    
    __weak IBOutlet UIImageView *bgImageView;
    __weak IBOutlet NSLayoutConstraint *commentsViewBottomConstraint;
    __weak IBOutlet UIView *commentsView;
    
    // time picker
    
    __weak IBOutlet UIPickerView *timePicker;
    __weak IBOutlet UIView *timePickerView;
    
    __weak IBOutlet NSLayoutConstraint *timePickerViewBottomConstraint;
    
    // EMPTY BASKET VIEW
    
    __weak IBOutlet UIView *basketEmptyView;
    
}
- (IBAction)addItemsIntoEmptyBasketAction:(id)sender;

- (IBAction)hideBgImageViewAction:(id)sender;

- (IBAction)writeCommentsBtnAction:(id)sender;
- (IBAction)makeOrderFavoriteAction:(id)sender;
- (IBAction)editOrderBtnAction:(id)sender;
- (IBAction)addMoreBtnAction:(id)sender;
- (IBAction)takeAwayBtnAction:(id)sender;
- (IBAction)reserveATableBtnAction:(id)sender;
- (IBAction)deliveryBtnAction:(id)sender;
- (IBAction)inStoreNowBtnAction:(id)sender;

- (IBAction)editBtnAction:(id)sender;
- (IBAction)timePickerDoneBtnAction:(id)sender;

- (IBAction)proceedToCheckoutBtnAction:(id)sender;

@end

@implementation OrderCheckoutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    timePickerViewBottomConstraint.constant = - timePickerView.frame.size.height;
    
    canPlaceOrder = 1;
    totalPriceLabel.text = @"";
    subTotalPriceLabel.text = @"";
    vatPriceLabel.text = @"";
    serviceTaxPriceLabel.text = @"";
    restaurantNameLabel.text = @"";
    takeAwayTimeLabel.text = @"";
    reserveTableTimeLabel.text = @"";
    commentsTextView.text = @"";
    serviceTaxPlaceholderLabel.text = @"Service tax";
    vatPlaceholderLabel.text = @"Vat";
    isKeyboardShown = NO;
    
    commentsView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    commentsView.layer.borderWidth = 0.5;
    commentsView.layer.cornerRadius = 5.0;
    commentsView.alpha = 0.0;
    bgImageView.alpha = 0.0;
    orderDict = [[NSMutableDictionary alloc] init];
    orderItemsArray = [[NSMutableArray alloc] init];
    checkoutTypeValuesArray = [[NSMutableArray alloc] init];
    checkoutTypeArray = [[NSMutableArray alloc] init];
    intervalArray = [[NSMutableArray alloc] init];
    
    orderTableHeightConstraint.constant = 92;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderItems:) name:@"updateOrder" object:nil];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    
    // Do any additional setup after loading the view.
}


-(void)viewWillAppear:(BOOL)animated
{
    NSDictionary *savedRestDict = [[Database sharedObject] readRestaurant];
    if (savedRestDict.allKeys.count > 0)
    {
        NSString *jsonDictStr = savedRestDict[@"detailDict"];
        
        NSData *data = [jsonDictStr dataUsingEncoding:NSUTF8StringEncoding];
        restaurantDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        NSLog(@"restaurant Dict:%@",restaurantDict);
        
        restaurantNameLabel.text = restaurantDict[@"name"];
        
//        [self updateTimeLabel:takeAwayTimeLabel WithTime:restaurantDict[@"defaultTakeAwayTime"]];
//        [self updateTimeLabel:reserveTableTimeLabel WithTime:restaurantDict[@"defaultReserveaTableTime"]];
//        [self updateTimeLabel:deliveryTimeLabel WithTime:restaurantDict[@"defaultDeliveryTime"]];
        
        takeAwayTimeLabel.text = @"ASAP";
        reserveTableTimeLabel.text = @"ASAP";
        deliveryTimeLabel.text = @"ASAP";
        
        serviceTaxPlaceholderLabel.text = [NSString stringWithFormat:@"Service tax (%@ %%)",restaurantDict[@"serviceTax"]];
        vatPlaceholderLabel.text = [NSString stringWithFormat:@"Vat (%@ %%)",restaurantDict[@"vat"]];
        
        NSArray *itemsArray = [[Database sharedObject] readAllProducts];
        NSLog(@"itemsArray :%@",itemsArray);
        if (itemsArray.count > 0)
        {
            basketEmptyView.hidden = YES;
        }
        else
        {
            basketEmptyView.hidden = NO;
        }
        
        [orderItemsArray removeAllObjects];
        [orderItemsArray addObjectsFromArray:itemsArray];
        orderTableHeightConstraint.constant = 92 + 44*orderItemsArray.count;
        [self updateOrderPriceDetails];
        [orderListTableView reloadData];
    }
    else
    {
        basketEmptyView.hidden = NO;
        
        canPlaceOrder = 0;
        restaurantNameLabel.text = @"";
        takeAwayTimeLabel.text = @"";
        reserveTableTimeLabel.text = @"";
        deliveryTimeLabel.text = @"";
        serviceTaxPlaceholderLabel.text = @"Service tax";
        vatPlaceholderLabel.text = @"Vat";
        totalPriceLabel.text = @"";
        subTotalPriceLabel.text = @"";
        vatPriceLabel.text = @"";
        serviceTaxPriceLabel.text = @"";
        commentsLabel.text = @"Write Comments...";
        commentsTextView.text = @"";
        takeAwayBtn.selected = NO;
        reserveATableBtn.selected = NO;
        deliveryBtn.selected = NO;
        
        [orderListTableView reloadData];
    }
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

#pragma mark - local Actions

-(void)updateTimeLabel:(UILabel *)label WithTime:(NSString *)secondsStr
{
    int seconds = [secondsStr doubleValue];
    NSString *timeStr;
    int hours = seconds/3600;
    int minutes = (seconds%3600)/60;
    
    if (hours > 0)
    {
        timeStr = [NSString stringWithFormat:@"%dh ",hours];
    }
    if (minutes > 0)
    {
        if (hours > 0)
        {
            timeStr = [NSString stringWithFormat:@"%@%dm",timeStr, minutes];
        }
        else
        {
            timeStr = [NSString stringWithFormat:@"%dm", minutes];
        }
        
    }
    label.text = timeStr;
}

-(void)updateOrderPriceDetails
{
    if (orderItemsArray.count > 0)
    {
        canPlaceOrder = 1;
        double subTotal = 0.0;
        
        for (NSDictionary *dict in orderItemsArray)
        {
            subTotal = subTotal + [dict[@"totalPrice"] doubleValue];
        }
        
        double vat = [restaurantDict[@"vat"] doubleValue];
        vat = (vat/100) * subTotal;
        
        double tax = [restaurantDict[@"serviceTax"] doubleValue];
        tax = (tax/100) * subTotal;
        
        double total = subTotal + vat + tax;
        
        totalPriceLabel.text = [NSString stringWithFormat:@"$ %0.2f",total];
        subTotalPriceLabel.text = [NSString stringWithFormat:@"$ %0.2f",subTotal];
        vatPriceLabel.text = [NSString stringWithFormat:@"$ %0.2f",vat];
        serviceTaxPriceLabel.text = [NSString stringWithFormat:@"$ %0.2f",tax];
        
        // update order dict
        
        [orderDict setObject:restaurantDict[@"Id"] forKey:@"RestaurantId"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",total] forKey:@"TotalPrice"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",subTotal] forKey:@"SubTotal"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",vat] forKey:@"VatPrice"];
        [orderDict setObject:[NSString stringWithFormat:@"%0.2f",tax] forKey:@"TaxPrice"];
    }
    else
    {
        canPlaceOrder = 0;
        totalPriceLabel.text = @"";
        subTotalPriceLabel.text = @"";
        vatPriceLabel.text = @"";
        serviceTaxPriceLabel.text = @"";
    }
    
}

-(void)updatePickerArrayWithCheckoutType:(int)index
{
    NSString *defaultTimeDelay;
    
    switch (index)
    {
        case 10:
        {
            defaultTimeDelay = restaurantDict[@"defaultTakeAwayTime"];
        }
            break;
            
        case 11:
        {
            defaultTimeDelay = restaurantDict[@"defaultReserveaTableTime"];
        }
            break;
            
        case 12:
        {
            defaultTimeDelay = restaurantDict[@"defaultDeliveryTime"];
        }
            break;
            
        default:
            break;
    }
    
    NSTimeInterval timeInterval = [defaultTimeDelay doubleValue];
    
    NSDate *currentDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:[NSDate date]];
    // offset second
    NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: seconds]];
    dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
    NSString *dateStr = [dateFormatter stringFromDate:currentDate];
    NSDate *startDate = [dateFormatter dateFromString:dateStr];
    
    dateFormatter.dateFormat = @"dd/MM/yyyy";
    
    NSDate *closingDate = [NSDate date];
    NSString *closingDateStr = [dateFormatter stringFromDate:closingDate];
    NSString *closingHoursStr = restaurantDict[@"closingHours"];
    NSMutableArray *components = [[NSMutableArray alloc] initWithArray:[closingHoursStr componentsSeparatedByString:@":"]];
    [components removeLastObject];
    closingHoursStr = [components componentsJoinedByString:@":"];
    
    closingDateStr = [NSString stringWithFormat:@"%@ %@",closingDateStr,closingHoursStr];
    dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
    
    NSDate *endDate = [dateFormatter dateFromString:closingDateStr];
    
    NSTimeInterval currentTimeSeconds = [startDate timeIntervalSince1970];
    NSTimeInterval closingTimeSeconds = [endDate timeIntervalSince1970];
    
    [intervalArray removeAllObjects];
    [intervalArray addObject:@"ASAP"];
    [checkoutTypeValuesArray addObject:@"ASAP"];
    NSTimeInterval difference = timeInterval;
        
//    if (startDate < endDate)
//    {
//        NSDate *nextDate = [startDate dateByAddingTimeInterval:0];
//        NSLog(@"nextDate : %@",nextDate);
//        do
//        {
//            [intervalArray addObject:nextDate];
//           [checkoutTypeValuesArray addObject:[self convertDateIntoString:nextDate]];
//            nextDate = [nextDate dateByAddingTimeInterval:difference];
//            NSLog(@"nextDate : %@ \n endDate :%@",nextDate,endDate);
//        }
//        while (nextDate < endDate);
//    }
    
    if (currentTimeSeconds < closingTimeSeconds)
    {
        NSDate *nextDate = [startDate dateByAddingTimeInterval:0];
        NSTimeInterval updatedTimeSeconds = [nextDate timeIntervalSince1970];
        
        do
        {
            [intervalArray addObject:nextDate];
            [checkoutTypeValuesArray addObject:[self convertDateIntoString:nextDate]];
            nextDate = [nextDate dateByAddingTimeInterval:difference];
            updatedTimeSeconds = [nextDate timeIntervalSince1970];
        }
        while (updatedTimeSeconds < closingTimeSeconds);
    }
    
    [timePicker reloadAllComponents];
}

-(NSString *)convertDateIntoString:(NSDate *)date
{
    // offset second
    NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: seconds]];
    dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
    NSString *dateStr = [dateFormatter stringFromDate:date];
    
    return [[dateStr componentsSeparatedByString:@" "] lastObject];
}

#pragma mark - NSNotification Handlers

-(void)updateOrderItems:(NSNotification *)notif
{
    NSArray *itemsArray = [[Database sharedObject] readAllProducts];
    NSLog(@"itemsArray :%@",itemsArray);
    
    [orderItemsArray removeAllObjects];
    [orderItemsArray addObjectsFromArray:itemsArray];
    orderTableHeightConstraint.constant = 92 + 44*orderItemsArray.count;
    [self updateOrderPriceDetails];
    [orderListTableView reloadData];

}

#pragma mark - UIButtons Actions

- (IBAction)addItemsIntoEmptyBasketAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
}

- (IBAction)hideBgImageViewAction:(id)sender {
    
    [commentsTextView resignFirstResponder];
    [self keyboardWillHide:nil];
}

- (IBAction)writeCommentsBtnAction:(id)sender {
    
    if ([commentsLabel.text isEqualToString:@"Write Comments..."])
    {
        commentsTextView.text = @"";
        commentsCountLabel.text = @"250";
    }
    else
    {
        commentsTextView.text = commentsLabel.text;
        commentsCountLabel.text = [NSString stringWithFormat:@"%lu",250 - commentsLabel.text.length];
    }
    
    if ([commentsCountLabel.text integerValue] <= 20)
    {
        commentsCountLabel.textColor = [UIColor redColor];
    }
    else
    {
        commentsCountLabel.textColor = [UIColor blackColor];
    }
    
    [commentsTextView becomeFirstResponder];
}

- (IBAction)makeOrderFavoriteAction:(id)sender {
    
    UIButton *btn = sender;
    if (!btn.selected)
    {
        btn.selected = YES;
        [[[UIAlertView alloc] initWithTitle:@"" message:@"Your order has been marked as your favorite order !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (IBAction)editOrderBtnAction:(id)sender
{
    UIButton *btn = sender;
    if ([btn.titleLabel.text isEqualToString:@"EDIT ORDER"])
    {
        orderListTableView.editing = YES;
        [btn setTitle:@"SAVE ORDER" forState:UIControlStateNormal];
    }
    else
    {
        [btn setTitle:@"EDIT ORDER" forState:UIControlStateNormal];
        orderListTableView.editing = NO;
    }
}

- (IBAction)addMoreBtnAction:(id)sender {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectHomeTab" object:nil];
    
    [self performSelector:@selector(reloadRestaurantForAddMoreItemsAction) withObject:nil afterDelay:0.2];
}

-(void)reloadRestaurantForAddMoreItemsAction
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddMore" object:restaurantDict];
}

- (IBAction)takeAwayBtnAction:(id)sender {
    
    takeAwayBtn.selected = YES;
    reserveATableBtn.selected = NO;
    deliveryBtn.selected = NO;
    inStoreNowBtn.selected = NO;
    
    [orderDict setObject:@"1" forKey:@"CheckoutType"];
    
    if (timePickerViewBottomConstraint.constant == 0)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 10;
        
        [self editBtnAction:btn];
    }
}

- (IBAction)reserveATableBtnAction:(id)sender {
    
    takeAwayBtn.selected = NO;
    deliveryBtn.selected = NO;
    inStoreNowBtn.selected = NO;
    reserveATableBtn.selected = YES;
    
    [orderDict setObject:@"3" forKey:@"CheckoutType"];
    
    if (timePickerViewBottomConstraint.constant == 0)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 11;
        
        [self editBtnAction:btn];
    }
}

- (IBAction)deliveryBtnAction:(id)sender {
    
    takeAwayBtn.selected = NO;
    reserveATableBtn.selected = NO;
    inStoreNowBtn.selected = NO;
    deliveryBtn.selected = YES;
    
    [orderDict setObject:@"2" forKey:@"CheckoutType"];
    
    if (timePickerViewBottomConstraint.constant == 0)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = 12;
        
        [self editBtnAction:btn];
    }
}

-(void)inStoreNowBtnAction:(id)sender
{
    takeAwayBtn.selected = NO;
    reserveATableBtn.selected = NO;
    inStoreNowBtn.selected = YES;
    deliveryBtn.selected = NO;
    
    [orderDict setObject:@"4" forKey:@"CheckoutType"];
    
    if (timePickerViewBottomConstraint.constant == 0)
    {
        timePickerViewBottomConstraint.constant = - timePickerView.frame.size.height;
        [self.view updateConstraintsIfNeeded];
        
        [UIView animateWithDuration:0.35 animations:^{
            [self.view layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
        }];
    }
    
}

- (IBAction)editBtnAction:(id)sender
{
    NSInteger checkoutType = [orderDict[@"CheckoutType"] integerValue];
    
    switch ([sender tag])
    {
        case 10:
        {
            if (checkoutType == 1)
            {
                [checkoutTypeArray removeAllObjects];
                [checkoutTypeArray addObject:@"PickUp"];
                [checkoutTypeValuesArray removeAllObjects];
                [self updatePickerArrayWithCheckoutType:10];
                
                if (timePickerViewBottomConstraint.constant == - timePickerView.frame.size.height)
                {
                    timePickerViewBottomConstraint.constant = 0.0;
                    [self.view updateConstraintsIfNeeded];
                    
                    [UIView animateWithDuration:0.35 animations:^{
                        [self.view layoutIfNeeded];
                        
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"You are not allowed to update time for un-selected checkout option !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
        }
            break;
            
        case 11:
        {
            if (checkoutType == 3)
            {
                [checkoutTypeArray removeAllObjects];
                [checkoutTypeArray addObject:@"ReserveTable"];
                [checkoutTypeValuesArray removeAllObjects];
                [self updatePickerArrayWithCheckoutType:11];
                
                if (timePickerViewBottomConstraint.constant == - timePickerView.frame.size.height)
                {
                    timePickerViewBottomConstraint.constant = 0.0;
                    [self.view updateConstraintsIfNeeded];
                    
                    [UIView animateWithDuration:0.35 animations:^{
                        [self.view layoutIfNeeded];
                        
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"You are not allowed to update time for un-selected checkout option !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
        }
            break;
            
        case 12:
        {
            if (checkoutType == 2)
            {
                [checkoutTypeArray removeAllObjects];
                [checkoutTypeArray addObject:@"Delivery"];
                [checkoutTypeValuesArray removeAllObjects];
                [self updatePickerArrayWithCheckoutType:12];
                
                if (timePickerViewBottomConstraint.constant == - timePickerView.frame.size.height)
                {
                    timePickerViewBottomConstraint.constant = 0.0;
                    [self.view updateConstraintsIfNeeded];
                    
                    [UIView animateWithDuration:0.35 animations:^{
                        [self.view layoutIfNeeded];
                        
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                }
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"" message:@"You are not allowed to update time for un-selected checkout option !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            
        }
            break;
            
        default:
            break;
    }
    
    
//    [timePicker reloadAllComponents];
}

- (IBAction)timePickerDoneBtnAction:(id)sender {
    
    if (checkoutTypeValuesArray.count > 0)
    {
        NSString *selectedObject = checkoutTypeValuesArray[[timePicker selectedRowInComponent:1]];
        
        NSString *checkoutTypeStr = [checkoutTypeArray firstObject];
        if ([checkoutTypeStr isEqualToString:@"PickUp"])
        {
            takeAwayTimeLabel.text = selectedObject;
        }
        else if ([checkoutTypeStr isEqualToString:@"ReserveTable"])
        {
            reserveTableTimeLabel.text = selectedObject;
        }
        else if ([checkoutTypeStr isEqualToString:@"Delivery"])
        {
            deliveryTimeLabel.text = selectedObject;
        }
        
//        if ([selectedObject isEqualToString:@"ASAP"])
//        {
//            NSString *checkoutTypeStr = [checkoutTypeArray firstObject];
//            if ([checkoutTypeStr isEqualToString:@"PickUp"])
//            {
//                takeAwayTimeLabel.text = selectedObject;
//            }
//            else if ([checkoutTypeStr isEqualToString:@"ReserveTable"])
//            {
//                reserveTableTimeLabel.text = selectedObject;
//            }
//            else if ([checkoutTypeStr isEqualToString:@"Delivery"])
//            {
//                deliveryTimeLabel.text = selectedObject;
//            }
//        }
//        else
//        {
//            NSInteger seconds = [[NSTimeZone localTimeZone] secondsFromGMT];
//            
//            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//            [dateFormatter setTimeZone :[NSTimeZone timeZoneForSecondsFromGMT: seconds]];
//            dateFormatter.dateFormat = @"dd/MM/yyyy HH:mm";
//            NSString *dateStr = [dateFormatter stringFromDate:[NSDate date]];
//            NSDate *startDate = [dateFormatter dateFromString:dateStr];
//            //    startDate = [startDate dateByAddingTimeInterval:seconds];
//            
//            NSDate *selectedDate = intervalArray[[timePicker selectedRowInComponent:1]];
//            
//            NSTimeInterval interval = [selectedDate timeIntervalSinceDate:startDate];
//            NSString *intervalStr = [NSString stringWithFormat:@"%f",interval];
//            
//            NSString *checkoutTypeStr = [checkoutTypeArray firstObject];
//            if ([checkoutTypeStr isEqualToString:@"PickUp"])
//            {
//                [self updateTimeLabel:takeAwayTimeLabel WithTime:intervalStr];
//            }
//            else if ([checkoutTypeStr isEqualToString:@"ReserveTable"])
//            {
//                [self updateTimeLabel:reserveTableTimeLabel WithTime:intervalStr];
//            }
//            else if ([checkoutTypeStr isEqualToString:@"Delivery"])
//            {
//                [self updateTimeLabel:deliveryTimeLabel WithTime:intervalStr];
//            }
//        }
       
    }
    
    timePickerViewBottomConstraint.constant = - timePickerView.frame.size.height;
    [self.view updateConstraintsIfNeeded];
    
    [UIView animateWithDuration:0.35 animations:^{
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
}

- (IBAction)proceedToCheckoutBtnAction:(id)sender {
    
    UserDetails *userDetailObj = [UserDetails sharedManager];
    if (userDetailObj.userId != nil)
    {
        if (canPlaceOrder == 1)
        {
            double totalAmount = [orderDict[@"TotalPrice"] doubleValue];
            double maxAmount = [restaurantDict[@"maxAmount"] doubleValue];
            if (maxAmount < totalAmount)
            {
                [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"You are not allowed to place order of more than amount $ %.2f !",maxAmount] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
            }
            else
            {
                NSLog(@"checkout :%@",[orderDict objectForKey:@"CheckoutType"]);
                if ([orderDict objectForKey:@"CheckoutType"] != nil)
                {
                    if ([commentsLabel.text isEqualToString:@"Write Comments..."])
                    {
                        [orderDict setObject:@"" forKey:@"orderComments"];
                    }
                    else
                    {
                        [orderDict setObject:commentsLabel.text forKey:@"orderComments"];
                    }
                    
                    if (takeAwayTimeLabel.text != nil)
                    {
                        [orderDict setObject:takeAwayTimeLabel.text forKey:@"TakeAwayTime"];
                    }
                    else
                    {
                        [orderDict setObject:@"" forKey:@"TakeAwayTime"];
                    }
                    
                    if (reserveTableTimeLabel.text != nil)
                    {
                        [orderDict setObject:reserveTableTimeLabel.text forKey:@"ReserveaTableTime"];
                    }
                    else
                    {
                        [orderDict setObject:@"" forKey:@"ReserveaTableTime"];
                    }
                    
                    if (deliveryTimeLabel.text != nil)
                    {
                        [orderDict setObject:deliveryTimeLabel.text forKey:@"DeliveryTime"];
                    }
                    else
                    {
                        [orderDict setObject:@"" forKey:@"DeliveryTime"];
                    }
                    
                    [orderDict setObject:@"ASAP" forKey:@"InStoreNow"];
                    
                    [self performSegueWithIdentifier:@"CheckoutOrderSeque" sender:nil];
                }
                else
                {
                    [[[UIAlertView alloc] initWithTitle:@"" message:@"Please select checkout value(i.e Take Away, Reserve a Table or Delivery)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
                }
            }
            
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Basket Empty !" message:@"Please add some items into basket before placing order !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Login" message:@"Please login to place your order !" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login", nil];
        alert.tag = 111;
        [alert show];
    }
}

#pragma mark - UITableView Delegates

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return orderItemsArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderItemCell"];
    
    if (!IS_iOS8)
    {
        cell.contentView.frame = cell.bounds;
        cell.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    }
    
    UILabel *itemNameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    UILabel *itemPriceLabel = (UILabel *)[cell.contentView viewWithTag:2];
    itemNameLabel.text = orderItemsArray[indexPath.row][@"productName"];
    double price = [orderItemsArray[indexPath.row][@"totalPrice"] doubleValue];
    itemPriceLabel.text = [NSString stringWithFormat:@"$ %0.2f",price];
    
    return cell;
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSString *itemId = orderItemsArray[indexPath.row][@"id"];
        [[Database sharedObject] deleteProductWithId:[itemId intValue]];
        [orderItemsArray removeObjectAtIndex:indexPath.row];
        [orderListTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self updateOrderPriceDetails];
        NSLog(@"delete");
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (orderListTableView.editing == YES)
    {
        return UITableViewCellEditingStyleDelete;
    }
    return UITableViewCellEditingStyleNone;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (orderListTableView.editing == YES)
    {
        NSDictionary *selectedDict = orderItemsArray[indexPath.row];
        
        NSString *itemDictJson = selectedDict[@"itemDict"];
        NSDictionary *itemDict = [NSJSONSerialization JSONObjectWithData:[itemDictJson dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        
        NSMutableDictionary *menuItemDict = [[NSMutableDictionary alloc] init];
        [menuItemDict setObject:selectedDict[@"categoryId"] forKey:@"categoryId"];
        [menuItemDict setObject:selectedDict[@"serverId"] forKey:@"itemId"];
        [menuItemDict setObject:selectedDict[@"productName"] forKey:@"itemName"];
        [menuItemDict setObject:selectedDict[@"price"] forKey:@"price"];
        [menuItemDict setObject:itemDict[@"addonArray"] forKey:@"addonArray"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddToBasket" object:menuItemDict];

    }
    NSLog(@"did select");
}

#pragma mark - UIAlertView Delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 111)
    {
        if (buttonIndex == 0)
        {
            
        }
        else if (buttonIndex == 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"login" object:nil];
        }
    }
}

#pragma mark - UIPickerView Delegates

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger rowsInComponent;
    if (component==0)
    {
        rowsInComponent=[checkoutTypeArray count];
    }
    else
    {
        rowsInComponent=[checkoutTypeValuesArray count];
    }
    return rowsInComponent;
}



- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString * nameInRow;
    if (component==0)
    {
        nameInRow=[checkoutTypeArray objectAtIndex:row];
    }
    else  if (component==1)
    {
        nameInRow=[checkoutTypeValuesArray objectAtIndex:row];
    }
    
    return nameInRow;
}

#pragma mark - UITextView Delegates

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if ([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return FALSE;
    }
    
    if (textView.text.length >= 250)
    {
        if ([text isEqualToString:@""])
        {
            return TRUE;
        }
        return FALSE;
    }
    
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length >= 250)
    {
        commentsCountLabel.text = @"0";
    }
    else
    {
        commentsCountLabel.text = [NSString stringWithFormat:@"%lu",250 - textView.text.length];
    }
    
    if ([commentsCountLabel.text integerValue] <= 20)
    {
        commentsCountLabel.textColor = [UIColor redColor];
    }
    else
    {
        commentsCountLabel.textColor = [UIColor blackColor];
    }
    
}

#pragma mark - Keyboard Delegate

- (void)keyboardWillHide:(NSNotification *)n
{
    if (commentsTextView.text.length == 0)
    {
        commentsLabel.text = @"Write Comments...";
    }
    else
    {
        commentsLabel.text = commentsTextView.text;
    }
    isKeyboardShown = NO;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    commentsViewBottomConstraint.constant = 0;
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    commentsView.alpha = 0.0;
    bgImageView.alpha = 0.0;
    [UIView commitAnimations];
    
}

- (void)keyboardWillShow:(NSNotification *)n
{
    if (isKeyboardShown == YES)
    {
        return;
    }
    isKeyboardShown = YES;
    NSDictionary* userInfo = [n userInfo];
    
    // get the size of the keyboard
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    commentsView.alpha = 1.0;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    bgImageView.alpha = 0.6;
    commentsViewBottomConstraint.constant = keyboardSize.height;
    [self.view updateConstraintsIfNeeded];
    [self.view layoutIfNeeded];
    
    [UIView commitAnimations];
    
}


 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if ([[segue identifier] isEqualToString:@"CheckoutOrderSeque"])
     {
         PlaceOrderViewController *placeOrderObj = [segue destinationViewController];
         placeOrderObj.orderDict = orderDict;
     }
 }


@end
