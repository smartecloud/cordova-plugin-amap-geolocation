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

  #import "AMapPlugin.h"



 #define Lang(en,zh) [[NSLocale preferredLanguages][0] rangeOfString:@"zh"].location==0?zh:en
 #define kSBKBeaconPluginReceiveLocalNotification @"SBKBeaconPluginReceiveLocalNofication"


 static NSDictionary *_luanchOptions=nil;


  @implementation AMapPlugin {
 
  }

 @synthesize _beacons;
 @synthesize _UUIDs;
 @synthesize callbackId=_callbackId;

  # pragma mark CDVPlugin



- (void)initLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
}


- (void)reGeocodeAction
{
    //    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
}

- (void)locAction
{
    //    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:self.completionBlock];
}

- (void)configLocationManager
{
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
}

- (void)initCompleteBlock
{
    //    __weak SingleLocationViewController *wSelf = self;
    
    __block AMapPlugin *blockSelf = self;

    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            if (error.code == AMapLocationErrorLocateFailed)
            {
                return;
            }
        }
        
        if (location)
        {
            if (regeocode)
            {
                NSLog(@"adress %@",[NSString stringWithFormat:@"%@", regeocode.formattedAddress]);
                //[annotation setSubtitle:[NSString stringWithFormat:@"%@-%@-%.2fm", regeocode.citycode, regeocode.adcode, location.horizontalAccuracy]];
                NSMutableDictionary* returnInfo = [[NSMutableDictionary alloc] init];
                
                [returnInfo setObject: [blockSelf getFormateString:regeocode.citycode]   forKey:@"citycode"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.formattedAddress]  forKey:@"address"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.adcode]  forKey:@"adcode"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.province]  forKey:@"province"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.city]  forKey:@"city"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.district]  forKey:@"district"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.township]  forKey:@"township"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.neighborhood] forKey:@"neighborhood"];
                [returnInfo setObject:[blockSelf getFormateString:regeocode.building]  forKey:@"building"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.street]   forKey:@"street"];
                [returnInfo setObject: [blockSelf getFormateString:regeocode.number ] forKey:@"number"];

                NSString *ss =  [NSString stringWithFormat:@"lat:%f;lon:%f;", location.coordinate.latitude, location.coordinate.longitude];
                NSLog(@"ss-> %@",ss);
                CLLocation* lInfo = location;
                
               // NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:8];
                NSNumber* timestamp = [NSNumber numberWithDouble:([lInfo.timestamp timeIntervalSince1970] * 1000)];
                [returnInfo setObject:timestamp forKey:@"timestamp"];
                [returnInfo setObject:[NSNumber numberWithDouble:lInfo.speed] forKey:@"velocity"];
                [returnInfo setObject:[NSNumber numberWithDouble:lInfo.verticalAccuracy] forKey:@"altitudeAccuracy"];
                [returnInfo setObject:[NSNumber numberWithDouble:lInfo.horizontalAccuracy] forKey:@"accuracy"];
                [returnInfo setObject:[NSNumber numberWithDouble:lInfo.course] forKey:@"heading"];
                [returnInfo setObject:[NSNumber numberWithDouble:lInfo.altitude] forKey:@"altitude"];
                [returnInfo setObject:[NSNumber numberWithDouble:lInfo.coordinate.latitude] forKey:@"latitude"];
                [returnInfo setObject:[NSNumber numberWithDouble:lInfo.coordinate.longitude] forKey:@"longitude"];
                
                [blockSelf returnSuccess:returnInfo];
            }
            else
            {
                NSString *ss =  [NSString stringWithFormat:@"lat:%f;lon:%f;", location.coordinate.latitude, location.coordinate.longitude];
                NSLog(@"ss-> %@",ss);
                    CLLocation* lInfo = location;
                
                NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:8];
                    NSNumber* timestamp = [NSNumber numberWithDouble:([lInfo.timestamp timeIntervalSince1970] * 1000)];
                    [returnInfo setObject:timestamp forKey:@"timestamp"];
                    [returnInfo setObject:[NSNumber numberWithDouble:lInfo.speed] forKey:@"velocity"];
                    [returnInfo setObject:[NSNumber numberWithDouble:lInfo.verticalAccuracy] forKey:@"altitudeAccuracy"];
                    [returnInfo setObject:[NSNumber numberWithDouble:lInfo.horizontalAccuracy] forKey:@"accuracy"];
                    [returnInfo setObject:[NSNumber numberWithDouble:lInfo.course] forKey:@"heading"];
                    [returnInfo setObject:[NSNumber numberWithDouble:lInfo.altitude] forKey:@"altitude"];
                    [returnInfo setObject:[NSNumber numberWithDouble:lInfo.coordinate.latitude] forKey:@"latitude"];
                    [returnInfo setObject:[NSNumber numberWithDouble:lInfo.coordinate.longitude] forKey:@"longitude"];
                [blockSelf reGeocodeAction];
                //[self returnSuccess:returnInfo];
            }
        }
    };
}

