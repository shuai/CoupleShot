//
//  CAppDelegate.m
//  Hello
//
//  Created by Shuai on 5/20/13.
//  Copyright (c) 2013 joy. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "CAppDelegate.h"
#import "JNSWizardViewController.h"
#import "CViewController.h"
#import "JNSConfig.h"
#import "JNSPairViewController.h"
#import "JNSPairWaitingViewController.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface CAppDelegate() {
}
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;


- (NSURL *)applicationDocumentsDirectory;
@end


@implementation CAppDelegate
@synthesize managedObjectModel=_managedObjectModel, managedObjectContext=_managedObjectContext, persistentStoreCoordinator=_persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Load config
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"JNSConfig"];

    NSError* error;
    NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (error) {
        // create config
        NSLog(@"%@",error);
        return NO;
    }
    
    if ([result count] == 0) {
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"JNSConfig"
                                                  inManagedObjectContext:self.managedObjectContext];
        [JNSConfig setConfig: [[JNSConfig alloc] initWithEntity:entity
                                 insertIntoManagedObjectContext:self.managedObjectContext]];
    } else {
        NSAssert([result count] == 1, @"");
        [JNSConfig setConfig:[result firstObject]];
    }
    
    // Init views
    [self.window makeKeyAndVisible];
    
    JNSUser* user = [JNSUser activeUser];
    if (!user || !user.partner) {
        JNSWizardViewController* wizard = [[self.window.rootViewController storyboard] instantiateViewControllerWithIdentifier:@"wizard_view"];
        [self.window.rootViewController presentViewController:wizard animated:false completion:nil];
    }
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    if (![JNSConfig config].deviceToken) {
        NSLog(@"Register for push notification");
        int types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [application registerForRemoteNotificationTypes:types];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    // try to clean up as much memory as possible. next step is to terminate app
    
}

// notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JNSConfig config].deviceToken = deviceToken;
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    if ([error code] != 3010) {
        NSLog(@"RETRY Register for push notification");
        int types = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert;
        [application registerForRemoteNotificationTypes:types];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"didReceiveRemoteNotification: %@", [userInfo description]);
    NSString* type = [userInfo valueForKey:@"type"];
    if ([type compare:@"post"] == NSOrderedSame) {
        [[JNSUser activeUser].timeline loadLatest];
    } else if ([type compare:@"pair"] == NSOrderedSame) {
        NSDictionary* user = [userInfo objectForKey:@"user"];
        if (user) {
            [[JNSUser activeUser] updateJSON:user];
        }
    }
}

- (void)saveContext
{    
    NSError *error;
    if (_managedObjectContext != nil) {
        if ([_managedObjectContext hasChanges] && ![_managedObjectContext save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// Core Data
#pragma mark -
#pragma mark Core Data stack

/*
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return _managedObjectContext;
}


// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}


/*
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Cache.JNSStore"];
    
//    /*
//     Set up the store.
//     For the sake of illustration, provide a pre-populated default store.
//     */
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    // If the expected store doesn't exist, copy the default store.
//    if (![fileManager fileExistsAtPath:[storeURL path]]) {
//        NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:@"CoreDataBooks" withExtension:@"CDBStore"];
//        if (defaultStoreURL) {
//            [fileManager copyItemAtURL:defaultStoreURL toURL:storeURL error:NULL];
//        }
//    }
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    
    NSError *error;
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
