//
//  UserDetails.h
//  RestoOrder
//
//  Created by Suresh Kumar on 14/07/15.
//
//

#import "UserDetails.h"
#import "Constants.h"
@implementation UserDetails

@synthesize userId, name, mobile, email, password, facebookId, latitude, longitude, userType;

static UserDetails *userDetailObj;

+(UserDetails *)sharedManager
{
    if (userDetailObj == nil)
    {
        userDetailObj = [[UserDetails alloc] init];
    }
    
    return userDetailObj;
}


-(void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:userId forKey:@"userid"];
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:mobile forKey:@"mobile"];
    [encoder encodeObject:email forKey:@"email"];
    [encoder encodeObject:password forKey:@"password"];
    [encoder encodeObject:facebookId forKey:@"facebookId"];
    [encoder encodeDouble:latitude forKey:@"latitude"];
    [encoder encodeDouble:longitude forKey:@"longitude"];
    [encoder encodeObject:userType forKey:@"userType"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        
        userId = [decoder decodeObjectForKey:@"userid"];
        name = [decoder decodeObjectForKey:@"name"];
        mobile = [decoder decodeObjectForKey:@"mobile"];
        email = [decoder decodeObjectForKey:@"email"];
        password = [decoder decodeObjectForKey:@"password"];
        facebookId = [decoder decodeObjectForKey:@"facebookId"];
        latitude = [decoder decodeDoubleForKey:@"latitude"];
        longitude = [decoder decodeDoubleForKey:@"longitude"];
        userType = [decoder decodeObjectForKey:@"userType"];
    }
    return self;
}

-(void)archiveUserDetails
{
    //archiving user detail object...
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userdetails"];
    [NSKeyedArchiver archiveRootObject:self toFile:filePath];
}

-(void)unarchiveUserDetail
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userdetails"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        UserDetails *archivedObj = [[UserDetails alloc] init];
        archivedObj = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
        
        userId = archivedObj.userId;
        name = archivedObj.name;
        mobile = archivedObj.mobile;
        email = archivedObj.email;
        password = archivedObj.password;
        facebookId = archivedObj.facebookId;
        latitude = archivedObj.latitude;
        longitude = archivedObj.longitude;
        userType = archivedObj.userType;
    }
}

-(void)deleteArchivedUserDetails
{
    self.userId = nil;
    self.name = nil;
    self.mobile = nil;
    self.email = nil;
    self.password = nil;
    self.facebookId = nil;
    self.latitude = 0.0;
    self.longitude = 0.0;
    userType = nil;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"userdetails"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

@end
