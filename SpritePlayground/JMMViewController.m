//
//  JMMViewController.m
//  SpritePlayground
//
//  Created by Justin Martin on 2/1/14.
//  Copyright (c) 2014 JMM. All rights reserved.
//

#import "JMMViewController.h"
#import "JMMMyScene.h"

@implementation JMMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    SKView *skView = (SKView *) self.view;
    
    if (!skView.scene) {
        skView.showsFPS = YES;
        skView.showsNodeCount = YES;
    }
    
    SKScene *scene = [JMMMyScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    
    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
    } else {
        return UIInterfaceOrientationMaskAll;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

@end
