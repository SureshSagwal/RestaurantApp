//
//  UserDetails.h
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import <Foundation/Foundation.h>

@interface UserDetails : NSObject

@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *userType;

@property (nonatomic, strong) NSString *mobile;
@property(nonatomic, strong) NSString *facebookId;
@property(nonatomic, assign) double latitude;
@property(nonatomic, assign) double longitude;

+(UserDetails *)sharedManager;

-(void)archiveUserDetails;
-(void)unarchiveUserDetail;
-(void)deleteArchivedUserDetails;

@end
