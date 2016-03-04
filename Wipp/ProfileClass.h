//
//  ProfileClass.h
//

#import <Foundation/Foundation.h>


@interface ProfileClass : NSObject

@property (nonatomic, retain) NSString *Id;
@property (nonatomic, strong) NSString *account_url;
@property (nonatomic, retain) NSString *username;
@property (nonatomic, retain) NSString *email;
@property (nonatomic, retain) NSString *first_name;
@property (nonatomic, retain) NSString *last_name;
@property (nonatomic, retain) NSString *profile_picture;
@property (nonatomic, assign) BOOL is_driver;

@end
