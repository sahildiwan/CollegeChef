//
//  CSSearchViewController.m
//  CollegeChef
//
//  Created by Sahil Diwan.
//

#import "CSSearchViewController.h"

#import "CSTextFieldCell.h"
#import "CSFoundViewController.h"

#import "TFHpple.h"
#import "CSHTMLParsing.h"

@interface CSSearchViewController ()
@end

@implementation CSSearchViewController {
    BOOL _horizontalSwipeEditMode;
}

- (void)insertNewObject:(id)sender {
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:@"" atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_objects.count - 1 inSection:0];
    [self.ingredientsTable insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)reloadTableView:(id)sender {
    [_ingredientsTable reloadData];
}

#pragma mark IBActions
- (IBAction)done:(id)sender {
	[_ingredientsTable setEditing:NO animated:YES];
	_horizontalSwipeEditMode = NO;
	[self.navigationItem setLeftBarButtonItem:_editButton animated:YES];
}

- (IBAction)edit:(id)sender {
	[_ingredientsTable setEditing:YES animated:YES];
	[self.navigationItem setLeftBarButtonItem:_doneButton animated:YES];
}

- (IBAction)recipeSearchScrape:(id)sender {
    if([_textCells count] > 2) { // TO TEST CREATE 3 CELLS WITH CONTENTS: Chicken, Rice, Eggs
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSString* manipulatedUrl = [NSString stringWithFormat:@"http://allrecipes.com/search/default.aspx?qt=i&rt=r&origin=Home+Page&pqt=k&ms=0&fo=0&w0=%@&w1=%@&w2=%@&vm=l&p34=SR_ListView", ((CSTextFieldCell*)[_textCells objectAtIndex:0]).ingredientTextField.text, ((CSTextFieldCell*)[_textCells objectAtIndex:1]).ingredientTextField.text, ((CSTextFieldCell*)[_textCells objectAtIndex:2]).ingredientTextField.text];
            
            NSLog(@"Manipulate landing URL with user input. Result: %@ \r \r", manipulatedUrl);
            
            NSURL* searchUrl = [NSURL URLWithString:manipulatedUrl];
            NSData* searchHtmlData = [NSData dataWithContentsOfURL:searchUrl];
            
            TFHpple* recipesParser = [TFHpple hppleWithHTMLData:searchHtmlData];
            
            NSString* recipesXpathQueryString = @"//div[@class='searchImg_result']/a";
            NSArray* recipesNodes = [recipesParser searchWithXPathQuery:recipesXpathQueryString];
            
            NSMutableArray* newRecipes = [[NSMutableArray alloc] initWithCapacity:0];
            for (TFHppleElement* element in recipesNodes) {
                CSHTMLParsing* recipe = [[CSHTMLParsing alloc] init];
                [newRecipes addObject:recipe];
                
                recipe.url = [element objectForKey:@"href"];
            }
            _recipes = newRecipes;
            
            NSLog(@"Manipulate specific recipe URL scraped from previous. Result: %@ \r \r", ((CSHTMLParsing*)_recipes[0]).url);
            
            // Open first individual recipe url and scrape needed info to be displayed on CSFoundViewController
            NSURL* indivRecipeUrl = [NSURL URLWithString:((CSHTMLParsing*)_recipes[0]).url];
            NSData* indivRecipeHtmlData = [NSData dataWithContentsOfURL:indivRecipeUrl];
            
            TFHpple* indivRecipeParser = [TFHpple hppleWithHTMLData:indivRecipeHtmlData];
            
            //Scrape TITLE
            NSString* titleXpathQueryString = @"//h1[@class='plaincharacterwrap fn']";
            NSArray* indivRecipeNodes = [indivRecipeParser searchWithXPathQuery:titleXpathQueryString];
            
            NSMutableArray* indivRecipes = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray* recipeTitle = [[NSMutableArray alloc] initWithCapacity:0];
            for(TFHppleElement* indivRecipeTF in indivRecipeNodes) {
                CSHTMLParsing* indivRecipeHTML = [[CSHTMLParsing alloc] init];
                [indivRecipes addObject:indivRecipeTF];
                
                indivRecipeHTML.title = [[indivRecipeTF firstChild] content];
                [recipeTitle addObject:indivRecipeHTML.title];
            }
            _recipeTitle = recipeTitle;
            NSLog(@"Log scraped recipe name. Result: %@ \r ", _recipeTitle);
            
            //Scrape IMAGEURL
            NSString* imageUrlXpathQueryString = @"//img[@class='rec-image rec-shadow hero-image marb10 photo']";
            indivRecipeNodes = [indivRecipeParser searchWithXPathQuery:imageUrlXpathQueryString];
            
            indivRecipes = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray* recipeImageUrl = [[NSMutableArray alloc] initWithCapacity:0];
            for(TFHppleElement* indivRecipeTF in indivRecipeNodes) {
                CSHTMLParsing* indivRecipeHTML = [[CSHTMLParsing alloc] init];
                [indivRecipes addObject:indivRecipeTF];
                
                indivRecipeHTML.imageUrl = [indivRecipeTF objectForKey:@"src"];
                [recipeImageUrl addObject:indivRecipeHTML.imageUrl];
            }
            _recipeImageUrl = recipeImageUrl;
            NSLog(@"Log scraped recipe image url. Result: %@ \r ", _recipeImageUrl);
            
            //Scrape INGREDIENTS
            NSString* ingredientsXpathQueryString = @"//span[@class='ingredient-name']";
            indivRecipeNodes = [indivRecipeParser searchWithXPathQuery:ingredientsXpathQueryString];
            
            indivRecipes = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray* recipeIngredients = [[NSMutableArray alloc] initWithCapacity:0];
            for(TFHppleElement* indivRecipeTF in indivRecipeNodes) {
                CSHTMLParsing* indivRecipeHTML = [[CSHTMLParsing alloc] init];
                [indivRecipes addObject:indivRecipeTF];
                
                indivRecipeHTML.ingredients = [[indivRecipeTF firstChild] content];
                [recipeIngredients addObject:indivRecipeHTML.ingredients];
            }
            _recipeIngredients = recipeIngredients;
            NSLog(@"Log recipe ingredients. Result: %@ \r \r", _recipeIngredients);
            
            // Scrape DIRECTIONS
            NSString* detailsXpathQueryString = @"//span[@class='plaincharacterwrap break']";
            indivRecipeNodes = [indivRecipeParser searchWithXPathQuery:detailsXpathQueryString];
            
            indivRecipes = [[NSMutableArray alloc] initWithCapacity:0];
            NSMutableArray* recipeDirections = [[NSMutableArray alloc] initWithCapacity:0];
            for(TFHppleElement* indivRecipeTF in indivRecipeNodes) {
                CSHTMLParsing* indivRecipeHTML = [[CSHTMLParsing alloc] init];
                [indivRecipes addObject:indivRecipeTF];
                
                indivRecipeHTML.directions = [[indivRecipeTF firstChild] content];
                [recipeDirections addObject:indivRecipeHTML.directions];
            }
            _recipeDirections = recipeDirections;
            NSLog(@"Log recipe directions. Result: %@ \r", _recipeDirections);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSegueWithIdentifier:@"FoundRecipeSegue" sender:self];
            });
        });
    }
}

