//
//  AppDelegate.h
//  Wipp
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(AppDelegate*) getDelegate;
+(void)showMessage:(NSString *)message;

@property (strong, nonatomic) NSMutableDictionary *dictProfileInfo;

//Activity Methods
-(void)showHUDAddedToView2:(UIView *)view message:(NSString *)message;
-(void)showHUDAddedToView:(UIView *)view message:(NSString *)message;
-(void)hideHUDForView2:(UIView *)view;
-(void)hideHUDForView:(UIView *)view;
-(void)showHUDAddedTo:(UIView *)view ;
-(void)showHUDAddedTo:(UIView *)view message:(NSString *)message ;
-(void)UpdateMessage:(NSString *)message;

//Validation Methods
+(BOOL)validateFullName:(NSString *)fullName;
+(BOOL)validateEmail:(NSString *)email;
+(BOOL)isValidCharacter:(NSString*)string filterCharSet:(NSString*)set;
+(BOOL)validateMobileNum:(NSString *)mobileNum;
-(NSString*)formatNumber:(NSString*)mobileNumber;
-(int)getLength:(NSString*)mobileNumber;

-(void)userLogout;


@end

