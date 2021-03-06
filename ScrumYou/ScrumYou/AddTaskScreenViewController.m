//
//  AddTaskScreenViewController.m
//  ScrumYou
//
//  Created by Bérangère La Touche on 08/03/2017.
//  Copyright © 2017 Bérangère La Touche. All rights reserved.
//

#import "AddTaskScreenViewController.h"
#import "ScrumBoardScreenViewController.h"
#import "UserHomeScreenViewController.h"
#import "ErrorsViewController.h"
#import "APIKeys.h"
#import "CrudUsers.h"
#import "CrudTasks.h"
#import "CrudSprints.h"

@interface AddTaskScreenViewController () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>

- (void) editTask;

@end

@implementation AddTaskScreenViewController {
    ScrumBoardScreenViewController* scrumBoardVC;
    UserHomeScreenViewController* userHomeVC;
    ErrorsViewController* errors;
    
    NSMutableArray<User*>* get_users;
    NSMutableArray<Sprint*>* get_sprints;
    NSMutableArray<User*>* users_in;
    
    NSMutableArray* members;
    NSMutableArray* ids;
    
    NSArray* searchResultsUser;
    NSArray* statusArray;
    
    UIVisualEffectView *blurEffectView;
    
    NSString* statusTask;
    
    NSNumber* ids_sprint;
    NSInteger priority;
    NSInteger nMember;
    NSInteger nMemberTask;
    NSNumber* category;
    
    Task* newTask;
    Sprint* spr;
    
    NSDate* currentDate;
    
    CrudUsers* Users;
    CrudTasks* Tasks;
    CrudSprints* Sprints;
    
    BOOL isModify;
    BOOL sprintChoosen;
}

@synthesize token_dic = _token_dic;
@synthesize id_task = _id_task;
@synthesize taskTitleTextField = _taskTitleTextField;
@synthesize taskDescriptionTextField = _taskDescriptionTextField;
@synthesize taskDifficultyTextField = _taskDifficultyTextField;
@synthesize taskCostTextField = _taskCostTextField;
@synthesize taskDurationTextField = _taskDurationTextField;
@synthesize taskMembersTextField = _taskMembersTextField;
@synthesize taskPriorityTextField = _taskPriorityTextField;
@synthesize prioritySegmentation = _prioritySegmentation;
@synthesize categorySegmentation = _categorySegmentation;
@synthesize status = _status;
@synthesize mTask = _mTask;
@synthesize cProject = _cProject;
@synthesize cSprint = _cSprint;
@synthesize labelTitle = _labelTitle;
@synthesize labelDescription = _labelDescription;
@synthesize labelCost = _labelCost;
@synthesize labelDifficulty = _labelDifficulty;
@synthesize sprintsByProject = _sprintsByProject;
@synthesize editButton = _editButton;
@synthesize editButtonIsHidden = _editButtonIsHidden;

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    if (self != nil) {
        
        Users = [[CrudUsers alloc] init];
        Tasks = [[CrudTasks alloc] init];
        Sprints = [[CrudSprints alloc] init];
        
        errors = [[ErrorsViewController alloc] init];
        
        newTask = [[Task alloc] init];
        spr = [[Sprint alloc] init];
        
        get_users = [[NSMutableArray<User*> alloc] init];
        get_sprints = [[NSMutableArray<Sprint*> alloc] init];
        users_in = [[NSMutableArray<User*> alloc] init];
        
        members = [[NSMutableArray alloc] init];
        ids = [[NSMutableArray alloc] init];
        
        isModify = NO;
        self.editButtonIsHidden = false;
        sprintChoosen = NO;
        self.status = false;
        category = [NSNumber numberWithInt:1];
        statusTask = @"A faire";
        statusArray = @[@"A faire", @"En cours", @"Finies"];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self designPage];
    [self activeRightItem];
    
    membersTableView.delegate = self;
    membersTableView.dataSource = self;
    
    self.taskTitleTextField.delegate = self;
    self.taskDescriptionTextField.delegate = self;
    self.taskDifficultyTextField.delegate = self;
    self.taskDurationTextField.delegate = self;
    self.taskMembersTextField.delegate = self;
    self.taskCostTextField.delegate = self;
    self.taskPriorityTextField.delegate = self;
    
    [self getUsers];
    [self getUserByTask];
    
    pickerStatus.delegate = self;
    pickerStatus.dataSource = self;
    
    pickerSprint.delegate = self;
    pickerSprint.dataSource = self;
    
    buttonValidate.hidden = YES;
    buttonModify.hidden = YES;
    buttonDelete.hidden = YES;
    
    [membersTableView reloadData];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.editButtonIsHidden = NO;
    [self designPage];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.view endEditing:YES];
    return YES;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}


- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    if (thePickerView == pickerStatus) {
        return statusArray.count;
    } else {
        return self.sprintsByProject.count;
    }
}


- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (thePickerView == pickerStatus) {
        return [statusArray objectAtIndex:row];
    } else {
        spr = [self.sprintsByProject objectAtIndex:0];
        return [[self.sprintsByProject objectAtIndex:row] valueForKey:@"title"];
    }
}


- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (thePickerView == pickerStatus) {
        statusTask = [statusArray objectAtIndex:row];
    } else {
        spr = [self.sprintsByProject objectAtIndex:row];
    }
    
}


/**
 * \fn (void)showSprintView
 * \brief Show sprint view.
 * \details Function which allows to show sprint view.
 */
- (void)showSprintView {
    [sprintView setHidden:false];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    
    [self.view insertSubview:blurEffectView belowSubview:sprintView];
}

/**
 * \fn (IBAction)closeWindowSprint:(id)sender
 * \brief Close window sprint button.
 * \details Allows to close window sprint when clicking on it.
 */
- (IBAction)closeWindowSprint:(id)sender {
    [sprintView setHidden:true];
    [blurEffectView removeFromSuperview];
}

/**
 * \fn (IBAction)validateSprint:(id)sender
 * \brief Validate sprint button.
 * \details Allows to link modified task or added task to the sprint and remove task if sprint is different from the initial sprint.Then, update it.
 */
- (IBAction)validateSprint:(id)sender {
    
    NSString* token = [self.token_dic valueForKey:@"token"];
    NSMutableArray* list_task = [[NSMutableArray alloc] init];
    NSMutableArray* list_tasksCurrentSprint = [[NSMutableArray alloc] initWithArray:self.cSprint.id_listTasks];
    
    if (spr.id_sprint != self.cSprint.id_sprint && self.cSprint.id_sprint != nil) {
        for (int i = 0; i < self.cSprint.id_listTasks.count ; i++) {
            if (self.cSprint.id_listTasks[i] == self.id_task) {
                [list_tasksCurrentSprint removeObjectAtIndex:i];
            }
        }
        [Sprints updateSprintId:[NSString stringWithFormat:@"%@", self.cSprint.id_sprint] title:self.cSprint.title beginningDate:self.cSprint.beginningDate endDate:self.cSprint.endDate id_listTasks:list_tasksCurrentSprint token:token callback:^(NSError *error, BOOL success) {
            if (success) {
            }
        }];
    }

    
    if (![spr.id_listTasks isKindOfClass:[NSNull class]]) {
        list_task = [[NSMutableArray alloc] initWithArray: spr.id_listTasks];
        
        for (int i = 0; i < list_task.count; i++) {
            if (list_task[i] == newTask.id_task) {
                [list_task removeObjectAtIndex:i];
            }
        }
    }
    
    [list_task addObject:newTask.id_task];
    spr.id_listTasks = list_task;
    
    NSString* id_sprint = [NSString stringWithFormat:@"%@", spr.id_sprint];
    NSString* title = spr.title;
    NSString* beginning_date = spr.beginningDate;
    NSString* end_date = spr.endDate;
    
    [Sprints updateSprintId:id_sprint title:title beginningDate:beginning_date endDate:end_date id_listTasks:list_task token:token callback:^(NSError *error, BOOL success) {
        if (success) {
        }
    }];
    
    userHomeVC = [[UserHomeScreenViewController alloc] init];
    scrumBoardVC.id_project = [NSString stringWithFormat:@"%@", self.cProject.id_project];
    scrumBoardVC.token = self.token_dic;
    
    [self.navigationController pushViewController:scrumBoardVC animated:YES];
    
}

/**
 * \fn (IBAction)updateTask:(id)sender
 * \brief Update task button.
 * \details Allows to update task, to know if it's finished or not to get the end date, and redirect to the scrumboard.
 */
