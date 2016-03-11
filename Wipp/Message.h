//
//  Message.h
//

#ifndef Wipp_Message_h
#define Wipp_Message_h

// General
#define INCORRECTOLDPASS @"Incorrect old password."
#define SERVER_ERROR @"Server error. Please try again later."
#define LOGIN_ERROR  @"Unable to login with provided credentials."
#define NETWORK_UNAVAILABLE  @"Please check your network connection."

// Sign in
#define USER_NOTREGISTERED @"The username or password is incorrect."
#define INCORRECT_PASSWORD @"This password is not correct."
#define EMAIL_EXISTS_ANOTHER_USER @"This email is already taken. Please try a different one."

// Sign up
#define INVALID_EMAIL @"Please enter a valid university (.edu) email address."
#define EMPTY_EMAIL @"Please enter your email in the designated field."
#define EMPTY_PASSWORD @"Please enter your password in the designated field."
#define EMPTY_CNF_PASSWORD @"Please verify your password."
#define EMAIL_EXISTS @"This email is already associated with an account."
#define INVALID_NAME @"Please enter a valid name."
#define EMPTY_NAME @"Please enter your full name in the designated field."
#define INVALID_MOBILE @"Please enter a valid phone number."
#define EMPTY_MOBILE @"Please enter your phone number in the designated field."
#define SIGNUP_SUCCESS @"Thank you for signing up on Wipp!"

// Forgot Password
#define EMPTY_OLD_PASSWORD @"Please enter your old password."
#define EMPTY_NEW_PASSWORD @"Please enter your new password."
#define EMPTY_CNF_NEW_PASSWORD @"Please confirm your password."
#define PASS_MIN_LEGTH @"Password must be longer than 5 characters."
#define PASS_SAME @"Your old password and new password must be different."
#define PASS_MISMATCH @"The passwords entered do not match."
#define PASS_SUCCESS @"Your password has been reset successfully."
#define PASS_FAILURE @"This email address does not exists."
#define PASS_SENT @"A password reset e-mail has been sent to you."

// Verify Mobile Number
#define VERIFICATION_MOBILE_SUCCESS @"Your number has been updated successfully."
#define VERIFICATION_MOBILE_EXISTS @"This mobile number is already registered. Please try a different number."

// Change Password
#define CHANGE_PASS_SUCCESS @"Your password has been updated successfully."
#define CHANGE_PASS_MISMATCH @"Incorrect old password."

// Settings
#define UPDATEPROFILE_SUCCESS @"Your profile has been updated."

#endif
