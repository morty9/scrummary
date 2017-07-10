//
//  LoginScreenViewController.m
//  ScrumYou
//
//  Created by Bérangère La Touche on 08/03/2017.
//  Copyright © 2017 Bérangère La Touche. All rights reserved.
//

#import "LoginScreenViewController.h"
#import "HomeScreenViewController.h"
#import "UserHomeScreenViewController.h"
#import "CrudAuth.h"
#import "CrudProjects.h"
#import "Project.h"
#import "AccountSettingsScreenViewController.h"
#import "AddProjectScreenViewController.h"

@interface LoginScreenViewController ()

@end

@implementation LoginScreenViewController {
 
    CrudProjects* ProjectsCrud;
    CrudAuth* Auth;
    
    NSDictionary* token;
    NSMutableArray<Project*>* get_project;
    
    bool userHaveProject;
    
    AddProjectScreenViewController* addProjectVC;
    AccountSettingsScreenViewController* accountSettings;
    UserHomeScreenViewController* userHomeVC;

}

@synthesize token = _token;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        
        ProjectsCrud = [[CrudProjects alloc] init];
        get_project = [[NSMutableArray<Project*> alloc] init];
        userHaveProject = false;
        
        [ProjectsCrud getProjects:^(NSError *error, BOOL success) {
            if (success) {
                NSLog(@"SUCCESS PROJECT");
                get_project = ProjectsCrud.projects_list;
            }
        }];
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self designPage];
    Auth = [[CrudAuth alloc] init];
    addProjectVC = [[AddProjectScreenViewController alloc] init];
    accountSettings = [[AccountSettingsScreenViewController alloc] init];
    userHomeVC = [[UserHomeScreenViewController alloc] init];
}

- (IBAction)connectionButton:(id)sender {
    
    [Auth login:emailTextField.text password:pwdTextField.text callback:^(NSError *error, BOOL success) {
        if (success) {
            NSLog(@"CONNECTED");
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"AUTH TOKEN %@", Auth.token);
                addProjectVC.token_dic = Auth.token;
                accountSettings.token = Auth.token;
                
                [self checkIfMemberHaveProject:get_project tokenActive:Auth.token];
                
                if (userHaveProject == true) {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self.navigationController pushViewController:userHomeVC animated:YES];
                    }
                );} else {
                    dispatch_async(dispatch_get_main_queue(), ^ {
                        [self.navigationController pushViewController:addProjectVC animated:YES];
                    }
                );}
                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self.navigationController pushViewController:accountSettings animated:YES];
//                });
            });
        }
    }];
}

- (void) checkIfMemberHaveProject:(NSArray*)array_projects tokenActive:(NSDictionary*)tokenActive {
    
    NSNumber* tokenUserId = [tokenActive valueForKey:@"userId"];
    
    for (Project* project in array_projects) {
        for (NSNumber* id_members in [project valueForKey:@"id_members"]) {
            if (tokenUserId == id_members || [tokenUserId stringValue] == [project valueForKey:@"id_creator"]) {
                userHaveProject = true;
            }
        }
    }
    
}

- (void) designPage {
    
    //navigation bar customization
    self.navigationItem.title = [NSString stringWithFormat:@"Connexion"];
    
    UINavigationBar* bar = [self.navigationController navigationBar];
    [bar setHidden:false];
    
    UIImage *cancel = [[UIImage imageNamed:@"error.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:cancel style:UIBarButtonItemStylePlain target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    //border email text field
    CALayer *borderEmail = [CALayer layer];
    CGFloat borderWidthEmail = 1.5;
    borderEmail.borderColor = [UIColor darkGrayColor].CGColor;
    borderEmail.frame = CGRectMake(0, emailTextField.frame.size.height - borderWidthEmail, emailTextField.frame.size.width, emailTextField.frame.size.height);
    borderEmail.borderWidth = borderWidthEmail;
    [emailTextField.layer addSublayer:borderEmail];
    emailTextField.layer.masksToBounds = YES;
    
    //border password text field
    CALayer *borderPwd = [CALayer layer];
    CGFloat borderWidthPwd = 1.5;
    borderPwd.borderColor = [UIColor darkGrayColor].CGColor;
    borderPwd.frame = CGRectMake(0, pwdTextField.frame.size.height - borderWidthPwd, pwdTextField.frame.size.width, pwdTextField.frame.size.height);
    borderPwd.borderWidth = borderWidthPwd;
    [pwdTextField.layer addSublayer:borderPwd];
    pwdTextField.layer.masksToBounds = YES;
    
    
    
}

- (void) cancelButton:(id)sender {
    HomeScreenViewController* homeVc = [[HomeScreenViewController alloc] init];
    [self.navigationController pushViewController:homeVc animated:YES];
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
