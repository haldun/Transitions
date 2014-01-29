//
//  CatsViewController.m
//  Transitions
//
//  Created by Haldun Bayhantopcu on 29/01/14.
//  Copyright (c) 2014 Monoid. All rights reserved.
//

#import "CatsViewController.h"
#import "Cat.h"
#import "DataModelHelper.h"
#import "CatDetailViewController.h"
#import "AboutViewController.h"
#import "BouncePresentTransition.h"
#import "ShrinkDismissTransition.h"
#import "FlipTransition.h"

static NSString * const kShowCatDetailSegueIdentifier = @"ShowCatDetail";
static NSString * const kShowAboutSegueIdentifier = @"ShowAbout";

@interface CatsViewController () <NSFetchedResultsControllerDelegate,
                                  UIViewControllerTransitioningDelegate,
                                  UINavigationControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) id observer;
@property (strong, nonatomic) BouncePresentTransition *bouncePresentTransition;
@property (strong, nonatomic) ShrinkDismissTransition *shrinkDismissTransition;
@property (strong, nonatomic) FlipTransition *flipTransition;

@end

@implementation CatsViewController

- (NSFetchedResultsController *)fetchedResultsController
{
  if (!_fetchedResultsController) {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Cat"];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    
    NSManagedObjectContext *context = [DataModelHelper sharedHelper].mainObjectContext;
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                    managedObjectContext:context
                                                                      sectionNameKeyPath:nil
                                                                               cacheName:nil];
    _fetchedResultsController.delegate = self;
  }
  return _fetchedResultsController;
}

- (BouncePresentTransition *)bouncePresentTransition
{
  if (!_bouncePresentTransition) {
    _bouncePresentTransition = [[BouncePresentTransition alloc] init];
  }
  return _bouncePresentTransition;
}

- (ShrinkDismissTransition *)shrinkDismissTransition
{
  if (!_shrinkDismissTransition) {
    _shrinkDismissTransition = [[ShrinkDismissTransition alloc] init];
  }
  return _shrinkDismissTransition;
}

- (FlipTransition *)flipTransition
{
  if (!_flipTransition) {
    _flipTransition = [[FlipTransition alloc] init];
  }
  return _flipTransition;
}

#pragma mark - View controller life cycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  NSError *error = nil;
  if (![self.fetchedResultsController performFetch:&error]) {
    NSLog(@"Error: %@", error);
  }
  
  self.navigationController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  self.observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:
    ^(NSNotification *note) {
      [self.fetchedResultsController.managedObjectContext mergeChangesFromContextDidSaveNotification:note];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self.observer];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
  switch (type) {
    case NSFetchedResultsChangeInsert:
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
      
    case NSFetchedResultsChangeDelete:
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
    
    case NSFetchedResultsChangeMove:
      [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
      break;
    
    case NSFetchedResultsChangeUpdate:
      [self configureCell:[self.tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
      break;
  }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
  [self.tableView endUpdates];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
  Cat *cat = [self.fetchedResultsController objectAtIndexPath:indexPath];
  cell.textLabel.text = cat.name;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return [self.fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
  return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"CatCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (IBAction)addACat:(id)sender
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    context.persistentStoreCoordinator = [DataModelHelper sharedHelper].persistentStoreCoordinator;
    
    Cat *cat = [NSEntityDescription insertNewObjectForEntityForName:@"Cat" inManagedObjectContext:context];
    cat.name = @"Garfield";
    cat.catDescription = @"Cok mukemmel bir kedi kendisi";
    cat.age = @3;
    
    NSError *error = nil;
    if (![context save:&error]) {
      NSLog(@"cannot insert a new cat: %@", error);
    }
  });
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
  if ([segue.identifier isEqualToString:kShowCatDetailSegueIdentifier]) {
    if ([segue.destinationViewController isKindOfClass:[CatDetailViewController class]]) {
      CatDetailViewController *detailViewController = segue.destinationViewController;
      detailViewController.cat = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
  } else if ([segue.identifier isEqualToString:kShowAboutSegueIdentifier]) {
    if ([segue.destinationViewController isKindOfClass:[AboutViewController class]]) {
      AboutViewController *aboutViewController = segue.destinationViewController;
      aboutViewController.transitioningDelegate = self;
    }
  }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
  return self.bouncePresentTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
  return self.shrinkDismissTransition;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC
{
  self.flipTransition.reverse = operation == UINavigationControllerOperationPop;
  return self.flipTransition;
}

@end
