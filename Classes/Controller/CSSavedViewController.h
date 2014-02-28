//
//  CSSavedViewController.h
//  CollegeChef
//
//  Created by Sahil Diwan.
//

#import "CSFoundViewControllerDelegate.h"

@class Recipe;

@interface CSSavedViewController : UITableViewController <CSFoundViewControllerDelegate>
- (void)setSelectedRecipe:(Recipe*)selectedRecipe;
@end