-(NSString*)getFormateString:(NSString*)source
{
    NSString *ss = @"";
    if (source) {
        ss = [NSString stringWithFormat:@"%@",source];
    }
    return ss;
}

- (void)returnSuccess:(NSMutableDictionary*) resultInfo{
    
    NSLog(@"resultinfo %@",[resultInfo description]);
    
    CDVPluginResult* result = nil;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:resultInfo];

    if (resultInfo) {
        [self.commandDelegate sendPluginResult:result callbackId:self.callbackId];
    }
    
}

/*
- (void)returnLocationInfo:(NSString*)callbackId andKeepCallback:(BOOL)keepCallback
{
    CDVPluginResult* result = nil;
    CDVLocationData* lData = self.locationData;
    
    if (lData && !lData.locationInfo) {
        // return error
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:POSITIONUNAVAILABLE];
    } else if (lData && lData.locationInfo) {
        CLLocation* lInfo = lData.locationInfo;
        NSMutableDictionary* returnInfo = [NSMutableDictionary dictionaryWithCapacity:8];
        NSNumber* timestamp = [NSNumber numberWithDouble:([lInfo.timestamp timeIntervalSince1970] * 1000)];
        [returnInfo setObject:timestamp forKey:@"timestamp"];
        [returnInfo setObject:[NSNumber numberWithDouble:lInfo.speed] forKey:@"velocity"];
        [returnInfo setObject:[NSNumber numberWithDouble:lInfo.verticalAccuracy] forKey:@"altitudeAccuracy"];
        [returnInfo setObject:[NSNumber numberWithDouble:lInfo.horizontalAccuracy] forKey:@"accuracy"];
        [returnInfo setObject:[NSNumber numberWithDouble:lInfo.course] forKey:@"heading"];
        [returnInfo setObject:[NSNumber numberWithDouble:lInfo.altitude] forKey:@"altitude"];
        [returnInfo setObject:[NSNumber numberWithDouble:lInfo.coordinate.latitude] forKey:@"latitude"];
        [returnInfo setObject:[NSNumber numberWithDouble:lInfo.coordinate.longitude] forKey:@"longitude"];
        
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnInfo];
        [result setKeepCallbackAsBool:keepCallback];
    }
    if (result) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}

- (void)returnLocationError:(NSUInteger)errorCode withMessage:(NSString*)message
{
    NSMutableDictionary* posError = [NSMutableDictionary dictionaryWithCapacity:2];
    
    [posError setObject:[NSNumber numberWithUnsignedInteger:errorCode] forKey:@"code"];
    [posError setObject:message ? message:@"" forKey:@"message"];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:posError];
    
    for (NSString* callbackId in self.locationData.locationCallbacks) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
    
    [self.locationData.locationCallbacks removeAllObjects];
    
    for (NSString* callbackId in self.locationData.watchCallbacks) {
        [self.commandDelegate sendPluginResult:result callbackId:callbackId];
    }
}
*/

- (void)getLocation:(CDVInvokedUrlCommand*)command
{
    
    self.callbackId = command.callbackId;
    //OL enableHighAccuracy = [[command argumentAtIndex:0] boolValue];
//    [self locAction];
    [self reGeocodeAction];

}