#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* result = nil;
    if([_textCells count] <= indexPath.row) {
        CSTextFieldCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.ingredientTextField.delegate = self;
        [_textCells addObject:cell];
        result = cell;
    }
    else {
        result = _textCells[indexPath.row];
    }
    return result;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CSTextFieldCell* cell = (CSTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell.ingredientTextField resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    if(indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [_objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.navigationItem setLeftBarButtonItem:_doneButton animated:YES];
	_horizontalSwipeEditMode = YES;
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath {
	[self.navigationItem setLeftBarButtonItem:_editButton animated:YES];
	_horizontalSwipeEditMode = NO;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField {
	return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

#pragma mark View Management
- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"FoundRecipeSegue"]) {
        NSString* resultIngredients = [_recipeIngredients componentsJoinedByString:@", "];
        NSString* resultDirections = [_recipeDirections componentsJoinedByString:@" "];
        
        CSFoundViewController* foundDetails = segue.destinationViewController;
        
        foundDetails.recipeName = [_recipeTitle objectAtIndex:0];
        NSLog(@"SearchView RecipeName: %@", foundDetails.recipeName);
        foundDetails.recipeIngredients = resultIngredients;
        NSLog(@"SearchView RecipeIngredients: %@", foundDetails.recipeIngredients);
        foundDetails.recipeDirections = resultDirections;
        NSLog(@"SearchView RecipeDirections: %@", foundDetails.recipeDirections);
    }
}

#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    if(_textCells == nil) {
        _textCells = [[NSMutableArray alloc] init];
    }
	// Do any additional setup after loading the view, typically from a nib.
    [self.navigationItem setLeftBarButtonItem:_editButton animated:NO];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
    [self insertNewObject:self];
    [self insertNewObject:self];
    [self insertNewObject:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
