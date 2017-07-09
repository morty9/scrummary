//
//  ScrumBoardScreenViewController.m
//  ScrumYou
//
//  Created by Bérangère La Touche on 08/03/2017.
//  Copyright © 2017 Bérangère La Touche. All rights reserved.
//

#import "ScrumBoardScreenViewController.h"
#import "PageContentViewController.h"
#import "PageViewController.h"
#import "CrudTasks.h"
#import "Task.h"
#import "Sprint.h"
#import "Project.h"
#import "CrudProjects.h"

@interface ScrumBoardScreenViewController () <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;

@end

@implementation ScrumBoardScreenViewController {
    
    CrudTasks* TasksCrud;
    CrudProjects* ProjectsCrud;
    
    NSMutableArray<Task*>* get_tasks;
    NSMutableArray<Sprint*>* get_sprints;
    Project* project;
    
}

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self != nil) {
        
        TasksCrud = [[CrudTasks alloc] init];
        ProjectsCrud = [[CrudProjects alloc] init];
        
        get_tasks = [[NSMutableArray<Task*> alloc] init];
        get_sprints = [[NSMutableArray<Sprint*> alloc] init];
        project = [[Project alloc] init];
        
        [ProjectsCrud getProjectById:@"54" callback:^(NSError *error, BOOL success) {
            if (success) {
                NSLog(@"GET PROJECT BY ID SUCCESS");
            }
        }];
        
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self designPage];
    
    _pageTitles = @[@"Over 200 Tips and Tricks", @"Discover Hidden Features", @"Bookmark Favorite Tip", @"Free Regular Update"];
    
    // Create page view controllerinstantiateViewControllerWithIdentifier:@"PageViewController"];
    self.pageViewController = [[PageViewController alloc] initWithNibName:@"PageViewController" bundle:nil];
    self.pageViewController.dataSource = self;
    
    PageContentViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageViewController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageViewController.view.frame = CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 75);
    
    [self addChildViewController:_pageViewController];
    [self.view addSubview:_pageViewController.view];
    [self.pageViewController didMoveToParentViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) designPage {
    
    self.navigationItem.title = [NSString stringWithFormat:@"Projet NAME"];
}

#pragma mark - Page View Controller Data Source

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((PageContentViewController*) viewController).pageIndex;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.pageTitles count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (PageContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.pageTitles count] == 0) || (index >= [self.pageTitles count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    PageContentViewController *pageContentViewController = [[PageContentViewController alloc] initWithNibName:@"PageContentViewController" bundle:nil];
    pageContentViewController.txtTitle = self.pageTitles[index];
    pageContentViewController.pageIndex = index;
    
    return pageContentViewController;
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.pageTitles count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
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
