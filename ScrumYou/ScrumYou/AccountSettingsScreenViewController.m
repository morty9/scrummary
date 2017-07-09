//
//  AccountSettingsScreenViewController.m
//  ScrumYou
//
//  Created by Bérangère La Touche on 08/03/2017.
//  Copyright © 2017 Bérangère La Touche. All rights reserved.
//

#import "AccountSettingsScreenViewController.h"
#import "LoginScreenViewController.h"
#import "CrudAuth.h"
#import "CrudUsers.h"

@interface AccountSettingsScreenViewController ()



@end


@implementation AccountSettingsScreenViewController {
    
    NSDictionary* token;
    User* currentUser;

    
    CrudAuth* Auth;
    CrudUsers* UsersCrud;
    
    //TO FIX Redirection vers une page apres modification
}

@synthesize token = _token;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        
        Auth = [[CrudAuth alloc] init];
        UsersCrud = [[CrudUsers alloc] init];
        currentUser = [[User alloc] init];

        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self designPage];
    Auth = [[CrudAuth alloc] init];

    NSString* userId = [[self.token valueForKey:@"userId"] stringValue];
    NSLog(@"USER ID %@", userId);
    
    dispatch_async(dispatch_get_main_queue(), ^{
    [UsersCrud getUserById:userId callback:^(NSError *error, BOOL success) {
        if (success) {
            
                currentUser = UsersCrud.user;
                [self displayUser:currentUser];
        }
    }];
        });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayUser:(User*)curUser {
    NSLog(@"Username: %@", [curUser valueForKey:@"_fullname"]);
    labelUserField.text = curUser.fullname;
    nameTextField.text = curUser.fullname;
    nicknameTextField.text = curUser.nickname;
    emailTextField.text = curUser.email;
    pwdTextField.text = curUser.password;
}


//TO FIX
- (IBAction)saveModification:(id)sender {
    
    [Auth login:emailTextField.text password:pwdTextField.text callback:^(NSError *error, BOOL sucess) {
        if (sucess) {
            
        }
    }];
}

//- (void)getCurrentUser:(NSNumber*)id_user {
//    [UsersCrud getUserById:[NSString stringWithFormat:@"%ld", (long)id_user] callback:^(NSError *error, BOOL success) {
//        if (success) {
//            NSLog(@"USER CRUD: %@", UsersCrud.user);
//            currentUser = UsersCrud.user;
//            //NSLog(@"CURRENT USER: %@", currentUser);
//        }
//    }];
//}



- (void) designPage {
    
    self.navigationItem.title = [NSString stringWithFormat:@"Profil"];
    
    //edit button navbar
//    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editProfil:)];
//    editButton.tintColor = [UIColor colorWithRed:0.14 green:0.22 blue:0.27 alpha:1.0];
//    self.navigationItem.rightBarButtonItem = editButton;
    
    //image profil
    profilImage.layer.cornerRadius = profilImage.frame.size.width / 2;
    profilImage.clipsToBounds = YES;
    
    //border name text field
    CALayer *borderName = [CALayer layer];
    CGFloat borderWidthName = 1;
    borderName.borderColor = [UIColor darkGrayColor].CGColor;
    borderName.frame = CGRectMake(0, nameTextField.frame.size.height - borderWidthName, nameTextField.frame.size.width, nameTextField.frame.size.height);
    borderName.borderWidth = borderWidthName;
    [nameTextField.layer addSublayer:borderName];
    nameTextField.layer.masksToBounds = YES;
    
    //border firstname text field
//    CALayer *borderFirstname = [CALayer layer];
//    CGFloat borderWidthFirstname = 1;
//    borderFirstname.borderColor = [UIColor darkGrayColor].CGColor;
//    borderFirstname.frame = CGRectMake(0, firstnameTextField.frame.size.height - borderWidthFirstname, firstnameTextField.frame.size.width, firstnameTextField.frame.size.height);
//    borderFirstname.borderWidth = borderWidthFirstname;
//    [firstnameTextField.layer addSublayer:borderFirstname];
//    firstnameTextField.layer.masksToBounds = YES;
    
    //border nickname text field
    CALayer *borderNickname = [CALayer layer];
    CGFloat borderWidthNickname = 1;
    borderNickname.borderColor = [UIColor darkGrayColor].CGColor;
    borderNickname.frame = CGRectMake(0, nicknameTextField.frame.size.height - borderWidthNickname, nicknameTextField.frame.size.width, nicknameTextField.frame.size.height);
    borderNickname.borderWidth = borderWidthNickname;
    [nicknameTextField.layer addSublayer:borderNickname];
    nicknameTextField.layer.masksToBounds = YES;
    
    //border email text field
    CALayer *borderEmail = [CALayer layer];
    CGFloat borderWidthEmail = 1;
    borderEmail.borderColor = [UIColor darkGrayColor].CGColor;
    borderEmail.frame = CGRectMake(0, emailTextField.frame.size.height - borderWidthEmail, emailTextField.frame.size.width, emailTextField.frame.size.height);
    borderEmail.borderWidth = borderWidthEmail;
    [emailTextField.layer addSublayer:borderEmail];
    emailTextField.layer.masksToBounds = YES;
    
    //border password text field
    CALayer *borderPassword = [CALayer layer];
    CGFloat borderWidthPassword = 1;
    borderPassword.borderColor = [UIColor darkGrayColor].CGColor;
    borderPassword.frame = CGRectMake(0, pwdTextField.frame.size.height - borderWidthPassword, pwdTextField.frame.size.width, pwdTextField.frame.size.height);
    borderPassword.borderWidth = borderWidthPassword;
    [pwdTextField.layer addSublayer:borderPassword];
    pwdTextField.layer.masksToBounds = YES;
    
}

- (void) editProfil {
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
