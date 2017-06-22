//
//  ProjectSettingsScreenViewController.h
//  ScrumYou
//
//  Created by Bérangère La Touche on 08/03/2017.
//  Copyright © 2017 Bérangère La Touche. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectSettingsScreenViewController : UIViewController {
    
    __weak IBOutlet UITextField *nameTextField;
    __weak IBOutlet UITableView *membersTableView;
    __weak IBOutlet UIPickerView *pickerView;
    
    __weak IBOutlet UIButton *editButtonMembers;
}

- (void) editProject;

- (void) editMembers;

- (void) cancelButton;

@end
