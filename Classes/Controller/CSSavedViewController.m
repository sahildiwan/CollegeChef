//
//  CSSavedViewController.m
//  CollegeChef
//
//  Created by Sahil Diwan.
//

#import "CSSavedViewController.h"

#import "Recipe.h"
#import "Ingredients.h"
#import "Picture.h"

#import "CSDetailsViewController.h"

#import "CSCoreDataService.h"

@interface CSSavedViewController () <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>
@property(nonatomic, weak) IBOutlet UITableView* recipeItemListTable;
@property(nonatomic, weak) IBOutlet UIBarButtonItem* doneButton;
@property(nonatomic, weak) IBOutlet UIBarButtonItem* editButton;
@end

@implementation CSSavedViewController {
    Recipe* _selectedRecipe;
    
    NSFetchedResultsController* _recipeItemsResultsController;
    BOOL _horizontalSwipeEditMode;
}

#pragma mark IBActions
- (IBAction)done:(id)sender {
	[_recipeItemListTable setEditing:NO animated:YES];
	_horizontalSwipeEditMode = NO;
	
	[self.navigationItem setRightBarButtonItem:_editButton animated:YES];
}

- (IBAction)edit:(id)sender {
	[_recipeItemListTable setEditing:YES animated:YES];
	
	[self.navigationItem setRightBarButtonItem:_doneButton animated:YES];
}

#pragma mark Public
- (void)setSelectedRecipe:(Recipe*)selectedRecipeItem {
	_selectedRecipe = selectedRecipeItem;
	
	self.navigationItem.title = _selectedRecipe.name;
	
	[self _refreshFetchedResultsController];
	[_recipeItemListTable reloadData];
}

#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[_recipeItemsResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInformation = [[_recipeItemsResultsController sections] objectAtIndex:section];
	return [sectionInformation numberOfObjects];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"RecipeItemCell" forIndexPath:indexPath];
	
    if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"RecipeItemCell"];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
	}
    
	[self _updateCell:cell forRecipeItem:[_recipeItemsResultsController objectAtIndexPath:indexPath]];
	
	return cell;
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	NSManagedObjectContext* context = [CSCoreDataService sharedCoreDataService].mainQueueContext;
    
	if(editingStyle == UITableViewCellEditingStyleDelete) {
		Recipe* recipe = [_recipeItemsResultsController objectAtIndexPath:indexPath];
		[context deleteObject:recipe];
        
        [[CSCoreDataService sharedCoreDataService] saveMainQueueContextWithCompletionHandler:^(BOOL success) {
            if(success) {
                NSLog(@"Update to SavedView was successful!");
            }
            else {
                NSLog(@"Update to SavedView failed :^(");
            }
        }];
	}
}

#pragma mark NSFetchedResultsControllerDelegate
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
	[_recipeItemListTable beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
	if(type == NSFetchedResultsChangeDelete) {
		[_recipeItemListTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	if(type == NSFetchedResultsChangeDelete) {
		[_recipeItemListTable deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationLeft];
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[_recipeItemListTable endUpdates];
}

#pragma mark Private (UI)
- (void)_updateCell:(UITableViewCell*)cell forRecipeItem:(Recipe*)recipe {
    cell.textLabel.text = recipe.name;
}

#pragma mark Private (Object Management)
- (void)_refreshFetchedResultsController {
	NSManagedObjectContext* context = [CSCoreDataService sharedCoreDataService].mainQueueContext;
    
	_recipeItemsResultsController = nil;
	
	NSFetchRequest* recipeFetchRequest = [[NSFetchRequest alloc] init];
	recipeFetchRequest.entity = [NSEntityDescription entityForName:@"Recipe" inManagedObjectContext:context];
	recipeFetchRequest.fetchBatchSize = 12;
	recipeFetchRequest.includesPendingChanges = NO;
    recipeFetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
	_recipeItemsResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:recipeFetchRequest managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
	
	_recipeItemsResultsController.delegate = self;
    NSError* error = nil;
    if(![_recipeItemsResultsController performFetch:&error]) {
        NSLog(@"Error performing saved recipe fetch %@", error);
    }
}

#pragma mark View Life Cycle
- (void)viewDidLoad {
    self.navigationItem.rightBarButtonItem = _editButton;
    if(_recipeItemsResultsController == nil) {
        [self _refreshFetchedResultsController];
        
        [_recipeItemListTable reloadData];
    }
    [_recipeItemListTable reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if([segue.identifier isEqualToString:@"RecipeDetailsSegue"]) {
		NSIndexPath* indexPath = [_recipeItemListTable indexPathForSelectedRow];
		[_recipeItemListTable deselectRowAtIndexPath:indexPath animated:YES];
		
        Recipe* recipe = [_recipeItemsResultsController objectAtIndexPath:indexPath];
		CSDetailsViewController* recipeDetailViewController = segue.destinationViewController;
		//recipeDetailViewController.delegate = self;
		[recipeDetailViewController setSelectedRecipe:recipe];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