- (IBAction)updateTask:(id)sender {
    
    NSString* token = [self.token_dic valueForKey:@"token"];
    
    NSString* current_dateString;
    
    [self getIdUser];
    
    newTask.id_task = self.id_task;
    
    if ([statusTask isEqualToString:@"Finies"]) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"dd/MM/yyyy"];
        currentDate = [NSDate date];
        current_dateString = [formatter stringFromDate:currentDate];
    } else {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"00-00-0000"];
        currentDate = [NSDate date];
        current_dateString = [formatter stringFromDate:currentDate];
    }
    
    [Tasks updateTaskId:[NSString stringWithFormat:@"%@", self.id_task] title:self.taskTitleTextField.text description:self.taskDescriptionTextField.text difficulty:self.taskDifficultyTextField.text priority:[NSNumber numberWithInteger:priority] id_category:category businessValue:self.taskCostTextField.text duration:self.taskDurationTextField.text status:statusTask id_members:ids taskDone:current_dateString token:token callback:^(NSError *error, BOOL success) {
        if (success) {
            if ([Tasks.dict_error valueForKey:@"type"] != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [errors bddErrorsTitle:[Tasks.dict_error valueForKey:@"title"] message:[Tasks.dict_error valueForKey:@"message"] viewController:self];
                });
                    
            } else {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Modification réussie" message:@"Votre tâche a été modifiée." preferredStyle:UIAlertControllerStyleAlert];
                        
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        [self showSprintView];
                        scrumBoardVC = [[ScrumBoardScreenViewController alloc] init];
                        scrumBoardVC.comeUpdateTask = true;
                    }];
                        
                    [alert addAction:defaultAction];
                    [self presentViewController:alert animated:YES completion:nil];
                        
                });
                
            }
        }
    }];
    
}

/**
 * \fn (IBAction)validateNewTask:(id)sender
 * \brief Add task button.
 * \details Allows to add task and redirect to the scrumboard.
 */
- (IBAction)validateNewTask:(id)sender {
    __unsafe_unretained typeof(self) weakSelf = self;
    
    NSString* token = [self.token_dic valueForKey:@"token"];
    
    NSLog(@"category %@", category);
    
    [Tasks addTaskTitle:self.taskTitleTextField.text description:self.taskDescriptionTextField.text difficulty:self.taskDifficultyTextField.text priority:priority id_category:category businessValue:self.taskCostTextField.text duration:self.taskDurationTextField.text status:statusTask id_members:ids token:token callback:^(NSError *error, BOOL success) {
        if (success) {
            if ([Tasks.dict_error valueForKey:@"type"] != nil) {

                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf->errors bddErrorsTitle:[weakSelf->Tasks.dict_error valueForKey:@"title"] message:[weakSelf->Tasks.dict_error valueForKey:@"message"] viewController:weakSelf];
                });
                
            } else {
                newTask = Tasks.task;
                weakSelf->_id_task = newTask.id_task;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Création réussie" message:@"Votre tâche a été créée." preferredStyle:UIAlertControllerStyleAlert];
                    
                    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                        [weakSelf showSprintView];
                        scrumBoardVC = [[ScrumBoardScreenViewController alloc] init];
                        weakSelf->scrumBoardVC.comeAddTask = true;
                        
                    }];
                    
                    [alert addAction:defaultAction];
                    [weakSelf presentViewController:alert animated:YES completion:nil];
                    
                });
            }
        }
    }];
    
    self.taskTitleTextField.text = @"";
    self.taskDescriptionTextField.text = @"";
    self.taskDifficultyTextField.text = @"";
    self.taskMembersTextField.text = @"";
    self.taskCostTextField.text = @"";
    self.taskDurationTextField.text = @"";
    [self.categorySegmentation setSelectedSegmentIndex:0];
    [self.prioritySegmentation setSelectedSegmentIndex:0];
}

/**
 * \fn (IBAction)deleteTask:(id)sender
 * \brief Delete task button.
 * \details Allows to delete task and redirect to the scrumboard.
 */
- (IBAction)deleteTask:(id)sender {
    
    NSString* token = [self.token_dic valueForKey:@"token"];
    
    newTask.id_task = self.id_task;
    
    NSLog(@"SPR %@", self.cSprint.id_sprint);
    
    [Tasks deleteTaskWithId:[NSString stringWithFormat:@"%@", newTask.id_task] andIdSprint:[NSString stringWithFormat:@"%@", self.cSprint.id_sprint] token:token callback:^(NSError *error, BOOL success) {
        if (success) {
            NSLog(@"DELETE TASK SUCCESS");

            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Supression réussie" message:@"Votre tâche a été supprimée." preferredStyle:UIAlertControllerStyleAlert];
                    
                UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    scrumBoardVC = [[ScrumBoardScreenViewController alloc] init];
                    scrumBoardVC.id_project = [NSString stringWithFormat:@"%@", self.cProject.id_project];
                    scrumBoardVC.comeDeleteTask = true;
                    scrumBoardVC.token = _token_dic;
                    [self.navigationController pushViewController:scrumBoardVC animated:YES];
                        
                }];
                    
                [alert addAction:defaultAction];
                [self presentViewController:alert animated:YES completion:nil];
                    
            });
        }
    }];
    
}