- (void)getCurrentAdress:(CDVInvokedUrlCommand*)command
{
    self.callbackId = command.callbackId;
    //OL enableHighAccuracy = [[command argumentAtIndex:0] boolValue];
    [self reGeocodeAction];
}


 +(void)setLaunchOptions:(NSDictionary *)theLaunchOptions{
     _luanchOptions=theLaunchOptions;
    // [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |                                                   UIUserNotificationTypeSound |   UIUserNotificationTypeAlert)  categories:nil];
     //[APService setupWithOption:_luanchOptions];
 }

 - (void)setBeacon:(AMapPlugin *)amap{
 }

 -(void)initial:(CDVInvokedUrlCommand*)command{
     //do nithng,because Cordova plugin use lazy load mode.
     NSLog(@"initial->");
     [self initLocationManager];
     [self initCompleteBlock];
     [self configLocationManager];
     //    //逆地址
     //    [self reGeocodeAction];
     //    //
     //    [self locAction];

//     [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//     //[self customizeAppearance];

 }

 - (CDVPlugin*)initWithWebView:(UIWebView*)theWebView{
     if (self=[super initWithWebView:theWebView]) {
        
         NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
         [defaultCenter addObserver:self
                           selector:@selector(localDidReceiveMessage:)
                               name:kSBKBeaconPluginReceiveLocalNotification
                             object:nil];
 //
 //        [defaultCenter addObserver:self
 //                          selector:@selector(networkDidReceiveNotification1:)
 //                              name:@"leave"
 //                            object:nil];
        
 //        if (_luanchOptions) {
 //            NSDictionary *userInfo = [_luanchOptions
 //                                      valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
 //            if ([userInfo count] >0) {
 //                NSError  *error;
 //                NSData   *jsonData   = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
 //                NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
 //                if (!error) {
 //                    
 //                    dispatch_async(dispatch_get_main_queue(), ^{
 //                        [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('jpush.openNotification',%@)",jsonString]];
 //                    });
 //                    
 //                }
 //            }
 //            
 //        }
        
     }
     return self;
 }


 -(void)getRangeNewBeacon:(CDVInvokedUrlCommand*)command{
    
     //NSString* registrationID = [APService registrationID];
     CDVPluginResult *result=[self pluginResultForValue:@""];
    
     if (result) {
         [self succeedWithPluginResult:result withCallbackID:command.callbackId];
     } else {
         [self failWithCallbackID:command.callbackId];
     }
 }

 - (void)failWithCallbackID:(NSString *)callbackID {
     CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
     [self.commandDelegate sendPluginResult:result callbackId:callbackID];
 }
 - (void)succeedWithPluginResult:(CDVPluginResult *)result withCallbackID:(NSString *)callbackID {
     [self.commandDelegate sendPluginResult:result callbackId:callbackID];
 }


 - (CDVPluginResult *)pluginResultForValue:(id)value {
    
     CDVPluginResult *result;
     if ([value isKindOfClass:[NSString class]]) {
         result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK
                                    messageAsString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
     } else if ([value isKindOfClass:[NSNumber class]]) {
         CFNumberType numberType = CFNumberGetType((CFNumberRef)value);
         //note: underlyingly, BOOL values are typedefed as char
         if (numberType == kCFNumberIntType || numberType == kCFNumberCharType) {
             result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:[value intValue]];
         } else  {
             result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDouble:[value doubleValue]];
         }
     } else if ([value isKindOfClass:[NSArray class]]) {
         result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:value];
     } else if ([value isKindOfClass:[NSDictionary class]]) {
         result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:value];
     } else if ([value isKindOfClass:[NSNull class]]) {
         result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
     } else {
         NSLog(@"Cordova callback block returned unrecognized type: %@", NSStringFromClass([value class]));
         return nil;
     }
     return result;
 }


 - (instancetype)initWithDictionary:(NSDictionary*)dictionary {
     if (self = [super init]) {
         [self setValuesForKeysWithDictionary:dictionary];}
     return self;
 }

 -(void)getChangeBeacon:(CDVInvokedUrlCommand*)command{
    
     //NSString* registrationID = [APService registrationID];
    
     NSMutableDictionary *option = [command.arguments objectAtIndex:0];

     //SBKBeacon *mobj = [self initWithDictionary:option];
    
     NSLog(@"_beacons-> %@",[_beacons description]);
 
    
     CDVPluginResult *result=[self pluginResultForValue:@""];
    
     if (result) {
         [self succeedWithPluginResult:result withCallbackID:command.callbackId];
     } else {
         [self failWithCallbackID:command.callbackId];
     }
 }




 #pragma mark - AMapManagerDelegate
 - (void)localDidReceiveMessage:(NSNotification *)notification {
    
     NSDictionary *userInfo = [notification userInfo];
     NSLog(@"%@", [userInfo description]);
 //    
 //    NSError  *error;
 //    NSData   *jsonData   = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
 //    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
 //    //NSLog(@"%@",jsonString);
 //    dispatch_async(dispatch_get_main_queue(), ^{
 //        
 //        [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('jpush.receiveMessage',%@)",jsonString]];
 //        //[self.commandDelegate evalJs:[NSString stringWithFormat:@"window.plugins.jPushPlugin.getNewBeaconInAndroidCallback('%@')",jsonString]];
 //    });
    
 }

 -(void)networkDidReceiveNotification1:(id)notification{
    
     NSError  *error;
     NSDictionary *userInfo = [notification object];
    
     NSData   *jsonData   = [NSJSONSerialization dataWithJSONObject:userInfo options:0 error:&error];
     NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
     switch ([UIApplication sharedApplication].applicationState) {
         case UIApplicationStateActive:
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('jpush.receiveNotification',%@)",jsonString]];
             });
            
         }
             break;
         case UIApplicationStateInactive:
         case UIApplicationStateBackground:
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('jpush.openNotification',%@)",jsonString]];
             });
            
         }
             break;
         default:
             //do nothing
             break;
     }
 }



 - (NSString*) convertObjectToJson:(NSMutableDictionary*) object
 {

     NSError *error;
     NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                        options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                          error:&error];
     NSString *result=@"";
     if (! jsonData) {
         NSLog(@"Got an error: %@", error);
     } else {
         result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
     }
    
     return result;
 }


 -(void)customizeAppearance
 {
     //    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x111111)];
     //    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
     //    [[UINavigationBar appearance] setShadowImage:[[UIImage imageWithColor:UIColorFromRGB(0x111111) andSize:CGSizeMake(1, 1)] stretchableImageWithLeftCapWidth:1 topCapHeight:1]];
 }

