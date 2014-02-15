//
//  CSViewController.m
//  CollegeChef
//
//  Created by Sahil Diwan.
//

#import "CSViewController.h"

@interface CSViewController (/*Class Extension*/)
- (void)_initialize;
@end


@implementation CSViewController
#pragma mark View Management
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

	// Do any additional setup after loading the view, typically from a nib.
	// Note that this method can potentially be called multiple times, so check to make sure instance
	// variables are not already initialized if appropriate
}


#pragma mark Initialization
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
		[self _initialize];
    }
	
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder {
	if((self = [super initWithCoder:aDecoder])) {
		[self _initialize];
	}
	
	return self;
}


#pragma mark Private (Initialization)
- (void)_initialize {
	// Custom initialization
}
@end
