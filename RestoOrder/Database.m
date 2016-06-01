//
//  Database.m
//  Delivery
//
//  Created by Suresh Kumar on 20/02/15.
//  Copyright (c) 2015 WebSnoox Technologies. All rights reserved.
//

#import "Database.h"
#import <UIKit/UIKit.h>
#define DATABASENAME @"delivery.sqlite3"

@implementation Database
static Database *obj = nil;

@synthesize dataArray;

+(Database *)sharedObject
{
    if (obj == nil)
    {
        obj = [[Database alloc]init];
    }
    return obj;
}

-(NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:DATABASENAME];
}

// Handler used to create Database
-(void)createDatabase:(int)type
{
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    switch (type)
    {
        case 1:
        {
            [self createAddressTable];
        }
            break;
        case 2:
        {
            [self createProductTable];
        }
            break;
        case 3:
        {
            [self createRestaurantDetailTable];
        }
            
        default:
            break;
    }
}

#pragma mark - AddressTable

-(void)createAddressTable
{
    NSString *createQuery = @"CREATE TABLE IF NOT EXISTS Address(ID INT PRIMARY KEY, ADDRESS1 TEXT, ADDRESS2 TEXT, IS_DEFAULT INT, PIN TEXT, USER_ID TEXT)";
    
    char *errorMsg = nil;
    
    if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK)
    {
        NSString *countQuery = @"SELECT COUNT(*) FROM Address";
        
        sqlite3_stmt *compliedStmt = nil;
        
        if (sqlite3_prepare(database, [countQuery UTF8String], -1, &compliedStmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(compliedStmt) == SQLITE_ROW)
            {
                
            }
        }
        else
        {
            NSLog(@"create database error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        sqlite3_finalize(compliedStmt);
        
    }
    
    else
    {
        NSLog(@"create database error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    sqlite3_close(database);
}

-(void)addNewAddressWithAddress1:(NSString *)address1 Address2:(NSString *)address2 pin:(NSString *)pincode is_Default:(int)isDefault
{
    [self createDatabase:1];
    
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    int rowId = 0;
    sqlite3_stmt *countStmt = nil;
    NSString *countQuery = @"SELECT MAX(ID) FROM Address";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowId = sqlite3_column_int(countStmt, 0);
            
            rowId ++;
        }
    }
    sqlite3_finalize(countStmt);
    
    char *insertQuery = "INSERT OR REPLACE INTO Address (ID, ADDRESS1, ADDRESS2,IS_DEFAULT,PIN) VALUES (?, ?, ?, ?, ?);";
    
    sqlite3_stmt *compiledStmt;
    
    if (sqlite3_prepare_v2(database, insertQuery, -1, &compiledStmt, nil) == SQLITE_OK)
    {
        
        sqlite3_last_insert_rowid(database);
        
        sqlite3_bind_int(compiledStmt, 1, rowId);
        sqlite3_bind_text(compiledStmt, 2, [address1 UTF8String], -1, NULL);
        sqlite3_bind_text(compiledStmt, 3, [address2 UTF8String], -1, NULL);
        sqlite3_bind_int(compiledStmt, 4, isDefault);
        sqlite3_bind_text(compiledStmt, 5, [pincode UTF8String], -1, NULL);
        
    }
    NSLog(@"insertQuery :%s",insertQuery);
    
    if (sqlite3_step(compiledStmt) == SQLITE_DONE)
    {
    }
    else
    {
        NSLog(@"insert record error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sqlite3_finalize(compiledStmt);
    sqlite3_close(database);

}

-(void)updateAddressWithAddress1:(NSString *)address1 Address2:(NSString *)address2 pin:(NSString *)pincode is_Default:(int)isDefault AddressId:(int)addressId
{
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    sqlite3_stmt *compiledStmt;
    
    char *insertQuery = "UPDATE Address SET ADDRESS1 = ?, ADDRESS2 = ?, PIN = ?, IS_DEFAULT = ? WHERE ID = ?;";
    
    if (sqlite3_prepare_v2(database, insertQuery, -1, &compiledStmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(compiledStmt, 1, [address1 UTF8String], -1, NULL);
        sqlite3_bind_text(compiledStmt, 2, [address2 UTF8String], -1, NULL);
        sqlite3_bind_text(compiledStmt, 3, [pincode UTF8String], -1, NULL);
        sqlite3_bind_int(compiledStmt, 4, isDefault);
        sqlite3_bind_int(compiledStmt, 5, addressId);
    }
    
    if (sqlite3_step(compiledStmt) == SQLITE_DONE)
    {
        
    }
    else
    {
        NSLog(@"update error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sqlite3_finalize(compiledStmt);
    sqlite3_close(database);
}

-(void)deleteAddressWithId:(int)addressId
{
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    sqlite3_stmt *compiledStmt;
    
    BOOL  check = TRUE;
    
    char *insertQuery = "DELETE FROM Address WHERE ID = ?;";
    
    if (sqlite3_prepare_v2(database, insertQuery, -1, &compiledStmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_int(compiledStmt, 1, addressId);
    }
    
    if (sqlite3_step(compiledStmt) == SQLITE_DONE)
    {
        NSLog(@"deleted");
    }
    else
    {
        check = FALSE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sqlite3_finalize(compiledStmt);
    sqlite3_close(database);
}

-(NSArray *)readAllAddresses
{
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    sqlite3_stmt *countStmt = nil;
    
    int rowid = 0;
    NSMutableArray *addressArray = [[NSMutableArray alloc]init];
    
    NSString *countQuery = @"SELECT COUNT(*) FROM Address;";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowid = sqlite3_column_int(countStmt, 0);
        }
    }
    sqlite3_finalize(countStmt);
    if (rowid != 0)
    {
        NSString *readingQuery = @"SELECT * FROM Address;";
        
        sqlite3_stmt *compiledStmt = nil;
        
        if (sqlite3_prepare(database, [readingQuery UTF8String], -1, &compiledStmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(compiledStmt) == SQLITE_ROW)
            {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 0)] forKey:@"id"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 1)] forKey:@"address1"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 2)] forKey:@"address2"];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 3)] forKey:@"isDefault"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 4)] forKey:@"pin"];
                
                [addressArray addObject:dict];
            }
            
        }
        
        else
        {
            NSLog(@" reading error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        sqlite3_finalize(compiledStmt);
    }
    sqlite3_close(database);
    
    return addressArray;
}