/**
 * \fn (IBAction)showAddMembersView:(id)sender
 * \brief Show add members view button.
 * \details Allows to show add members view.
 */
- (IBAction)showAddMembersView:(id)sender {
    [membersView setHidden:false];
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    
    [self.view insertSubview:blurEffectView belowSubview:membersView];
}

/**
 * \fn (void) getUsername
 * \brief Get users names.
 * \details Allows to get users names.
 */
- (void) getUsername {
    get_users = Users.userList;
    [membersTableView reloadData];
}

/**
 * \fn (void) getUsers
 * \brief Get users.
 * \details Allows to get users.
 */
- (void) getUsers {
    [Users getUsers:^(NSError *error, BOOL success) {
        if (success) {
            get_users = Users.userList;
            [membersTableView reloadData];
        }
    }];
}

/**
 * \fn (void) getUserByTask
 * \brief Get users by tasks.
 * \details Allows to get users by tasks.
 */
- (void) getUserByTask {
    
    for (NSNumber* membersArray in self.mTask.id_members) {
        NSString* result = [NSString stringWithFormat:@"%@",membersArray];
        [Users getUserById:result callback:^(NSError *error, BOOL success) {
            if (success) {
                [users_in addObject:Users.user];
                nMemberTask = users_in.count;
                self.taskMembersTextField.text = [@(nMemberTask)stringValue];
            }
            [membersTableView reloadData];
        }];
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(self.searchController.isActive) {
        return searchResultsUser.count;
    }else {
        return [get_users count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString* const kCellId = @"cell";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellId];
    }
    
    User* username;
    if(self.searchController.isActive) {
        username = [searchResultsUser objectAtIndex:indexPath.row];
    }else {
        username = [get_users objectAtIndex:indexPath.row];
    }
    
    for (User* user in users_in) {
        if ([user.fullname isEqualToString:[get_users objectAtIndex:indexPath.row].fullname]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", username.fullname];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            nMember+=1;
            [members addObject:user.fullname];
        }else {
            cell.textLabel.text = [NSString stringWithFormat:@"%@", username.fullname];
        }
        
    }
    
    cell.textLabel.text = username.fullname;
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [membersTableView cellForRowAtIndexPath:indexPath];
    if (cell.accessoryType) {
        cell.accessoryType = NO;
        [members removeObject:cell.textLabel.text];
        nMember-=1;
    } else {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [members addObject:cell.textLabel.text];
        nMember+=1;
    }
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [membersTableView reloadData];
}


/**
 * \fn (void)searchForText:(NSString*)searchText
 * \brief Search text which corresponds to cells title.
 * \details Allows to search the text written in the search bar in order to find a cell by title.
 * \param searchText String written in the search bar.
 */
- (void)searchForText:(NSString*)searchText {
    NSPredicate *predicateUser = [NSPredicate predicateWithFormat:@"fullname contains[c] %@ OR nickname contains[c] %@", searchText, searchText];
    searchResultsUser = [get_users filteredArrayUsingPredicate:predicateUser];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self updateSearchResultsForSearchController:self.searchController];
}


/**
 * \fn (void) getIdUser
 * \brief Get user to add in the task.
 * \details Allows to get the ids of each users selected in table view to add in the task.
 */
- (void) getIdUser {
    [ids removeAllObjects];
    for (NSString* name in members) {
        for (User* user in get_users) {
            if ([name isEqualToString:[user valueForKey:@"fullname"]]) {
                NSString* uId = [user valueForKey:@"id_user"];
                if ([self cleanOccurrences:uId] == false) {
                    [ids addObject:uId];
                }
            }
        }
    }
}

/**
 * \fn (BOOL) cleanOccurrences:(NSString*)key
 * \brief Check the occurrences of ids array.
 * \details Allows to check the occurrences of the ids array contains each users of the task.
 */
