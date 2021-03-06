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
#import "ErrorsViewController.h"

@interface LoginScreenViewController () <UITextFieldDelegate>

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
    ErrorsViewController* errors;

}

@synthesize token = _token;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        
        ProjectsCrud = [[CrudProjects alloc] init];
        
        errors = [[ErrorsViewController alloc] init];
        
        get_project = [[NSMutableArray<Project*> alloc] init];
        userHaveProject = false;
        
        [ProjectsCrud getProjects:^(NSError *error, BOOL success) {
            if (success) {
                get_project = ProjectsCrud.projects_list;
            }
        }];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self designPage];
    
    emailTextField.delegate = self;
    pwdTextField.delegate = self;
    
    Auth = [[CrudAuth alloc] init];
    addProjectVC = [[AddProjectScreenViewController alloc] init];
    accountSettings = [[AccountSettingsScreenViewController alloc] init];
    userHomeVC = [[UserHomeScreenViewController alloc] init];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}


/**
 * \brief Connection button.
 * \details Redirect to the user homepage if user has projects or to the add project page if not, when clicking on it.
 */
- (IBAction)connectionButton:(id)sender {
    
    [Auth login:emailTextField.text password:pwdTextField.text callback:^(NSError *error, BOOL success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                if ([Auth.dict_error valueForKey:@"type"] != nil) {
                    [errors bddErrorsTitle:[Auth.dict_error valueForKey:@"title"] message:[Auth.dict_error valueForKey:@"message"] viewController:self];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        addProjectVC.token_dic = Auth.token;
                        userHomeVC.token = Auth.token;
                        
                        [self checkIfMemberHaveProject:get_project tokenActive:Auth.token];
                        
                        if (userHaveProject == true) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.navigationController pushViewController:userHomeVC animated:YES];
                            });
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.navigationController pushViewController:addProjectVC animated:YES];
                            });
                        }
                    });
                }
            }

        });
    
    }];
}

/**
 * \brief Check user projects.
 * \details Function which checks if users have projects with their token.
 * \param array_projects Array of projects.
 * \param tokenActive Token of the connected user.
 */
- (void) checkIfMemberHaveProject:(NSArray*)array_projects tokenActive:(NSDictionary*)tokenActive {
    
    NSNumber* tokenUserId = [tokenActive valueForKey:@"userId"];
    
    for (Project* project in array_projects) {
        for (NSNumber* id_members in [project valueForKey:@"id_members"]) {
            if (tokenUserId == id_members || tokenUserId == [project valueForKey:@"id_creator"]) {
                userHaveProject = true;
            }
        }
    }
    
}

- (void) designPage {
    
    //navigation bar customization
    self.navigationItem.title = [NSString stringWithFormat:@"Connexion"];
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.14 green:0.22 blue:0.27 alpha:1.0];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor colorWithRed:0.14 green:0.22 blue:0.27 alpha:1.0] forKey:NSForegroundColorAttributeName];
    
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


@end
