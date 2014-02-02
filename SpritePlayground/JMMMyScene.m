//
//  JMMMyScene.m
//  SpritePlayground
//
//  Created by Justin Martin on 2/1/14.
//  Copyright (c) 2014 JMM. All rights reserved.
//

#import "JMMMyScene.h"

static const uint32_t projectileCategory = 0x1 << 0;
static const uint32_t monsterCategory = 0x1 << 1;

@interface JMMMyScene() <SKPhysicsContactDelegate>

@property (nonatomic) SKSpriteNode *player;
@property (nonatomic) NSTimeInterval lastSpawnTimeInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;

@end

static inline CGPoint rwAdd(CGPoint a, CGPoint b) {
    return CGPointMake(a.x + b.x, a.y + b.y);
}
static inline CGPoint rwSub(CGPoint a, CGPoint b) {
	return CGPointMake(a.x - b.x, a.y - b.y);
}
static inline CGPoint rwMult(CGPoint a, float b) {
	return CGPointMake(a.x * b, a.y * b);
}
static inline float rwLength(CGPoint a) {
	return sqrtf(a.x * a.x + a.y * a.y);
}
static inline CGPoint rwNormalize(CGPoint a) {
    float length = rwLength(a);
    return CGPointMake(a.x/length, a.y/length);
}

@implementation JMMMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        
        self.backgroundColor = [SKColor colorWithRed:1 green:1 blue:1 alpha:1.0];
        
        self.player = [SKSpriteNode spriteNodeWithImageNamed:@"player"];
        self.player.position = CGPointMake(self.player.size.width/2, self.frame.size.height/2);
        
        self.lastUpdateTimeInterval = 0;
        self.lastSpawnTimeInterval = 0;
        
        [self addChild:self.player];
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void) update:(CFTimeInterval)currentTime {
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    
    if (timeSinceLast > 1) {
        timeSinceLast = 1.0 / 60;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
}

-(void) addMonster {
    SKSpriteNode *monster = [SKSpriteNode spriteNodeWithImageNamed:@"monster"];
    monster.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:monster.size];
    monster.physicsBody.dynamic = YES;
    monster.physicsBody.categoryBitMask = monsterCategory;
    monster.physicsBody.contactTestBitMask = projectileCategory;
    monster.physicsBody.collisionBitMask = 0;
    
    
    int minY = monster.size.height /2;
    int maxY = self.frame.size.height - minY;
    int rangeY = maxY - minY;
    int actualY = (arc4random() % rangeY) + minY;
    
    monster.position = CGPointMake(self.frame.size.width - monster.size.width/2, actualY);
    [self addChild:monster];
    
    int minDur = 2;
    int maxDur = 4;
    int rangeDur = maxDur - minDur;
    int actualDur = (arc4random() % rangeDur) + minDur;
    
    SKAction *moveAction = [SKAction moveTo:CGPointMake(-monster.size.width/2, actualY) duration:actualDur];
    SKAction *moveActionDone = [SKAction removeFromParent];
    [monster runAction:[SKAction sequence:@[moveAction, moveActionDone]]];
}

-(void) updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast {
    self.lastSpawnTimeInterval += timeSinceLast;
    if (self.lastSpawnTimeInterval > 1) {
        self.lastSpawnTimeInterval = 0;
        [self addMonster];
    }
}

-(void) didBeginContact:(SKPhysicsContact *)contact {
    SKPhysicsBody *firstBody, *secondBody;
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    } else {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) {
        [self projectile:(SKSpriteNode *)firstBody.node didCollideWithMonster:(SKSpriteNode *)secondBody.node];
    }
}

-(void) projectile:(SKSpriteNode *) projectile didCollideWithMonster:(SKSpriteNode *)monster {
    NSLog(@"HIT!!");
    [projectile removeFromParent];
    [monster removeFromParent];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
//    
//    for (UITouch *touch in touches) {
//        CGPoint location = [touch locationInNode:self];
//        
//        SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
//        
//        sprite.position = location;
//        
//        SKAction *action = [SKAction rotateByAngle:M_PI duration:1];
//        
//        [sprite runAction:[SKAction repeatActionForever:action]];
//        
//        [self addChild:sprite];
//    }
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    
    SKSpriteNode *projectile = [SKSpriteNode spriteNodeWithImageNamed:@"projectile"];
    projectile.position = self.player.position;
    projectile.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:projectile.size.width / 2];
    projectile.physicsBody.dynamic = YES;
    projectile.physicsBody.categoryBitMask = projectileCategory;
    projectile.physicsBody.contactTestBitMask = monsterCategory;
    projectile.physicsBody.collisionBitMask = 0;
    projectile.physicsBody.usesPreciseCollisionDetection = YES;
    
    
    CGPoint offset = rwSub(location, projectile.position);
    
    if (offset.x <= 0) return;
    
    [self addChild:projectile];
    
    CGPoint dir = rwNormalize(offset);
    CGPoint normEndPos = rwMult(dir, 1000);
    CGPoint relativeEndPos = rwAdd(projectile.position, normEndPos);
    
    SKAction *moveAction = [SKAction moveTo:relativeEndPos duration:1];
    SKAction *moveActionDone = [SKAction removeFromParent];
    [projectile runAction:[SKAction sequence:@[moveAction, moveActionDone]]];
}
@end