- (BOOL) cleanOccurrences:(NSString*)key {
    for (NSString* keys in ids) {
        if (keys == key) {
            return true;
        }
    }
    return false;
}

/**
 * \fn (IBAction)validateMembers:(id)sender
 * \brief Validate each users selected.
 * \details Allows to validate each users selected in members table view to add in the task.
 */
- (IBAction)validateMembers:(id)sender {
    [membersView setHidden:true];
    [blurEffectView removeFromSuperview];
    self.taskMembersTextField.text = [@(nMember)stringValue];
    if(self.searchController.isActive) {
        [self.searchController setActive:NO];
    }
    [self getIdUser];
}

/**
 * \fn (IBAction)closeWindowMembers:(id)sender
 * \brief Close members window.
 * \details Allows to close the members window.
 */
- (IBAction)closeWindowMembers:(id)sender {
    [membersView setHidden:true];
    [blurEffectView removeFromSuperview];
    if(self.searchController.isActive) {
        [self.searchController setActive:NO];
    }
}


/**
 * \fn (IBAction)priorityChanged:(UISegmentedControl *)sender
 * \brief Get current value of Segmented Control priority.
 * \details Allows to get the selected value of the segmented control priority.
 */
- (IBAction)priorityChanged:(UISegmentedControl *)sender {
    priority = [sender selectedSegmentIndex] + 1;
}


/**
 * \fn (IBAction)categoryChanged:(UISegmentedControl *)sender
 * \brief Get current value of Segmented Control category.
 * \details Allows to get the selected value of the segmented control category.
 */
- (IBAction)categoryChanged:(UISegmentedControl *)sender {
    NSInteger value = [sender selectedSegmentIndex] + 1;
    category = [NSNumber numberWithInteger:[sender selectedSegmentIndex] + 1];
}


/**
 * \fn (IBAction)stepperAction:(UIStepper*)sender
 * \brief Get current value of Stepper duration.
 * \details Allows to get the selected value of the stepper duration.
 */
- (IBAction)stepperAction:(UIStepper*)sender {
    NSUInteger value = sender.value;
    self.taskDurationTextField.text = [NSString stringWithFormat:@"%02lu", (unsigned long)value];
}

/**
 * \fn (void) designPage
 * \brief Design current view controller.
 * \details Allows to put different design on component of current view controller.
 */