-(void)deleteAllAddresses
{
    
    [self createDatabase:1];
    
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    sqlite3_stmt *statement;
    
    NSString *readingQuery = @"DELETE FROM Address";
    
    if (sqlite3_prepare_v2( database, [readingQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@", @"deleted");
        }
    }
    else
    {
        NSAssert(0, @"Failed to Delete");
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
}

#pragma mark - CartTable

-(void)createProductTable
{
    NSString *createQuery = @"CREATE TABLE IF NOT EXISTS CartProduct(ID INTEGER PRIMARY KEY, NAME TEXT, SERVER_ID INTEGER, QUANTITY INTEGER, PRICE DOUBLE, ADDON_IDS TEXT, CATEGORY_ID TEXT, ITEM_DICT TEXT, TOTAL_PRICE DOUBLE)";
    
    char *errorMsg = nil;
    
    if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK)
    {
        NSString *countQuery = @"SELECT COUNT(*) FROM CartProduct";
        
        sqlite3_stmt *compliedStmt = nil;
        
        if (sqlite3_prepare(database, [countQuery UTF8String], -1, &compliedStmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(compliedStmt) == SQLITE_ROW)
            {
                
            }
        }
        else
        {
            NSLog(@"create database error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        sqlite3_finalize(compliedStmt);
        
    }
    
    else
    {
        NSLog(@"create database error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
     sqlite3_close(database);
}

-(void)addNewProductWithName:(NSString *)productName server_Id:(NSString *)serverId quantity:(int)qty price:(double)price TotalPrice:(double)totalPrice addon_Ids:(NSString *)addonIds CategoryId:(NSString *)categoryId ItemDict:(NSString *)itemDict
{
    [self createDatabase:2];
    
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    int rowId = 0;
    sqlite3_stmt *countStmt = nil;
    NSString *countQuery = @"SELECT MAX(ID) FROM CartProduct";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowId = sqlite3_column_int(countStmt, 0);
            
            rowId ++;
        }
    }
    sqlite3_finalize(countStmt);
    
    char *insertQuery = "INSERT OR REPLACE INTO CartProduct (ID, NAME, SERVER_ID, QUANTITY, PRICE, ADDON_IDS,CATEGORY_ID, ITEM_DICT, TOTAL_PRICE) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);";
    
    sqlite3_stmt *compiledStmt;
    
    if (sqlite3_prepare_v2(database, insertQuery, -1, &compiledStmt, nil) == SQLITE_OK)
    {
        
        sqlite3_last_insert_rowid(database);
        
        sqlite3_bind_int(compiledStmt, 1, rowId);
        sqlite3_bind_text(compiledStmt, 2, [productName UTF8String], -1, NULL);
        sqlite3_bind_text(compiledStmt, 3, [serverId UTF8String], -1, NULL);
        sqlite3_bind_int(compiledStmt, 4, qty);
        sqlite3_bind_double(compiledStmt, 5, price);
        sqlite3_bind_text(compiledStmt, 6, [addonIds UTF8String], -1, NULL);
        sqlite3_bind_text(compiledStmt, 7, [categoryId UTF8String], -1, NULL);
        sqlite3_bind_text(compiledStmt, 8, [itemDict UTF8String], -1, NULL);
        sqlite3_bind_double(compiledStmt, 9, totalPrice);
        
    }
    NSLog(@"insertQuery :%s",insertQuery);
    
    if (sqlite3_step(compiledStmt) == SQLITE_DONE)
    {
        
    }
    else
    {
        NSLog(@"insert record error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sqlite3_finalize(compiledStmt);
    sqlite3_close(database);
}

-(NSDictionary *)readProductWithId:(NSString *)serverId
{
    int rowid = 0;
    NSDictionary *productDict;
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    sqlite3_stmt *countStmt = nil;
    
    NSString *countQuery = @"SELECT COUNT(*) FROM CartProduct WHERE SERVER_ID = ?;";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(countStmt, 1, [serverId UTF8String], -1, NULL);
        
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowid = sqlite3_column_int(countStmt, 0);
        }
    }
    sqlite3_finalize(countStmt);
    if (rowid != 0)
    {
        NSString *readingQuery = @"SELECT * FROM CartProduct WHERE SERVER_ID = ?;";
        
        sqlite3_stmt *compiledStmt = nil;
        
        if (sqlite3_prepare(database, [readingQuery UTF8String], -1, &compiledStmt, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(compiledStmt, 1, [serverId UTF8String], -1, NULL);
            
            while (sqlite3_step(compiledStmt) == SQLITE_ROW)
            {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 0)] forKey:@"id"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 1)] forKey:@"productName"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 2)] forKey:@"serverId"];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 3)] forKey:@"quantity"];
                [dict setObject:[NSString stringWithFormat:@"%f",sqlite3_column_double(compiledStmt, 4)] forKey:@"price"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 5)] forKey:@"addonIds"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 6)] forKey:@"categoryId"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 7)] forKey:@"itemDict"];
                [dict setObject:[NSString stringWithFormat:@"%f",sqlite3_column_double(compiledStmt, 8)] forKey:@"totalPrice"];
                
                productDict = dict;
            }
            
        }
        
        else
        {
            NSLog(@" reading error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        sqlite3_finalize(compiledStmt);
    }
    sqlite3_close(database);
    
    return productDict;
}

