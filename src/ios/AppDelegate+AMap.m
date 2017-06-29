 /*
  Licensed to the Apache Software Foundation (ASF) under one
  or more contributor license agreements.  See the NOTICE file
  distributed with this work for additional information
  regarding copyright ownership.  The ASF licenses this file
  to you under the Apache License, Version 2.0 (the
  "License"); you may not use this file except in compliance
  with the License.  You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an
  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
  KIND, either express or implied.  See the License for the
  specific language governing permissions and limitations
  under the License.
  */

 #import "AppDelegate+AMap.h"
 #import <objc/runtime.h>
 #import "AMapPlugin.h"


//#import "APIKey.h"
//#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>


 #define kSBKBeaconPluginReceiveLocalNotification @"SBKBeaconPluginReceiveLocalNofication"


 #ifndef iOS8
 #define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
 #endif

 #ifndef iOS7
 #define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
 #endif

 #ifndef iOS6
 #define iOS6 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0)
 #endif

 #define kAppDelegate ((AppDelegate *)([UIApplication sharedApplication].delegate))

 #define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


 //@interface AppDelegate (SBKBeacon) ()<CBCentralManagerDelegate,SBKBeaconManagerDelegate>
 //    @property(strong, nonatomic)CLLocationManager * locationManager;
 //    @property(strong, nonatomic)CBCentralManager * CM;
 //@end


  @implementation AppDelegate (SBKBeacon)


  + (void)load {
      static dispatch_once_t onceToken;
      dispatch_once(&onceToken, ^{
          Class class = [self class];

          SEL originalSelector = @selector(application:didFinishLaunchingWithOptions:);
          //         SEL originalSelector = @selector(init);
          SEL swizzledSelector = @selector(xxx_application:didFinishLaunchingWithOptions:);

          Method originalMethod = class_getInstanceMethod(class, originalSelector);
          Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
          //
          //         BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
          //         if (didAddMethod) {
          //             class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
          //         } else {
          //             method_exchangeImplementations(originalMethod, swizzledMethod);
          //         }

          Method origin;
          Method swizzle;
          origin = class_getInstanceMethod(class , originalSelector);
          swizzle = class_getInstanceMethod(class, swizzledSelector);


          method_exchangeImplementations(originalMethod, swizzledMethod);

      });
  }

 -(instancetype)init_plus1{

     [[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(applicationDidLaunchBeacon:)
                                                  name:@"UIApplicationDidFinishLaunchingNotificationBeacon"
                                                object:nil];
     return [self init_plus1];
 }

 -(void)applicationDidLaunchBeacon:(NSNotification *)notification{

     if (notification) {
         //[JPushPlugin setLaunchOptions:notification.userInfo];
         NSLog(@"applicationDidLaunch");
     }
 }



  - (BOOL) xxx_application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

      BOOL launchedWithoutOptions = launchOptions == nil;
      
      
      //[MAMapServices sharedServices].apiKey = @"ceca517de34a392b0eb7680957f13cfb";
      [AMapLocationServices sharedServices].apiKey = @"35338e8c2c72c22493ba3ab4d853b0f9";
      

      if (!launchedWithoutOptions) {
         // [self requestMoreBackgroundExecutionTime];
      }

      if (iOS8) {
          UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert categories:nil];
          [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
      }else{
          [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert];
      }


      // are you running on iOS8?
      if ([application respondsToSelector:@selector(registerUserNotificationSettings:)])
      {
          UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge|UIUserNotificationTypeAlert|UIUserNotificationTypeSound) categories:nil];
          [application registerUserNotificationSettings:settings];
      }
      else // iOS 7 or earlier
      {
          UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
          [application registerForRemoteNotificationTypes:myTypes];
      }

      // Override point for customization after application launch.

      // None of the code should even be compiled unless the Base SDK is iOS 8.0 or later
 #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
      // The following line must only run under iOS 8. This runtime check prevents
      // it from running if it doesn't exist (such as running under iOS 7 or earlier).
      if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
          [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
      }
 #endif



      return [self xxx_application:application didFinishLaunchingWithOptions:launchOptions];

  }

 // - (UIBackgroundTaskIdentifier) backgroundTaskIdentifier {
 //     NSNumber *asNumber = objc_getAssociatedObject(self, @selector(backgroundTaskIdentifier));
 //     UIBackgroundTaskIdentifier  taskId = [asNumber unsignedIntValue];
 //     return taskId;
 // }
 //
 // - (void)setBackgroundTaskIdentifier:(UIBackgroundTaskIdentifier)backgroundTaskIdentifier {
 //     NSNumber *asNumber = [NSNumber numberWithUnsignedInt:backgroundTaskIdentifier];
 //     objc_setAssociatedObject(self, @selector(backgroundTaskIdentifier), asNumber, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
 // }
 //
 // - (void) requestMoreBackgroundExecutionTime {
 //
 //     UIApplication *application = [UIApplication sharedApplication];
 //
 //     self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
 //         self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
 //
 //     }];
 // }


 // repost all remote and local notification using the default NSNotificationCenter so multiple plugins may respond
 - (void)  application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
 {
     // re-post ( broadcast )

     [[NSNotificationCenter defaultCenter] postNotificationName:CDVLocalNotification object:notification];

     NSLog(@"notification-> %@",notification.alertBody);

     [[NSNotificationCenter defaultCenter] postNotificationName:kSBKBeaconPluginReceiveLocalNotification  object:notification];

 }


  @end
