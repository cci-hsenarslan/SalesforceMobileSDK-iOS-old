/*
 SFLoginViewController.m
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

@import UIKit;

#import "SFLoginViewController.h"
#import "SFSDKLoginHostListViewController.h"
#import "SFSDKLoginHostDelegate.h"
#define kOFFSET_FOR_KEYBOARD 200.0
#import "SFOAuthCredentials.h"
#import "UIView+Toast.h"

@interface SFLoginViewController () <SFSDKLoginHostDelegate, SFUserAccountManagerDelegate, SFAuthenticationManagerDelegate>
// Reference to the login host list view controller

// Reference to previous user account
@property (nonatomic, strong) SFUserAccount *previousUserAccount;


@end

BOOL isPreseller = false;

@implementation SFLoginViewController
@synthesize oauthView = _oauthView;
@synthesize authorizingMessageLabel = _authorizingMessageLabel;
@synthesize usernameTextField = _label;
@synthesize passwordTextField = _passwordTextField;
@synthesize progressView = _progressView;
@synthesize centerView = _centerView;
@synthesize msg,isLoginClick,t,languageButton,languageTableView,goButton, resetPasswordButton,cityTableView,salesCenterTableView,langList,cityList,centerList,orLabel,loginTypeSwitch,loginTypeLabel;
@synthesize usernameLocal;
@synthesize passwordLocal;
@synthesize selectCityLocal;
@synthesize orLocal;
@synthesize selectSalesCenterLocal;
@synthesize trCityList,engCityList;

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.progressView.hidden = YES;
    [t invalidate];
    t = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    if (_avPl != nil) {
        [_avPl pause];
    }
}


-(AVPlayerLayer*)playerLayer{
    if(!_playerLayer){
        
        // find movie file
        NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"cocacola_mobile" ofType:@"mp4"];
        NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
        _avPl = [[AVPlayer alloc]initWithURL:movieURL];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPl];
        _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _avPl.volume = 0;
        _avPl.actionAtItemEnd = AVPlayerActionAtItemEndNone;
        CGRect mainRect = [[UIScreen mainScreen] bounds];
        _playerLayer.frame = self.view.layer.bounds;
        [_playerLayer.player play];
        
        
        
    }
    return _playerLayer;
}
-(void)replayMovie:(NSNotification *)notification
{
    [self.playerLayer.player play];
    AVPlayerItem *p = notification.object;
    [p seekToTime:kCMTimeZero];
}
- (void)viewWillAppear:(BOOL)animated
{
    /*
     DispatchQueue.main.async(execute: {
     if let window = UIApplication.shared.keyWindow {
     window.windowLevel = UIWindowLevelStatusBar + 1
     }
     })
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        if (win != nil) {
            win.windowLevel = UIWindowLevelStatusBar + 1;
        }
    });
    
    _rect = self.view.frame;
    [super viewWillAppear:animated];
    self.progressView.hidden = YES;
    [t invalidate];
    t = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    if (_avPl != nil) {
        [_avPl play];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
    [super viewDidAppear:animated];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.progressView.hidden = YES;
}
-(void)dismissKeyboard
{
    [self.view endEditing:YES];
    languageTableView.hidden = YES;
}

- (void) switchToggled:(id)sender {
    UISwitch *mySwitch = (UISwitch *)sender;
    if ([mySwitch isOn]) {
        NSLog(@"its on!");
        isPreseller = true;
    } else {
        NSLog(@"its off!");
        isPreseller = false;
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:isPreseller forKey:@"isPreseller"];
    
    [self viewDidLoad];
    [self viewWillAppear:YES];
    
    
    //MARK: will come in handy soon
    if([self.usernameTextField.text length] >0)
        [[NSUserDefaults standardUserDefaults] setValue:[self.usernameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Username"];
    if([self.passwordTextField.text length] >0)
        [[NSUserDefaults standardUserDefaults] setValue:self.passwordTextField.text forKey:@"Password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    //removes webview and displayed login page
    [[SFAuthenticationManager sharedManager] dismissAuthViewControllerIfPresent];
    
    //changes login url, recreates session, re-inits login page
    [[SFAuthenticationManager sharedManager] loginAsNewUser];
    
}

- (void)dealloc {
    self.oauthView = nil;
    if (self.progressView != nil)
    {
        self.progressView.hidden = YES;
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    /*
     [self log:SFLogLevelDebug format:@"SFAuthorizingViewController shouldAutorotateToInterfaceOrientation: %d", interfaceOrientation];
     if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
     return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
     } else {
     return YES;
     }*/
    return NO;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)onTick:(NSTimer *)timer {
    if(t != nil)
    {
        [t invalidate];
        t = nil;
        self.progressView.hidden = YES;
        self.msg = @"Server error";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!"
                                                        message:msg
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
}
- (BOOL) validEmail:(NSString*) emailString {
    
    if([emailString length]==0){
        return NO;
    }
    
    NSString *regExPattern = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    NSLog(@"%i", regExMatches);
    if (regExMatches == 0) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL) validateEmail: (NSString *) candidate {
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

-(void) actionLogin
{
    
    CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
    style.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_dark_grey"]];
    
    if ([self.usernameTextField.text isEqual:@""] || [self.passwordTextField.text isEqual:@""]) {
        NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
        NSString *message = @"Kullanıcı adı veya şifre boş olamaz.";
        if([langValue isEqualToString:self.langList[0]])
        {
            message = @"Username or password can not be empty.";
        }
        else if([langValue isEqualToString:self.langList[2]])
        {
            message = @"Имя пользователя или пароль не должны быть пустыми.";
        }
        
        [self.view makeToast:message
                    duration:3.0
                    position:CSToastPositionBottom
                    style:style];
        return;
    }
    
    if (![self isQA] && [self validateEmail:self.usernameTextField.text]) {
        UIAlertController *emailAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"email_error_title", "") message:NSLocalizedString(@"email_error_message", "") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", "") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [emailAlert dismissViewControllerAnimated:YES completion:nil];
        }];
        [emailAlert addAction:okAction];
        [self presentViewController:emailAlert animated:YES completion:nil];
        return ;
    }
    
    
    
    NSString *loginUsername = self.usernameTextField.text;
    NSString *presellerPrefix = @"@cci.com.tr.sf";
    
    if ([self isQA]) {
        presellerPrefix = @"@cci.com.tr.sf.qa1";
    }
    
    t = [NSTimer scheduledTimerWithTimeInterval: 180.0
                                         target: self
                                       selector:@selector(onTick:)
                                       userInfo: nil repeats:NO];
    [self.usernameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    NSString *urlAdfs=@"https://sso.cci.com.tr/adfs/ls/";
    NSString *idLogin=@"ContentPlaceHolder1_UsernameTextBox";
    NSString *idPassword=@"ContentPlaceHolder1_PasswordTextBox";
    NSString *idError=@"ContentPlaceHolder1_ErrorTextLabel";
    NSString *loginSubmitButtonHTMLString=@"document.getElementById(\"ContentPlaceHolder1_SubmitButton\").click();";
    
    if ([self isQA]) {
        idLogin=@"username";
        idPassword=@"password";
        idError=@"error";
        loginSubmitButtonHTMLString=@"document.getElementById(\"Login\").click();";
    }
    
    if (isPreseller) {
        idLogin = @"username";
        idPassword = @"password";
        loginSubmitButtonHTMLString = @"document.getElementById(\"Login\").click();";
        urlAdfs = @"https://test.salesforce.com"; //this does nothing but..
        idError=@"Error";
        //
        //        NSString *processName = [[NSProcessInfo processInfo] processName];
        //        NSString *processID = [NSString stringWithFormat:@"%d", [[NSProcessInfo processInfo] processIdentifier]];
        loginUsername = [NSString stringWithFormat:@"%@%@", loginUsername, presellerPrefix];
        //        loginUsername = loginUsername + presellerPrefix;
    }
    
    self.progressView.hidden = NO;
    UIWebView*webView=(UIWebView*)self.oauthView;
    
    if([self.usernameTextField.text length] >0)
        [[NSUserDefaults standardUserDefaults] setValue:[self.usernameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] forKey:@"Username"];
    if([self.passwordTextField.text length] >0)
        [[NSUserDefaults standardUserDefaults] setValue:self.passwordTextField.text forKey:@"Password"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if(nil!=webView){
        [self set:idLogin
               to:[loginUsername stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
             html:webView ];
        [self set:idPassword
               to:[self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
             html:webView ];
        NSString * output=[webView stringByEvaluatingJavaScriptFromString:loginSubmitButtonHTMLString];
        
        NSTimeInterval delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSString * errorOutput=[webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"error\").textContent;"];
            NSLog(@"Do some work : %@", errorOutput);
            if(![errorOutput isEqual:@""]) {
                self.progressView.hidden = YES;
                CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
                style.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_dark_grey"]];
                
                NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
                NSString *message = @"Kullanıcı adı veya parola yanlış.";
                if([langValue isEqualToString:self.langList[0]])
                {
                    message = @"The user name or password is incorrect.";
                }
                else if([langValue isEqualToString:self.langList[2]])
                {
                    message = @"Неверное имя пользователя или пароль.";
                }
                
                [self.view makeToast:message
                            duration:3.0
                            position:CSToastPositionBottom
                            style:style];
            }
        });
        
        NSLog(@"output : %@",output);
    }
    
    
    NSString *currentURL = webView.request.URL.absoluteString;
    //    NSLog(@"load finished yo: %@  --- " , currentURL);
    
    if ([currentURL containsString:@"ChangePassword"] &&  [currentURL containsString:@"salesforce.com"] && [currentURL containsString:@"RemoteAccessAuthorizationPage"]) {
        
        webView.hidden = false;
        webView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        //        [[[[[UIApplication sharedApplication] keyWindow] subviews] lastObject] addSubview:webView];
        //        [self.view addSubview:webView];
        //        [self.view bringSubviewToFront:webView];
        self.progressView.hidden = true;
        
        [webView.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        
    }
    ////    [self.view bringSubviewToFront:webView];
    //
    //    [self.view addSubview:webView];
    //
    //
    //    [self.view layoutSubviews];
    
}

- (IBAction)clickedLogin:(id)sender {
    
    if(!self.languageTableView.hidden)
    {
        self.languageTableView.hidden = YES;
    }
    if(!self.salesCenterTableView.hidden)
    {
        self.salesCenterTableView.hidden = YES;
    }
    if(!self.cityTableView.hidden)
    {
        self.cityTableView.hidden = YES;
    }
    
    self.isLoginClick = YES;
    [self actionLogin];
    //[self performSelector:@selector(subscribe) withObject:self afterDelay:30.0 ];
}

- (IBAction)clickedResetPassword:(id)sender {
    printf("Clicked Reset Password Button!");
    
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PasswordRecovery" bundle:nil];
    UIViewController *vc = [sb instantiateViewControllerWithIdentifier:@"PasswordNavigationController"];

    [self presentViewController:vc animated:YES completion:NULL];

    
}

- (IBAction)clickedLanguage:(id)sender {
    
    self.salesCenterTableView.hidden = YES;
    self.cityTableView.hidden = YES;
    
    if(self.languageTableView.hidden)
    {
        self.languageTableView.hidden = NO;
    }
    else
    {
        self.languageTableView.hidden = YES;
    }
}

- (IBAction)clickedCity:(id)sender {
    
    self.salesCenterTableView.hidden = YES;
    self.languageTableView.hidden = YES;
    self.cityTableView.userInteractionEnabled = YES;
    if(self.cityTableView.hidden)
    {
        self.cityTableView.hidden = NO;
    }
    else
    {
        self.cityTableView.hidden = YES;
    }
}

- (IBAction)clickedSalesCenter:(id)sender {
    
    self.cityTableView.hidden = YES;
    self.languageTableView.hidden = YES;
    
    if(self.salesCenterTableView.hidden)
    {
        self.salesCenterTableView.hidden = NO;
    }
    else
    {
        self.salesCenterTableView.hidden = YES;
    }
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.salesCenterTableView) {
        return self.centerList.count;
    }
    else if (tableView == self.languageTableView) {
        return self.langList.count;
    }
    else if (tableView == self.cityTableView) {
        return self.cityList.count;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGRect rect = tableView.frame;
    UITableViewCell *cell  = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 50)];
    
    UILabel *lblUserName = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, rect.size.width-20, 35)];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, rect.size.width, 49)];
    NSString *text = @"";
    if (tableView == salesCenterTableView) {
        text = [centerList objectAtIndex:indexPath.row];
    }
    else if (tableView == languageTableView) {
        text = [langList objectAtIndex:indexPath.row];
        btn.tag = indexPath.row;
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapLangFrom:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        gestureRecognizer.delegate = self;
        [btn addGestureRecognizer:gestureRecognizer];
    }
    else if (tableView == cityTableView) {
        NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
        if([langValue isEqualToString:self.langList[1]]){
            text = [trCityList objectAtIndex:indexPath.row];
        }else{
            text = [engCityList objectAtIndex:indexPath.row];
            
        }
        btn.tag = indexPath.row;
        UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapCityFrom:)];
        gestureRecognizer.cancelsTouchesInView = NO;
        gestureRecognizer.delegate = self;
        [btn addGestureRecognizer:gestureRecognizer];
        
    }
    lblUserName.text = text;
    
    
    [cell.contentView addSubview:lblUserName];
    [cell.contentView addSubview:btn];
    return cell;
}
- (void) handleTapCityFrom: (UITapGestureRecognizer *)recognizer
{
    NSString *text = [cityList objectAtIndex:recognizer.view.tag];
    [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"SelectedCity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    cityTableView.tag = recognizer.view.tag;
    NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
    //    if([langValue isEqualToString:self.langList[1]]){
    //        [self.cityButton setTitle:[self.trCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
    //    }else{
    //        [self.cityButton setTitle:[self.engCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
    //    }
    cityTableView.hidden = YES;
}

- (void) handleTapLangFrom: (UITapGestureRecognizer *)recognizer
{
    NSString *text = [langList objectAtIndex:recognizer.view.tag];
    
    [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"LangValue"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self setLanguages];
    self.usernameTextField.placeholder = usernameLocal;
    self.passwordTextField.placeholder = passwordLocal;
    
    NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
    //    if([langValue isEqualToString:self.langList[1]]){
    //        [self.cityButton setTitle:[self.trCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
    //    }else{
    //        [self.cityButton setTitle:[self.engCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
    //    }
    
    
    
    //    [self.salesCenterButton setTitle:selectSalesCenterLocal forState:UIControlStateNormal];
    self.orLabel.text = orLocal;
    [languageButton setTitle:text forState:UIControlStateNormal];
    languageTableView.hidden = YES;
    [cityTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *text = @"";
    if (tableView == salesCenterTableView) {
        text = [centerList objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"SelectedSalesCenter"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        //        [salesCenterButton setTitle:text forState:UIControlStateNormal];
        salesCenterTableView.hidden = YES;
    }
    else if (tableView == languageTableView) {
        text = [langList objectAtIndex:indexPath.row];
        
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"LangValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self setLanguages];
        self.usernameTextField.placeholder = usernameLocal;
        self.passwordTextField.placeholder = passwordLocal;
        
        NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
        //        if([langValue isEqualToString:self.langList[1]]){
        //            [self.cityButton setTitle:[self.trCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
        //        }else{
        //            [self.cityButton setTitle:[self.engCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
        //        }
        
        
        
        //        [self.salesCenterButton setTitle:selectSalesCenterLocal forState:UIControlStateNormal];
        self.orLabel.text = orLocal;
        [languageButton setTitle:text forState:UIControlStateNormal];
        languageTableView.hidden = YES;
        [cityTableView reloadData];
    }
    else if (tableView == cityTableView) {
        text = [cityList objectAtIndex:indexPath.row];
        [[NSUserDefaults standardUserDefaults] setValue:text forKey:@"SelectedCity"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        cityTableView.tag = indexPath.row;
        NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
        //        if([langValue isEqualToString:self.langList[1]]){
        //            [self.cityButton setTitle:[self.trCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
        //        }else{
        //            [self.cityButton setTitle:[self.engCityList objectAtIndex:cityTableView.tag] forState:UIControlStateNormal];
        //        }
        cityTableView.hidden = YES;
    }
}


-(void)subscribe
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:@"Connection Error"
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSString*)set:(NSString*)domId to:(NSString*)val html:(UIWebView *)webView{
    NSString * cmd=[NSString stringWithFormat:@"document.getElementById(\"%@\").value=\"%@\" " ,domId,val];
    return [webView stringByEvaluatingJavaScriptFromString:cmd];
}


#pragma mark - Properties
-(void) aMethod:(UIButton*)sender
{
    NSLog(@"you clicked on button ");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder && textField.tag == 0) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    
    if(textField.tag == 1)
    {
        return YES;
    }
    return NO;
}
-(void) setLanguages
{
    NSString *selectedSalesCenterValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"SelectedSalesCenter"];
    NSString *selectedCityValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"SelectedCity"];
    NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
    if(langValue == nil || [langValue isEqualToString:@""])
    {
        langValue = self.langList[0];
        [[NSUserDefaults standardUserDefaults] setValue:langValue forKey:@"LangValue"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
    if(selectedCityValue == nil || [selectedCityValue isEqualToString:@""])
    {
        selectedCityValue = self.cityList[0];
        [[NSUserDefaults standardUserDefaults] setValue:selectedCityValue forKey:@"SelectedCity"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if([langValue isEqualToString:self.langList[0]])
    {
        usernameLocal = @"Username";
        passwordLocal = @"Password";
        // selectCityLocal = @"TR";
        selectSalesCenterLocal = @"Select Sales Center";
        orLocal = @"OR";
        loginTypeLabel.text = @"Distributor Login";
        [goButton setTitle: @"Login" forState:UIControlStateNormal];
    }
    else if([langValue isEqualToString:self.langList[1]])
    {
        usernameLocal = @"Kullanıcı Adı";
        passwordLocal = @"Şifre";
        // selectCityLocal = @"TR";
        selectSalesCenterLocal = @"Satış Noktası Seçiniz";
        orLocal = @"VEYA";
        loginTypeLabel.text = @"Dağıtıcı Girişi";
        [goButton setTitle: @"Giriş" forState:UIControlStateNormal];
        
    }
    else if([langValue isEqualToString:self.langList[2]])
    {
        usernameLocal = @"Пользователь";
        passwordLocal = @"Пароль";
        //  selectCityLocal = @"TR";
        selectSalesCenterLocal = @"Выберите Центр продаж";
        orLocal = @"или";
        loginTypeLabel.text = @"Distributor Login";
        [goButton setTitle: @"Логин" forState:UIControlStateNormal];
        
    }
    else if([langValue isEqualToString:self.langList[3]])
    {
        usernameLocal = @"İstifadəçi adı";
        passwordLocal = @"Şifrə";
        //  selectCityLocal = @"TR";
        selectSalesCenterLocal = @"Satış Noktası Seçiniz";
        orLocal = @"VEYA";
        loginTypeLabel.text = @"Distributor Login";
        
    }
    
    if(selectedSalesCenterValue != nil && ![selectedSalesCenterValue isEqualToString:@""])
    {
        selectSalesCenterLocal = selectedSalesCenterValue;
    }
    
    if(selectedCityValue != nil && ![selectedCityValue isEqualToString:@""])
    {
        selectCityLocal = selectedCityValue;
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    self.languageTableView.hidden = YES;
}

- (void)setOauthView:(UIView *)oauthView {
    
    
    if (![oauthView isEqual:_oauthView]) {
        self.langList = [NSMutableArray new];
        [self.langList addObject:@"ENG"];
        [self.langList addObject:@"TUR"];
        [self.langList addObject:@"RUS"];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];

       
        self.view.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.9];
        UIImageView *bottleImage = [[UIImageView alloc] initWithFrame:self.view.layer.bounds];
        
        bottleImage.userInteractionEnabled = YES;
        bottleImage.image = [UIImage imageNamed:@"cci2"];
        bottleImage.contentMode = UIViewContentModeScaleAspectFill;
        UITapGestureRecognizer *singleFingerTap =
          [[UITapGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleSingleTap:)];
        [bottleImage addGestureRecognizer:singleFingerTap];
        [bottleImage addGestureRecognizer:tap];
        
        [self.view addSubview:bottleImage];
        //[self.view.layer addSublayer:self.playerLayer];
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(replayMovie:)
                                                     name: AVPlayerItemDidPlayToEndTimeNotification
                                                   object:_avPl.currentItem];
        self.cityList = [NSMutableArray new];
        [self.cityList addObject:@"TR"];
        //[self.cityList addObject:@"AZ"];
        [self.cityList addObject:@"IQ"];
        [self.cityList addObject:@"JO"];
        [self.cityList addObject:@"KG"];
        [self.cityList addObject:@"KZ"];
        [self.cityList addObject:@"PK"];
        [self.cityList addObject:@"SQ"];
        [self.cityList addObject:@"SY"];
        [self.cityList addObject:@"TJ"];
        [self.cityList addObject:@"TM"];
        
        
        if(self.trCityList == nil) {
            self.trCityList = [[NSMutableArray alloc] init];
        }
        
        [self.trCityList removeAllObjects];
        [self.trCityList addObject:@"Türkiye"];
        //[self.trCityList addObject:@"Azerbaycan"];
        [self.trCityList addObject:@"Kuzey Iraq"];
        [self.trCityList addObject:@"Ürdün"];
        [self.trCityList addObject:@"Kırgızistan"];
        [self.trCityList addObject:@"Kazakistan"];
        [self.trCityList addObject:@"Pakistan"];
        [self.trCityList addObject:@"Güney Irak"];
        [self.trCityList addObject:@"Suriye"];
        [self.trCityList addObject:@"Tacikistan"];
        [self.trCityList addObject:@"Türkmenistan"];
        if(self.engCityList == nil) {
            self.engCityList = [[NSMutableArray alloc] init];
        }
        
        [self.engCityList removeAllObjects];
        
        [self.engCityList addObject:@"Turkey"];
        //[self.engCityList addObject:@"Azerbaijan"];
        [self.engCityList addObject:@"North Iraq"];
        [self.engCityList addObject:@"Jordan"];
        [self.engCityList addObject:@"Kyrgyzstan"];
        [self.engCityList addObject:@"Kazakhstan"];
        [self.engCityList addObject:@"Pakistan"];
        [self.engCityList addObject:@"South Iraq"];
        [self.engCityList addObject:@"Syria"];
        [self.engCityList addObject:@"Tajikistan"];
        [self.engCityList addObject:@"Turkmenistan"];
        
        
        
        
        
        //  [self.cityList addObject:@"PKST"];
        
        self.centerList = [NSMutableArray new];
        [self.centerList addObject:@"Center 1"];
        [self.centerList addObject:@"Center 2"];
        [self.centerList addObject:@"Center 3"];
        
        self.msg = @"";
        self.isLoginClick = NO;
        
        [self setLanguages];
        
        NSString *usernameValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"Username"];
        NSString *passValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"Password"];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(askCredentials:)
                                                     name:@"askCredentials"
                                                   object:nil];
        isPreseller = [[NSUserDefaults standardUserDefaults] boolForKey:@"isPreseller"];
        
        
        
        [_oauthView removeFromSuperview];
        _oauthView = oauthView;
        
        if (nil != _oauthView) {
            
            
            CGRect mainRect = [[UIScreen mainScreen] bounds];
            CGFloat firstY =  (mainRect.size.height/4)-110;
            mainRect = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width - 40, [[UIScreen mainScreen] bounds].size.height);
            languageTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 52,  mainRect.size.width-20, 130)
                                                             style:UITableViewStylePlain];
            languageTableView.layer.cornerRadius = 8;
            //  languageTableView.tag = 0;
            languageTableView.delegate = self;
            languageTableView.dataSource = self;
            languageTableView.backgroundColor = [UIColor whiteColor];
            languageTableView.allowsSelection = YES;
            languageTableView.hidden = YES;
            [languageTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            [languageTableView reloadData];
            salesCenterTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 100,  mainRect.size.width-20, 150)
                                                                style:UITableViewStyleGrouped];
            //    salesCenterTableView.tag = 1;
            salesCenterTableView.delegate = self;
            salesCenterTableView.dataSource = self;
            salesCenterTableView.backgroundColor = [UIColor clearColor];
            salesCenterTableView.hidden = YES;
            
            
            cityTableView = [[UITableView alloc] initWithFrame:CGRectMake(10, 176,  mainRect.size.width-20, 110)
                                                         style:UITableViewStylePlain];
            cityTableView.tag = 0;
            cityTableView.delegate = self;
            cityTableView.dataSource = self;
            cityTableView.backgroundColor = [UIColor whiteColor];
            [cityTableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            cityTableView.hidden = YES;
            
            [_oauthView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
            [_oauthView setFrame:self.view.bounds];
    
            //   self.view.backgroundColor = [UIColor colorWithRed:199.0/255.0 green:0/255.0 blue:17.0/255.0 alpha:1];
            //            self.view.backgroundColor = background;
            
            CGRect upRect = CGRectMake(mainRect.size.width/2-106, 110, 150, 85);
            UIImageView *forManagersImageView = [[UIImageView alloc] initWithFrame:upRect];
            
            forManagersImageView.image = [UIImage imageNamed:@"ccim_logo_bottle"];
            
            CGRect centerRect = CGRectMake(0,mainRect.size.height-340, mainRect.size.width, 300);
            
            self.centerView = [[UIView alloc] initWithFrame:centerRect];
            UITapGestureRecognizer *singleFingerTap =
              [[UITapGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleSingleTap:)];
            [self.centerView addGestureRecognizer:singleFingerTap];
            self.usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 10, mainRect.size.width-20, 40)];
            UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
            self.usernameTextField.leftViewMode =UITextFieldViewModeAlways;
            self.usernameTextField.leftView = paddingView;
            self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.usernameTextField.delegate = self;
            self.usernameTextField.placeholder = usernameLocal;
            self.usernameTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
            self.usernameTextField.textColor = [UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1];
            self.usernameTextField.font = [UIFont systemFontOfSize:18];
            self.usernameTextField.layer.cornerRadius = 8;
            if(usernameValue != nil)
                self.usernameTextField.text = usernameValue;
            //   self.label.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg_form_username.png"]];
            CGRect labelRect = self.usernameTextField.bounds;
            UIImage *img2 = [UIImage imageNamed:@"i_username"];
            UIImageView *imageView2 = [[UIImageView alloc] initWithImage:img2];
            imageView2.frame = CGRectMake(10, 12,16,16);
            [self.usernameTextField addSubview:imageView2 ];
            self.usernameTextField.backgroundColor = [UIColor whiteColor];
            
            self.passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 55,  mainRect.size.width-20, 40)];
            self.passwordTextField.placeholder = passwordLocal;
            self.passwordTextField.delegate = self;
            self.passwordTextField.secureTextEntry = YES;
            self.passwordTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            self.passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
            self.passwordTextField.textColor = [UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1];
            self.passwordTextField.font = [UIFont systemFontOfSize:18];
            self.passwordTextField.layer.cornerRadius = 8;
            if(passValue != nil)
                self.passwordTextField.text = passValue;
            
            UIImage *img3 = [UIImage imageNamed:@"i_pw"];
            UIImageView *imageView3 = [[UIImageView alloc] initWithImage:img3];
            imageView3.frame = CGRectMake(10, 12,16,16);
            [self.passwordTextField addSubview:imageView3 ];
            self.passwordTextField.backgroundColor = [UIColor whiteColor];
            
            UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 20)];
            self.passwordTextField.leftViewMode =UITextFieldViewModeAlways;
            self.passwordTextField.leftView = paddingView2;
            
            
            self.languageButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 100,  mainRect.size.width-20, 40)];
            UIImage *imgLang = [UIImage imageNamed:@"i_language"];
            UIImageView *imageViewLang = [[UIImageView alloc] initWithImage:imgLang];
            imageViewLang.frame = CGRectMake(10, 12,16,16);
            [self.languageButton addSubview:imageViewLang ];
            
            UIImage *imgRightArrow1 = [UIImage imageNamed:@"i_select_arrow_down"];
            UIImageView *imgViewRightArrow1 = [[UIImageView alloc] initWithImage:imgRightArrow1];
            imgViewRightArrow1.frame = CGRectMake(languageButton.frame.size.width-20, 15,15,10);
            [self.languageButton addSubview:imgViewRightArrow1 ];
            
            
            NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
            [self.languageButton setTitle:langValue forState:UIControlStateNormal];
            [self.languageButton setTitleColor:[UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1] forState:UIControlStateNormal ];
            self.languageButton.backgroundColor = [UIColor whiteColor];
            self.languageButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.languageButton.contentEdgeInsets = UIEdgeInsetsMake(0,40, 0, 0);
            [self.languageButton addTarget:self
                                    action:@selector(clickedLanguage:)
                          forControlEvents:UIControlEventTouchUpInside];
            self.languageButton.font = [UIFont systemFontOfSize:18];
            self.languageButton.layer.cornerRadius = 8;
            
            //            self.cityButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 145,  mainRect.size.width-20, 40)];
            UIImage *imgCity = [UIImage imageNamed:@"i_selectcitypin"];
            UIImageView *imageViewCity = [[UIImageView alloc] initWithImage:imgCity];
            imageViewCity.frame = CGRectMake(10, 12,16,16);
            //            [self.cityButton addSubview:imageViewCity ];
            
            UIImage *imgRightArrow2 = [UIImage imageNamed:@"i_select_arrow_down"];
            UIImageView *imgViewRightArrow2 = [[UIImageView alloc] initWithImage:imgRightArrow2];
            //            imgViewRightArrow2.frame = CGRectMake(cityButton.frame.size.width-20, 15,15,10);
            //            [self.cityButton addSubview:imgViewRightArrow2 ];
            //
            //            [self.cityButton setTitle:[self.engCityList objectAtIndex:0] forState:UIControlStateNormal];
            //            [self.cityButton setTitleColor:[UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1] forState:UIControlStateNormal ];
            //            self.cityButton.backgroundColor = [UIColor whiteColor];
            //            self.cityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            //            self.cityButton.contentEdgeInsets = UIEdgeInsetsMake(0,40, 0, 0);
            //            [self.cityButton addTarget:self
            //                                action:@selector(clickedCity:)
            //                      forControlEvents:UIControlEventTouchUpInside];
            //            self.cityButton.font = [UIFont systemFontOfSize:18];
            //            self.cityButton.layer.cornerRadius = 8;
            
            
            
            //            self.salesCenterButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 230,  mainRect.size.width-20, 40)];
            //            UIImage *imgSalesCenter = [UIImage imageNamed:@"i_selectsalescenter"];
            //            UIImageView *imageViewSalesCenter = [[UIImageView alloc] initWithImage:imgSalesCenter];
            //            imageViewSalesCenter.frame = CGRectMake(10, 12,16,16);
            //            [self.salesCenterButton addSubview:imageViewSalesCenter ];
            //
            //            UIImage *imgRightArrow3 = [UIImage imageNamed:@"i_select_arrow_down"];
            //            UIImageView *imgViewRightArrow3 = [[UIImageView alloc] initWithImage:imgRightArrow3];
            //            imgViewRightArrow3.frame = CGRectMake(salesCenterButton.frame.size.width-20, 15,15,10);
            //            [self.salesCenterButton addSubview:imgViewRightArrow3 ];
            //
            //            [self.salesCenterButton setTitle:@"Select Sales Center" forState:UIControlStateNormal];
            //            [self.salesCenterButton setTitleColor:[UIColor colorWithRed:200.0/255.0 green:160.0/255.0 blue:160.0/255.0 alpha:1] forState:UIControlStateNormal ];
            //            self.salesCenterButton.backgroundColor = [UIColor whiteColor];
            //            self.salesCenterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            //            self.salesCenterButton.contentEdgeInsets = UIEdgeInsetsMake(0,40, 0, 0);
            //            [self.salesCenterButton addTarget:self
            //                                       action:@selector(clickedSalesCenter:)
            //                             forControlEvents:UIControlEventTouchUpInside];
            //            self.salesCenterButton.font = [UIFont systemFontOfSize:18];
            
            
            self.loginTypeSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(mainRect.size.width-65, 145,  mainRect.size.width-20, 40)];
            self.loginTypeSwitch.backgroundColor = [UIColor clearColor];
            self.loginTypeSwitch.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            [self.loginTypeSwitch addTarget:self action:@selector(switchToggled:) forControlEvents:UIControlEventValueChanged];
            
            
            self.loginTypeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 145 ,  mainRect.size.width-20, 30)];
            loginTypeLabel.text = @"Distributor Login";
            loginTypeLabel.textColor = [UIColor whiteColor];
            loginTypeLabel.textAlignment = NSTextAlignmentLeft;
            loginTypeLabel.font = [UIFont systemFontOfSize:18];
            
            
            //            self.cityButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 145,  mainRect.size.width-20, 40)];
            //            imageViewCity.frame = CGRectMake(10, 12,16,16);
            //            [self.cityButton addSubview:imageViewCity ];
            
            
            NSString *buttonTitle = @"Giriş";
            if([langValue isEqualToString:self.langList[0]])
            {
                buttonTitle = @"Login";
            }
            else if([langValue isEqualToString:self.langList[2]])
            {
                buttonTitle = @"Логин";
            }
            
            
            self.goButton =  [[UIButton alloc] initWithFrame:CGRectMake(10,190,  mainRect.size.width-20, 40)];
            self.goButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_dark_grey"]];
            [self.goButton setTitle:buttonTitle forState:UIControlStateNormal];
            self.goButton.titleLabel.textColor = [UIColor whiteColor];
            [self.goButton addTarget:self
                              action:@selector(clickedLogin:)
                    forControlEvents:UIControlEventTouchUpInside];
            self.goButton.font = [UIFont boldSystemFontOfSize:18];
            self.goButton.layer.cornerRadius = 8;
            
            
            
            self.resetPasswordButton =  [[UIButton alloc] initWithFrame:CGRectMake(10,240,  mainRect.size.width-20, 40)];
            [self.resetPasswordButton setTitle:@"Reset Password" forState:UIControlStateNormal];
            self.resetPasswordButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_dark_grey"]];
            self.resetPasswordButton.titleLabel.textColor = [UIColor whiteColor];
            [self.resetPasswordButton addTarget:self
                                         action:@selector(clickedResetPassword:)
                               forControlEvents:UIControlEventTouchUpInside];
            self.resetPasswordButton.font = [UIFont boldSystemFontOfSize:18];
            self.resetPasswordButton.layer.cornerRadius = 8;
            
            
            orLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 239 ,  mainRect.size.width-20, 30)];
            UIImage *imgOrLabel = [UIImage imageNamed:@"or_divider"];
            UIImageView *imgViewOrLabel = [[UIImageView alloc] initWithImage:imgOrLabel];
            imgViewOrLabel.frame = CGRectMake(0, 15 ,  mainRect.size.width-20, 1);
            [orLabel addSubview:imgViewOrLabel];
            orLabel.text = orLocal;
            orLabel.textColor = [UIColor whiteColor];
            orLabel.textAlignment = NSTextAlignmentCenter;
            orLabel.font = [UIFont systemFontOfSize:18];
            
            self.progressView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            _progressView.layer.shadowColor = [UIColor blackColor].CGColor;
            _progressView.layer.shadowOpacity = 1;
            _progressView.layer.shadowOffset = CGSizeZero;
            _progressView.layer.shadowRadius = 5;
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            spinner.color = [UIColor whiteColor];
            [spinner startAnimating];
            CGSize size = [UIScreen mainScreen].bounds.size;
            CGFloat w = size.width;
            CGFloat h = size.height;
            CGSize subViewSize = CGSizeMake(w * 0.35, h * 0.35);
            UIView * subView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, subViewSize.width, subViewSize.height)];
            subView.backgroundColor = [UIColor blackColor];
            subView.alpha = 0.3;
            subView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
            subView.layer.cornerRadius = 15.0f;
            subView.layer.masksToBounds = YES;
            
            UIButton * btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
            [btnCancel addTarget:self action:@selector(onButtonClickListener:) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView* animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, subViewSize.width * 0.6, subViewSize.height * 0.7)];
            animatedImageView.contentMode = UIViewContentModeScaleAspectFit;
            animatedImageView.animationImages = [NSArray arrayWithObjects:
                                                 [UIImage imageNamed:@"gif1"],
                                                 [UIImage imageNamed:@"gif2"],
                                                 [UIImage imageNamed:@"gif3"],
                                                 [UIImage imageNamed:@"gif4"],
                                                 [UIImage imageNamed:@"gif5"],
                                                 [UIImage imageNamed:@"gif6"],
                                                 [UIImage imageNamed:@"gif7"],
                                                 [UIImage imageNamed:@"gif8"],
                                                 [UIImage imageNamed:@"gif9"],
                                                 [UIImage imageNamed:@"gif10"],
                                                 [UIImage imageNamed:@"gif11"],
                                                 [UIImage imageNamed:@"gif12"],
                                                 [UIImage imageNamed:@"gif13"],
                                                 [UIImage imageNamed:@"gif14"],
                                                 [UIImage imageNamed:@"gif15"],
                                                 [UIImage imageNamed:@"gif16"],
                                                 [UIImage imageNamed:@"gif17"],
                                                 [UIImage imageNamed:@"gif18"],
                                                 [UIImage imageNamed:@"gif19"],
                                                 [UIImage imageNamed:@"gif20"],
                                                 [UIImage imageNamed:@"gif21"],
                                                 [UIImage imageNamed:@"gif22"],
                                                 [UIImage imageNamed:@"gif23"],
                                                 [UIImage imageNamed:@"gif24"],
                                                 [UIImage imageNamed:@"gif25"],
                                                 [UIImage imageNamed:@"gif26"],
                                                 [UIImage imageNamed:@"gif27"],
                                                 [UIImage imageNamed:@"gif28"],
                                                 [UIImage imageNamed:@"gif29"],
                                                 [UIImage imageNamed:@"gif30"],
                                                 [UIImage imageNamed:@"gif31"],
                                                 [UIImage imageNamed:@"gif32"],
                                                 [UIImage imageNamed:@"gif33"],
                                                 [UIImage imageNamed:@"gif34"],
                                                 [UIImage imageNamed:@"gif35"],
                                                 [UIImage imageNamed:@"gif36"],
                                                 [UIImage imageNamed:@"gif37"],
                                                 [UIImage imageNamed:@"gif38"],nil];
            animatedImageView.animationDuration = 2.3f;
            animatedImageView.animationRepeatCount = 0;
            [animatedImageView startAnimating];
            
            animatedImageView.center = CGPointMake(_progressView.frame.size.width / 2, _progressView.frame.size.height / 2);
            
            //            [subView addSubview:spinner];
            //            spinner.center = CGPointMake(subView.frame.size.width / 2, subView.frame.size.height / 2);
            
            [subView addSubview:btnCancel];
            
            
            [self.progressView addSubview:subView];
            [_progressView addSubview: animatedImageView];
            self.progressView.hidden = YES;
            
            _oauthView.hidden = YES;
            CGRect c=CGRectMake(0, 0,310,230);
            [_oauthView setFrame:c];
            UIView *divider =[[UIView alloc] initWithFrame:CGRectMake(10, 55, mainRect.size.width-20, 1)];
            divider.backgroundColor = [UIColor colorWithRed:207.0/255.0 green:207.0/255.0 blue:207.0/255.0 alpha:1];
            
            self.usernameTextField.tag = 0;
            self.passwordTextField.tag = 1;
            [self.centerView addSubview:self.usernameTextField];
            [self.centerView addSubview:self.passwordTextField];
            [self.centerView addSubview:self.languageButton];
            [self.centerView addSubview:self.loginTypeSwitch];
            [self.centerView addSubview:self.loginTypeLabel];
            
            //            [self.centerView addSubview:self.cityButton];
            //    [self.centerView addSubview:self.salesCenterButton];
            //    [self.centerView addSubview:orLabel];
            //    [self.centerView addSubview:divider];
            [self.centerView addSubview:goButton];
            
            if (isPreseller) {
                [self.centerView addSubview:resetPasswordButton];
            }
            
            [self.centerView addSubview:languageTableView];
            [self.centerView addSubview:cityTableView];
            [self.view addSubview:forManagersImageView];
            [self.view addSubview:self.centerView];
            [self.view addSubview:_oauthView];
            //      [self.centerView addSubview:salesCenterTableView];
            
            [self.view addSubview:self.progressView];
            self.progressView.center = CGPointMake(self.view.center.x, self.view.center.y);
            
            self.centerView.center = CGPointMake(self.view.center.x, self.centerView.center.y);
            forManagersImageView.center = CGPointMake(self.view.center.x, forManagersImageView.center.y);
            
            
            UIView *versionView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, 100, 40)];
            UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
            [versionView addSubview:versionLabel];
            if (@available(iOS 11.0, *)) {
                UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
                CGFloat topPadding = window.safeAreaInsets.top;
                
                versionView.frame = CGRectMake(self.view.frame.size.width - 120, topPadding + 10, 100, 40);
            }
            versionLabel.textColor = UIColor.whiteColor;
            versionView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
            versionView.layer.cornerRadius = 8;
            [self.view addSubview:versionView];
            versionLabel.textAlignment = UITextAlignmentCenter;
            
            versionLabel.text = [NSString stringWithFormat:@"v%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        }
        if(usernameValue != nil && usernameValue.length > 0
           && passValue != nil && passValue.length > 0)
        {
            Boolean isChangeCountry =[[NSUserDefaults standardUserDefaults] boolForKey:@"ChangeCountry"];
            if (isChangeCountry) {
                [[NSUserDefaults standardUserDefaults] setBool:false forKey:@"ChangeCountry"];
            }
            else {
                self.isLoginClick = YES;
                [self actionLogin];
            }
            
        }
        
        if (isPreseller) {
            [loginTypeSwitch setOn:YES animated:YES];
        }
    }
    
    
}
- (void) askCredentials:(NSNotification *) notification
{
    if(self.isLoginClick)
    {
        
        self.isLoginClick = NO;
        self.progressView.hidden = YES;
        if([notification.object length] > 0 && ![notification.object isEqualToString:self.msg] )
        {
            
            [t invalidate];
            t = nil;
            
            NSString *langValue =[[NSUserDefaults standardUserDefaults] stringForKey:@"LangValue"];
            NSString *message = @"Kullanıcı adı veya parola yanlış.";
            if([langValue isEqualToString:self.langList[0]])
            {
                message = @"The user name or password is incorrect.";
            }
            else if([langValue isEqualToString:self.langList[2]])
            {
                message = @"Неверное имя пользователя или пароль.";
            }
            
            CSToastStyle *style = [[CSToastStyle alloc] initWithDefaultStyle];
            style.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"btn_dark_grey"]];
            
            [self.view makeToast:message
                        duration:3.0
                        position:CSToastPositionBottom
                        style:style];
            
        }
        else
        {
            self.isLoginClick = YES;
            [self actionLogin];
            
        }
        
    }
    else
    {
    }
    
    
    
    
}

