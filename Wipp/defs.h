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

#define NUMBERS @"0123456789+"
#define ShowNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator()      [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#ifdef DEBUG
// DEV URLS
    // general
    #define TERMSURL @"http://127.0.0.1:8000/terms/"
    #define PRIVACYURL @"http://127.0.0.1:8000/privacy/"
    // accounts
    #define CHANGEPASSURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/password/change/"
    #define FORGOTPASSURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/password/reset/"
    #define LOGINURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/auth/token/"
    #define REGISTERURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/accounts/create/"
    #define PROFILEURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/accounts/"
    #define DRIVERURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/accounts/driver/"
    // reservations
    #define RESURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/reservations/"
    #define CREATEURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/reservations/create/"
    #define RESACCEPTURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/reservations/accept/"
    #define DRIVERFOUNDURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/reservations/driver/found/"
    #define RESCOMPLETEURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/reservations/complete/"
    #define RESCANCELURL @"http://127.0.0.1:8000/hidden/secure/wipp/api/reservations/cancel/"
#else
// PROD URLS
    // general
    #define TERMSURL @"https://pure-shelf-18585.herokuapp.com/terms/"
    #define PRIVACYURL @"https://pure-shelf-18585.herokuapp.com/privacy/"
    // accounts
    #define CHANGEPASSURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/password/change/"
    #define FORGOTPASSURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/password/reset/"
    #define LOGINURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/auth/token/"
    #define REGISTERURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/accounts/create/"
    #define PROFILEURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/accounts/"
    #define DRIVERURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/accounts/driver/"
    // reservations
    #define RESURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/reservations/"
    #define CREATEURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/reservations/create/"
    #define RESACCEPTURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/reservations/accept/"
    #define DRIVERFOUNDURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/reservations/driver/found/"
    #define RESCOMPLETEURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/reservations/complete/"
    #define RESCANCELURL @"https://pure-shelf-18585.herokuapp.com/hidden/secure/wipp/api/reservations/cancel/"
#endif

#define    UserDefaults          [NSUserDefaults standardUserDefaults]

#define    SetisUpdate(x)        [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"isUpdate"]
#define    GetisUpdate           [[NSUserDefaults standardUserDefaults] boolForKey:@"isUpdate"]

#define    SetAppKill(x)         [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"AppKill"]
#define    GetAppKill            [[NSUserDefaults standardUserDefaults] objectForKey:@"AppKill"]

#define    SetActiveRequest(x)   [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"ActiveRequest"]
#define    GetActiveRequest      [[NSUserDefaults standardUserDefaults] boolForKey:@"ActiveRequest"]

#define    SetFacebookToken(x)   [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"FacebookToken"]
#define    GetFacebookToken      [[NSUserDefaults standardUserDefaults] objectForKey:@"FacebookToken"]

#define    SetUserToken(x)       [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserToken"]
#define    GetUserToken          [[NSUserDefaults standardUserDefaults] objectForKey:@"UserToken"]

#define    SetUserID(x)          [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserID"]
#define    GetUserID             [[NSUserDefaults standardUserDefaults] integerForKey:@"UserID"]

#define    SetUserActive(x)      [[NSUserDefaults standardUserDefaults] setInteger:(x) forKey:@"UserActive"]
#define    GetUserActive         [[NSUserDefaults standardUserDefaults] integerForKey:@"UserActive"]

#define    SetUserIsDriver(x)    [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"UserIsDriver"]
#define    GetUserIsDriver       [[NSUserDefaults standardUserDefaults] boolForKey:@"UserIsDriver"]

#define    SetActiveDrive(x)     [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"ActiveDrive"]
#define    GetActiveDrive        [[NSUserDefaults standardUserDefaults] boolForKey:@"ActiveDrive"]

#define    SetReservationId(x)   [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"ReservationId"]
#define    GetReservationId      [[NSUserDefaults standardUserDefaults] objectForKey:@"ReservationId"]

#define    SetUserEmail(x)       [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserEmail"]
#define    GetUserEmail          [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"]

#define    SetUserPassword(x)    [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserPassword"]
#define    GetUserPassword       [[NSUserDefaults standardUserDefaults] objectForKey:@"UserPassword"]

#define    SetisMobile_Registered(x)    [NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"isMobileRegistered"]
#define    GetisMobile_Registered       [[NSUserDefaults standardUserDefaults] boolForKey:@"isMobileRegistered"]

#define    SetUserFullName(x)           [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"UserFullName"]
#define    GetUserFullName              [[NSUserDefaults standardUserDefaults] objectForKey:@"UserFullName"]

#define    SetProfilePic(x)      [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"ProfilePic"]
#define    GetProfilePic         [[NSUserDefaults standardUserDefaults] objectForKey:@"ProfilePic"]

#define    SetMobileNum(x)       [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"MobileNum"]
#define    GetMobileNum          [[NSUserDefaults standardUserDefaults] objectForKey:@"MobileNum"]

#define    SetUniversity(x)      [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"University"]
#define    GetUniversity         [[NSUserDefaults standardUserDefaults] objectForKey:@"University"]

#define    SetisFullView(x)      [[NSUserDefaults standardUserDefaults] setBool:(x) forKey:@"FullView"]
#define    GetsFullView          [[NSUserDefaults standardUserDefaults] boolForKey:@"FullView"]

#define    SetCurrentLoaction(x)    [[NSUserDefaults standardUserDefaults] setObject:(x) forKey:@"CurrentLocation"]
#define    GetCurrentLoaction       [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLocation"]

#endif