// - (BOOL)checkLocationServices
// {
//     if (!self.locationManager) {
//         self.locationManager = [[CLLocationManager alloc] init];
//         self.locationManager.desiredAccuracy=kCLLocationAccuracyBest;
//         self.locationManager.distanceFilter=100.0f;
//     }
//     BOOL enable=[CLLocationManager locationServicesEnabled];//定位服务是否可用
//     int status=[CLLocationManager authorizationStatus];//是否具有定位权限
//     if(!enable || status<3){
//         if([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
//         {
//             [self.locationManager requestAlwaysAuthorization];//请求权限
//         }
//         return NO;//需求请求定位权限
//     }
//     return YES;
// }




 - (void)check{
    
     //    if ([self.window.rootViewController.presentedViewController isKindOfClass:[CheckViewController class]]) {
     //        [(CheckViewController *)self.window.rootViewController.presentedViewController refresh];
     //    }
     //
//     if ([self checkBluetoothServices]&&[self checkLocationServices]) {
//        
//     }
//     else
//     {
//         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"掌上会"
//                                                         message:@"掌上会应用需要一些系统权限请开启:定位服务和蓝牙"
//                                                        delegate:nil
//                                               cancelButtonTitle:@"确定"
//                                               otherButtonTitles:nil];
//         //[alert show];
//     }
 }

 #pragma mark - CBCentralManagerDelegate


 - (void)beacon:(NSNotification *)notification {
     
 }


 - (void)sendLocalNotification:(NSString*)msg
 {
     UILocalNotification *notice = [[UILocalNotification alloc] init];
     notice.alertBody = msg;
     notice.alertAction = Lang(@"Open", @"打开软件");
     notice.soundName = UILocalNotificationDefaultSoundName;
     notice.userInfo = @{@"msg":@"whatever you want"};
     [[UIApplication sharedApplication] presentLocalNotificationNow:notice];
 }


  @end