+(instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static SFLoginViewController *loginViewController = nil;
    dispatch_once(&onceToken, ^{
        loginViewController = [[self alloc] initWithNibName:nil bundle:nil];
    });
    return loginViewController;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[SFUserAccountManager sharedInstance] addDelegate:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _usernameTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.view.backgroundColor = [UIColor grayColor];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}



- (BOOL)shouldShowBackButton {
    NSInteger totalAccounts = [SFUserAccountManager sharedInstance].allUserAccounts.count;
    if (totalAccounts > 0) {
        if (totalAccounts == 1) {
            SFUserAccount *userAccount = [SFUserAccountManager sharedInstance].allUserAccounts.firstObject;
            return !(userAccount.isTemporaryUser);
        } else {
            return YES;
        }
    }
    return NO;
}

- (IBAction)backToPreviousHost:(id)sender {
    [[SFAuthenticationManager sharedManager] cancelAuthentication];
    if (self.previousUserAccount) {
        [[SFUserAccountManager sharedInstance] switchToUser:self.previousUserAccount];
    }
}



-(void) onButtonClickListener:(id) sender {
    
    
    [t invalidate];
    UIWebView * webView = (UIWebView*)self.oauthView;
    
    if (webView != nil) {
        [webView stopLoading];
        self.isLoginClick = NO;
    }
    
    self.progressView.hidden = YES;
    
}

#pragma mark - Styling Methods for Nav bar

#pragma mark - SF Authentication Manager

- (void)userAccountManager:(SFUserAccountManager *)userAccountManager
        willSwitchFromUser:(SFUserAccount *)fromUser
                    toUser:(SFUserAccount *)toUser {
    if (!fromUser.isTemporaryUser) {
        self.previousUserAccount = fromUser;
    }
}


+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    [self setViewMovedUp:YES];
}

-(void)keyboardWillHide {
    [self setViewMovedUp:NO];
}

-(void)textFieldDidBeginEditing:(UITextField *)sender
{
    [self setViewMovedUp:YES];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y = _rect.origin.y -  kOFFSET_FOR_KEYBOARD;
        rect.size.height = _rect.size.height + kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y = _rect.origin.y;
        rect.size.height = _rect.size.height;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


-(NSMutableString*) currentVersion {
    NSMutableString* version = [NSString stringWithFormat:@"Version %@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    return version;
}

-(BOOL) isQA {
    
    BOOL rtn = [[self currentVersion] containsString:@"QA"];
    return rtn;
}


@end