-(NSArray *)readAllProducts
{
    [self createDatabase:2];
    
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    sqlite3_stmt *countStmt = nil;
    
    int rowid = 0;
    NSMutableArray *addressArray = [[NSMutableArray alloc]init];
    
    NSString *countQuery = @"SELECT COUNT(*) FROM CartProduct;";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowid = sqlite3_column_int(countStmt, 0);
        }
    }
    sqlite3_finalize(countStmt);
    if (rowid != 0)
    {
        NSString *readingQuery = @"SELECT * FROM CartProduct;";
        
        sqlite3_stmt *compiledStmt = nil;
        
        if (sqlite3_prepare(database, [readingQuery UTF8String], -1, &compiledStmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(compiledStmt) == SQLITE_ROW)
            {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 0)] forKey:@"id"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 1)] forKey:@"productName"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 2)] forKey:@"serverId"];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 3)] forKey:@"quantity"];
                [dict setObject:[NSString stringWithFormat:@"%f",sqlite3_column_double(compiledStmt, 4)] forKey:@"price"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 5)] forKey:@"addonIds"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 6)] forKey:@"categoryId"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 7)] forKey:@"itemDict"];
                [dict setObject:[NSString stringWithFormat:@"%f",sqlite3_column_double(compiledStmt, 8)] forKey:@"totalPrice"];
                
                [addressArray addObject:dict];
            }
            
        }
        
        else
        {
            NSLog(@" reading error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        sqlite3_finalize(compiledStmt);
    }
    sqlite3_close(database);
    
    return addressArray;
}

