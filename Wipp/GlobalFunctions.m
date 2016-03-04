//
//  GlobalFunctions.m
//  Wipp
//

#import <Foundation/Foundation.h>

#import "defs.h"
#import "GlobalFunctions.h"
#import "Message.h"
#import "Reachability.h"
#import "TWMessageBarManager.h"


void checkNetworkReachability() {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if(networkStatus == NotReachable) {
        [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Network Error"
                                                       description:NETWORK_UNAVAILABLE
                                                              type:TWMessageBarMessageTypeError
                                                          duration:6.0];
        return;
    }
}

void showServerError() {
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Server Error"
                                                   description:SERVER_ERROR
                                                          type:TWMessageBarMessageTypeError
                                                      duration:4.0];
}
