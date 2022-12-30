/*
 SFLoginViewController.h
 SalesforceSDKCore
 
 Created by Kunal Chitalia on 1/22/16.
 Copyright (c) 2016, salesforce.com, inc. All rights reserved.
 
 Redistribution and use of this software in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright notice, this list of conditions
 and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright notice, this list of
 conditions and the following disclaimer in the documentation and/or other materials provided
 with the distribution.
 * Neither the name of salesforce.com, inc. nor the names of its contributors may be used to
 endorse or promote products derived from this software without specific prior written
 permission of salesforce.com, inc.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
 WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SalesforceSDKCore.h"
#import <AVFoundation/AVFoundation.h>

@interface SFLoginViewController : UIViewController<UITextFieldDelegate,UITableViewDelegate,UIAlertViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate> {
    UILabel *_authorizingMessageLabel;
    UITextField *_usernameTextField;
    UITextField *_passwordTextField ;
    UIView *progressView;
    UIView *centerView;
    NSMutableString *selectedLanguage ;
}


/** Get a shared singleton of `SFLoginViewController` class
 */
+(_Nonnull instancetype)sharedInstance;

/**
 * Outlet to the OAuth web view.
 */
@property (nonatomic, strong, nullable) IBOutlet UIView* oauthView;
/**
 * The message label to show while loading.
 */
@property (nonatomic, strong) IBOutlet UITableView * _Nonnull languageTableView;
@property (nonatomic, strong) IBOutlet UITableView * _Nonnull cityTableView;
@property (nonatomic, strong) IBOutlet UITableView * _Nonnull salesCenterTableView;

@property (nonatomic, strong) IBOutlet UILabel * _Nonnull authorizingMessageLabel;
@property (nonatomic, strong) IBOutlet UITextField * _Nonnull usernameTextField;
@property (nonatomic, strong) IBOutlet UITextField * _Nonnull passwordTextField;
@property (nonatomic, strong) IBOutlet UIButton * _Nonnull languageButton;

@property (nonatomic, strong) IBOutlet UISwitch * _Nonnull loginTypeSwitch;
@property (nonatomic, strong) IBOutlet UILabel * _Nonnull loginTypeLabel;


@property (nonatomic, strong) IBOutlet UIButton * _Nonnull goButton;
@property (nonatomic, strong) IBOutlet UIButton * _Nonnull resetPasswordButton;

//@property (nonatomic, strong) IBOutlet UIButton * _Nonnull cityButton;
//@property (nonatomic, strong) IBOutlet UIButton * _Nonnull salesCenterButton;
@property (nonatomic, strong) IBOutlet UILabel * _Nonnull orLabel;
@property (nonatomic, strong) IBOutlet UIView * _Nonnull progressView;
@property (nonatomic, strong) IBOutlet UIView * _Nonnull centerView;
@property (weak,nonatomic) NSString * _Nullable msg;
@property (strong,nonatomic) NSMutableArray * _Nonnull langList;
@property (strong,nonatomic) NSMutableArray * _Nonnull cityList;
@property (strong,nonatomic) NSMutableArray * _Nonnull trCityList;
@property (strong,nonatomic) NSMutableArray * _Nonnull engCityList;
@property (strong,nonatomic) NSMutableArray * _Nonnull centerList;
@property (nonatomic) BOOL isLoginClick;
@property (nonatomic)  NSTimer * _Nullable t;
@property (nonatomic)  CGRect rect ;

@property (strong,nonatomic) NSString * _Nullable usernameLocal;
@property (strong,nonatomic) NSString * _Nullable passwordLocal;
@property (strong,nonatomic) NSString * _Nullable selectCityLocal;
@property (strong,nonatomic) NSString * _Nullable orLocal;
@property (strong,nonatomic) NSString * _Nullable selectSalesCenterLocal;

@property (nonatomic, strong) AVPlayerLayer * _Nullable playerLayer;
@property (nonatomic, strong) AVPlayer * _Nullable avPl;

/** Apply style to navigation bar */
- (void)styleNavigationBar:(nullable UINavigationBar *)navigationBar;
-(void) setLanguages;
@end