-(void)updateProductWithId:(int)productId quantity:(int)qty price:(double)price TotalPrice:(double)totalPrice addon_Ids:(NSString *)addonIds
{
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    sqlite3_stmt *compiledStmt;
    
    char *insertQuery = "UPDATE CartProduct SET QUANTITY = ?, PRICE = ?, ADDON_IDS = ?, TOTAL_PRICE = ? WHERE SERVER_ID = ?;";
    
    if (sqlite3_prepare_v2(database, insertQuery, -1, &compiledStmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_int(compiledStmt, 1, qty);
        sqlite3_bind_double(compiledStmt, 2, price);
        sqlite3_bind_text(compiledStmt, 3, [addonIds UTF8String], -1, NULL);
        sqlite3_bind_int(compiledStmt, 4, totalPrice);
        sqlite3_bind_double(compiledStmt, 5, productId);
    }
    
    if (sqlite3_step(compiledStmt) == SQLITE_DONE)
    {
        
    }
    else
    {
        NSLog(@"update error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sqlite3_finalize(compiledStmt);
    sqlite3_close(database);
}

-(void)deleteProductWithId:(int)productId
{
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    sqlite3_stmt *compiledStmt;
    
    BOOL  check = TRUE;
    
    char *insertQuery = "DELETE FROM CartProduct WHERE ID = ?;";
    
    if (sqlite3_prepare_v2(database, insertQuery, -1, &compiledStmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_int(compiledStmt, 1, productId);
    }
    
    if (sqlite3_step(compiledStmt) == SQLITE_DONE)
    {
        NSLog(@"deleted");
    }
    else
    {
        check = FALSE;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sqlite3_finalize(compiledStmt);
    sqlite3_close(database);
}

-(void)deleteAllProducts
{
    [self createDatabase:2];
    
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    sqlite3_stmt *statement;
    
    NSString *readingQuery = @"DELETE FROM CartProduct";
    
    if (sqlite3_prepare_v2( database, [readingQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@", @"deleted");
        }
    }
    else
    {
        NSAssert(0, @"Failed to Delete");
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);
}

#pragma mark - RestaurantDetails Table

-(void)createRestaurantDetailTable
{
    NSString *createQuery = @"CREATE TABLE IF NOT EXISTS RestaurantDetail(ID INTEGER PRIMARY KEY, RID TEXT, RESTAURANT_DICT TEXT)";
    
    char *errorMsg = nil;
    
    if (sqlite3_exec(database, [createQuery UTF8String], NULL, NULL, &errorMsg) == SQLITE_OK)
    {
        NSString *countQuery = @"SELECT COUNT(*) FROM RestaurantDetail";
        
        sqlite3_stmt *compliedStmt = nil;
        
        if (sqlite3_prepare(database, [countQuery UTF8String], -1, &compliedStmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(compliedStmt) == SQLITE_ROW)
            {
                
            }
        }
        else
        {
            NSLog(@"create database error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        
        sqlite3_finalize(compliedStmt);
        
    }
    
    else
    {
        NSLog(@"create database error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    sqlite3_close(database);
}

-(void)addNewRestaurantWithId:(NSString *)rId DetailDict:(NSString *)detailDict
{
    [self createDatabase:3];
    
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    int rowId = 0;
    sqlite3_stmt *countStmt = nil;
    NSString *countQuery = @"SELECT MAX(ID) FROM RestaurantDetail";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowId = sqlite3_column_int(countStmt, 0);
            
            rowId ++;
        }
    }
    sqlite3_finalize(countStmt);
    
    char *insertQuery = "INSERT OR REPLACE INTO RestaurantDetail (ID, RID, RESTAURANT_DICT) VALUES (?, ?, ?);";
    
    sqlite3_stmt *compiledStmt;
    
    if (sqlite3_prepare_v2(database, insertQuery, -1, &compiledStmt, nil) == SQLITE_OK)
    {
        
        sqlite3_last_insert_rowid(database);
        sqlite3_bind_int(compiledStmt, 1, rowId);
        sqlite3_bind_text(compiledStmt, 2, [rId UTF8String], -1, NULL);
        sqlite3_bind_text(compiledStmt, 3, [detailDict UTF8String], -1, NULL);
        
    }
    NSLog(@"insertQuery :%s",insertQuery);
    
    if (sqlite3_step(compiledStmt) == SQLITE_DONE)
    {
        
    }
    else
    {
        NSLog(@"insert record error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    sqlite3_finalize(compiledStmt);
    sqlite3_close(database);

}

-(NSDictionary *)readRestaurantWithId:(NSString *)restaurantId
{
    [self createDatabase:3];
    
    int rowid = 0;
    NSDictionary *productDict;
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    sqlite3_stmt *countStmt = nil;
    
    NSString *countQuery = @"SELECT COUNT(*) FROM RestaurantDetail WHERE RID = ?;";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        sqlite3_bind_text(countStmt, 1, [restaurantId UTF8String], -1, NULL);
        
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowid = sqlite3_column_int(countStmt, 0);
        }
    }
    sqlite3_finalize(countStmt);
    if (rowid != 0)
    {
        NSString *readingQuery = @"SELECT * FROM RestaurantDetail WHERE RID = ?;";
        
        sqlite3_stmt *compiledStmt = nil;
        
        if (sqlite3_prepare(database, [readingQuery UTF8String], -1, &compiledStmt, NULL) == SQLITE_OK)
        {
            sqlite3_bind_text(compiledStmt, 1, [restaurantId UTF8String], -1, NULL);
            
            while (sqlite3_step(compiledStmt) == SQLITE_ROW)
            {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 0)] forKey:@"id"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 1)] forKey:@"rId"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 2)] forKey:@"detailDict"];
                
                productDict = dict;
            }
            
        }
        
        else
        {
            NSLog(@" reading error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        sqlite3_finalize(compiledStmt);
    }
    sqlite3_close(database);
    
    return productDict;

}

-(NSDictionary *)readRestaurant
{
    [self createDatabase:3];
    NSDictionary *productDict;
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    
    sqlite3_stmt *countStmt = nil;
    
    int rowid = 0;
    NSString *countQuery = @"SELECT COUNT(*) FROM RestaurantDetail;";
    if (sqlite3_prepare(database, [countQuery UTF8String], -1, &countStmt, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(countStmt) == SQLITE_ROW)
        {
            rowid = sqlite3_column_int(countStmt, 0);
        }
    }
    sqlite3_finalize(countStmt);
    if (rowid != 0)
    {
        NSString *readingQuery = @"SELECT * FROM RestaurantDetail;";
        
        sqlite3_stmt *compiledStmt = nil;
        
        if (sqlite3_prepare(database, [readingQuery UTF8String], -1, &compiledStmt, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(compiledStmt) == SQLITE_ROW)
            {
                
                NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
                [dict setObject:[NSString stringWithFormat:@"%d",sqlite3_column_int(compiledStmt, 0)] forKey:@"id"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 1)] forKey:@"rId"];
                [dict setObject:[NSString stringWithUTF8String:(char*)sqlite3_column_text(compiledStmt, 2)] forKey:@"detailDict"];
                
                productDict = dict;
            }
            
        }
        
        else
        {
            NSLog(@" reading error code :%d  error message :%s",sqlite3_errcode(database), sqlite3_errmsg(database));
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ooops, something went wrong" message:@"We have encountered a rare problem. please close the app completely and launch again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
        sqlite3_finalize(compiledStmt);
    }
    sqlite3_close(database);
    
    return productDict;

}

-(void)deleteRestaurantDetail
{
    [self createDatabase:3];
    
    NSString *path = [self dataFilePath];
    sqlite3_open([path UTF8String], &database);
    sqlite3_stmt *statement;
    
    NSString *readingQuery = @"DELETE FROM RestaurantDetail";
    
    if (sqlite3_prepare_v2( database, [readingQuery UTF8String], -1, &statement, NULL) == SQLITE_OK)
    {
        while (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"%@", @"deleted");
        }
    }
    else
    {
        NSAssert(0, @"Failed to Delete");
    }
    sqlite3_finalize(statement);
    sqlite3_close(database);

}

@end
