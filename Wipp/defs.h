//
//  defs.h
//

#ifndef Casting_defs_h
#define Casting_defs_h

#include "AppDelegate.h"
#import "Message.h"

extern AppDelegate *appDelegate;

#define trim(x) [x stringByTrimmingCharactersInSet:WSset]
#if __LP64__ || (TARGET_OS_EMBEDDED && !TARGET_OS_IPHONE) || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
    #define SetSInt(x) [NSString stringWithFormat:@"%d",x]
    #define SetInt(x) [NSString stringWithFormat:@"%ld",x]
#else
    #define SetSInt(x) [NSString stringWithFormat:@"%d",x]
    #define SetInt(x) SetSInt(x)
#endif

#define DQ_  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
#define _DQ });
#define MQ_ dispatch_async( dispatch_get_main_queue(), ^(void) {
#define _MQ });

#define MAIN_FRAME [[UIScreen mainScreen]bounds]
#define SCREEN_WIDTH [[UIScreen mainScreen]bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen]bounds].size.height

#define fontLight(x)  [UIFont fontWithName:@"Raleway-Light" size:x];
#define fontRegular(x)  [UIFont fontWithName:@"Raleway-Regular" size:x];
#define fontMedium(x)  [UIFont fontWithName:@"Raleway-Medium" size:x];

#define EMAIL         @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.@-"
#define PASSWORD_CHAR @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890._-*@!"
#define USERNAME      @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
#define GROUPNAME     @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-,!@#$%^&*(){}[]|\/?':;.<>"

#define NUMBERS @"0123456789+"
#define NUMBERS1 @"0123456789"
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#ifdef DEBUG
    // DEV URLS
    #define TERMSURL @"http://127.0.0.1:8000/terms/"
    #define PRIVACYURL @"http://127.0.0.1:8000/privacy/"
    #define CHANGEPASSURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/password/change/"
    #define FORGOTPASSURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/password/reset/"
    #define LOGINURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/auth/token/"
    #define SIGNUPURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/accounts/create/"
    #define PROFILEURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/accounts/"
    #define CREATEURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/reservations/create/"
    #define SEARCH_URL @"http://127.0.0.1:8000/hidden/secure/wipp/api/search/?q="
#else
    // PROD URLS
    #define TERMSURL @"https://www.domain.com/terms/"
    #define PRIVACYURL @"https://www.domain.com/privacy/"
    #define CHANGEPASSURL @"https://www.domain.com/hidden/secure/wipp/api/password/change/"
    #define FORGOTPASSURL @"https://www.domain.com/hidden/secure/wipp/api/password/reset/"
    #define LOGINURL @"https://www.domain.com/hidden/secure/wipp/api/auth/token/"
    #define SIGNUPURL @"https://www.domain.com/hidden/secure/wipp/api/accounts/create/"
    #define PROFILEURL @"https://www.domain.com/hidden/secure/wipp/api/accounts/"
    #define CREATEURL @"https://www.domain.com/hidden/secure/wipp/api/reservations/create/"
    #define SEARCH_URL @"https://www.domain.com/hidden/secure/wipp/api/search/?q="
#endif

#define    SetisUpdate(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"isUpdate"]
#define    GetisUpdate            [[NSUserDefaults standardUserDefaults] boolForKey:@"isUpdate"]

#define    SetAppKill(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"AppKill"]
#define    GetAppKill              [[NSUserDefaults standardUserDefaults] objectForKey:@"AppKill"]

#define    SetUserToken(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserToken"]
#define    GetUserToken              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]

#define    SetUserID(x)           [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserID"]
#define    GetUserID               [[NSUserDefaults standardUserDefaults] integerForKey:@"UserID"]

#define    SetUserActive(x)           [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserActive"]
#define    GetUserActive               [[NSUserDefaults standardUserDefaults] integerForKey:@"UserActive"]

#define    SetEmailID(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"EmailID"]
#define    GetEmailID              [[NSUserDefaults standardUserDefaults] objectForKey:@"EmailID"]

#define    SetUserPassword(x)          [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserPassword"]
#define    GetUserPassword              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]

#define    SetisMobile_Registered(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"isMobileRegistered"]
#define    GetisMobile_Registered            [[NSUserDefaults standardUserDefaults] boolForKey:@"isMobileRegistered"]

#define    SetUserName(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserName"]
#define    GetUserName              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserName"]

#define    SetUserFullName(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserFullName"]
#define    GetUserFullName             [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFullName"]

#define    SetProifilePic(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"ProifilePic"]
#define    GetProifilePic              [[NSUserDefaults standardUserDefaults] objectForKey:@"ProifilePic"]

#define    SetUserMail(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserMail"]
#define    GetUserMail              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserMail"]

#define    SetFBID(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"FBID"]
#define    GetFBID              [[NSUserDefaults standardUserDefaults] objectForKey:@"FBID"]

#define    SetMobileNum(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"MobileNum"]
#define    GetMobileNum              [[NSUserDefaults standardUserDefaults] objectForKey:@"MobileNum"]

#define    SetIsVersion1(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"Version1"]
#define    GetsVersion1            [[NSUserDefaults standardUserDefaults] boolForKey:@"Version1"]

#define    SetisFullView(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"FullView"]
#define    GetsFullView            [[NSUserDefaults standardUserDefaults] boolForKey:@"FullView"]

#define UserDefaults            [NSUserDefaults standardUserDefaults]

#define SetLat(x)  [UserDefaults setObject:x forKey:@"C_Lat"]

#define GetLat()     [UserDefaults objectForKey:@"C_Lat"]

#define SetLong(x)  [UserDefaults setObject:x forKey:@"C_Long"]
#define GetLong()     [UserDefaults objectForKey:@"C_Long"]

#define SetFirst(x)  [UserDefaults setObject:x forKey:@"First"]
#define GetFirst     [UserDefaults objectForKey:@"First"]

#define    SetGender(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"Gender"]

#define    GetGender            [[NSUserDefaults standardUserDefaults] objectForKey:@"Gender"]

#define    SetCurrentLoaction(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"CurrentLocation"]

#define    GetCurrentLoaction            [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLocation"]

#define    SetIsFilter(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"Filter"]

#define    GetIsFilter            [[NSUserDefaults standardUserDefaults] boolForKey:@"Filter"]

#define    SetHelpOverlay(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"HelpOverlay"]

#define    GetHelpOverlay            [[NSUserDefaults standardUserDefaults] objectForKey:@"HelpOverlay"]

#define    SetInitialScreen(x)        [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"InitialScreen"]

#define    GetInitialScreen            [[NSUserDefaults standardUserDefaults] objectForKey:@"InitialScreen"]

#define    SetIsImageView(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"ImageView"]
#define    GetsImageView            [[NSUserDefaults standardUserDefaults] boolForKey:@"ImageView"]

#endif