- (void) designPage {
    
    //navigation bar customization
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60) forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.14 green:0.22 blue:0.27 alpha:1.0];

    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.14 green:0.21 blue:0.27 alpha:1.0];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    membersTableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    [self.searchController.searchBar setBarTintColor:[UIColor whiteColor]];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    
    if (self.status == 0) {
        self.navigationItem.title = @"Ajouter une tâche";
        buttonValidate.hidden = NO;
        buttonModify.hidden = YES;
        buttonDelete.hidden = YES;
        
    } else {
        self.navigationItem.title = self.mTask.title;
        
        buttonModify.hidden = YES;
        buttonDelete.hidden = YES;
        
        self.taskTitleTextField.enabled = false;
        self.taskCostTextField.enabled = false;
        self.taskDurationTextField.enabled = false;
        self.taskDifficultyTextField.enabled = false;
        self.prioritySegmentation.enabled = false;
        self.categorySegmentation.enabled = false;
        self.taskDescriptionTextField.enabled = false;
        self.taskMembersTextField.enabled = false;
        buttonMembersView.enabled = false;
        pickerStatus.userInteractionEnabled = false;
        stepperDuration.enabled = false;
        
        self.id_task = self.mTask.id_task;
        self.taskTitleTextField.text = self.mTask.title;
        self.taskDescriptionTextField.text = self.mTask.description;
        self.taskDifficultyTextField.text = [NSString stringWithFormat:@"%@",self.mTask.difficulty];
        self.taskMembersTextField.text = [NSString stringWithFormat:@"%ld", self.mTask.id_members.count];
        self.taskCostTextField.text = [NSString stringWithFormat:@"%@" ,self.mTask.businessValue];
        self.taskDurationTextField.text = [NSString stringWithFormat:@"%@",self.mTask.duration];
        [self.categorySegmentation setSelectedSegmentIndex:[self.mTask.id_category integerValue]-1];
        [self.prioritySegmentation setSelectedSegmentIndex:[self.mTask.priority integerValue]-1];
    }
    
    //border taskTitle text field
    CALayer *borderTaskTitle = [CALayer layer];
    CGFloat borderWidthTaskTitle = 1;
    borderTaskTitle.borderColor = [UIColor darkGrayColor].CGColor;
    borderTaskTitle.frame = CGRectMake(0, self.labelTitle.frame.size.height - borderWidthTaskTitle, self.labelTitle.frame.size.width, self.labelTitle.frame.size.height);
    borderTaskTitle.borderWidth = borderWidthTaskTitle;
    [self.labelTitle.layer addSublayer:borderTaskTitle];
    self.labelTitle.layer.masksToBounds = YES;
    
    //border taskDescription text field
    CALayer *borderTaskDescription = [CALayer layer];
    CGFloat borderWidthTaskDescription = 1;
    borderTaskDescription.borderColor = [UIColor darkGrayColor].CGColor;
    borderTaskDescription.frame = CGRectMake(0, self.labelDescription.frame.size.height - borderWidthTaskDescription, self.labelDescription.frame.size.width, self.labelDescription.frame.size.height);
    borderTaskDescription.borderWidth = borderWidthTaskDescription;
    [self.labelDescription.layer addSublayer:borderTaskDescription];
    self.labelDescription.layer.masksToBounds = YES;
    
    //border taskDifficulty text field
    CALayer *borderTaskDifficulty = [CALayer layer];
    CGFloat borderWidthTaskDifficulty = 1;
    borderTaskDifficulty.borderColor = [UIColor darkGrayColor].CGColor;
    borderTaskDifficulty.frame = CGRectMake(0, self.labelDifficulty.frame.size.height - borderWidthTaskDifficulty, self.labelDifficulty.frame.size.width, self.labelDifficulty.frame.size.height);
    borderTaskDifficulty.borderWidth = borderWidthTaskDifficulty;
    [self.labelDifficulty.layer addSublayer:borderTaskDifficulty];
    self.labelDifficulty.layer.masksToBounds = YES;
    
    //border taskCost text field
    CALayer *borderTaskCost = [CALayer layer];
    CGFloat borderWidthTaskCost = 1;
    borderTaskCost.borderColor = [UIColor darkGrayColor].CGColor;
    borderTaskCost.frame = CGRectMake(0, self.labelCost.frame.size.height - borderWidthTaskCost, self.labelCost.frame.size.width, self.labelCost.frame.size.height);
    borderTaskCost.borderWidth = borderWidthTaskCost;
    [self.labelCost.layer addSublayer:borderTaskCost];
    self.labelCost.layer.masksToBounds = YES;
    
    //border radius member view
    membersView.layer.cornerRadius = 2.0;
    
}

/**
 * \fn (void) activeRightItem
 * \brief Activation of right item of navigation bar.
 * \details Allows to activate or not the right button item in the navigation bar allow to modify a task.
 */
- (void) activeRightItem {
    if (self.editButtonIsHidden == false) {
        UIBarButtonItem* editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(editTask)];
        editButton.tintColor = [UIColor colorWithRed:0.14 green:0.22 blue:0.27 alpha:1.0];
        self.navigationItem.rightBarButtonItem = editButton;
    } else {
        self.navigationItem.rightBarButtonItem = nil;
        self.editButtonIsHidden = false;
    }
}

/**
 * \fn (void) editTask
 * \brief Make the textfields enabled.
 * \details Allows to make all text enabled when user clicked on modify button.
 */
- (void) editTask {
    buttonModify.hidden = NO;
    buttonDelete.hidden = NO;
    
    self.taskTitleTextField.enabled = true;
    self.taskCostTextField.enabled = true;
    self.taskDurationTextField.enabled = true;
    self.taskDifficultyTextField.enabled = true;
    self.prioritySegmentation.enabled = true;
    self.categorySegmentation.enabled = true;
    self.taskDescriptionTextField.enabled = true;
    self.taskMembersTextField.enabled = true;
    buttonMembersView.enabled = true;
    pickerStatus.userInteractionEnabled = true;
    stepperDuration.enabled = true;
    
    self.status = 0;
}


/**
 * \fn (void) cancelButton:(id)sender
 * \brief Cancel button.
 * \details Allows to back to the scrum board view controller when user click on it.
 */
- (void) cancelButton:(id)sender {
    ScrumBoardScreenViewController* UserVc = [[ScrumBoardScreenViewController alloc] init];
    [self.navigationController pushViewController:UserVc animated:YES];
}

@end
