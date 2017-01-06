//
//  HomeController.m
//  mapping
//
//  Created by Richard on 2016/12/6.
//  Copyright © 2016年 sailstech. All rights reserved.
//

#import "HomeController.h"
#import "PFUser.h"
#import "PFQuery.h"
#import "CommonDefine.h"
#import "MenuController.h"
#import "AccVerify.h"
#import "PopupInfoView.h"
#import "CheckPoint.h"
#import "POI.h"
#import <locating/Sails.h>

@interface HomeController ()
@property (weak, nonatomic) IBOutlet UIView *mapView;

@end

@implementation HomeController {
    PFObject *projectObject;
    UIAlertController *selectProjectController;
    NSArray *projectArray;
    SailsLocationMapView *mSailsMap;
    Sails *mSails;
    __weak IBOutlet UIButton *bZoomIn;
    __weak IBOutlet UIButton *bZoomOut;

    __weak IBOutlet UIButton *bCenter;
    __weak IBOutlet UIButton *bFloor;
    __weak IBOutlet UIBarButtonItem *biPositioning;
    BOOL inLocating;

    NSMutableDictionary *generalMap;
    NSMutableDictionary *highlightMap;
    NSMutableDictionary *checkMap;
    PopupInfoView *mPopupInfoView;
    __weak IBOutlet UIView *accVerifyView;
    __weak IBOutlet UILabel *labelSample;
    
    __weak IBOutlet UIView *accVerifyInnerView;
    __weak IBOutlet UIView *AccVerifyInner;
    __weak IBOutlet UILabel *labelAccuracy;
    __weak IBOutlet UILabel *labelDeviation;
}
- (IBAction)clearVerificationResults:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:ZpLocalizedString(@"delete_result")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:ZpLocalizedString(@"yes")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [AccVerify ClearMeasurementResult:mSailsMap];
                                                [self clearMeasurementTitle];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:ZpLocalizedString(@"no")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)emailCSVFile:(id)sender {
    if(![MFMailComposeViewController canSendMail]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                       message:ZpLocalizedString(@"no_email_account")
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:ZpLocalizedString(@"ok")
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    NSString *file=[AccVerify SaveToCSVFile];
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    mailer.mailComposeDelegate = self;
    NSString* name= [((NSString *) projectObject[@"name"]) stringByAppendingString:@" Measurement Result"];
    [mailer setSubject:name];
    [mailer addAttachmentData:[NSData dataWithContentsOfFile:file]
                     mimeType:@"text/csv"
                     fileName:@"output.csv"];
    [self presentModalViewController:mailer animated:YES];

}
- (BOOL)changeMode:(int)mode {
    if((mode&0x0fff)==(_currentMode&0xfff)) {
        _currentMode=mode;
        return true;
    }

    switch(_currentMode) {
        case NO_MODE:
            break;
        case ACCURACY_VERIFICATION:
            [AccVerify StopAccVerifyWithSailsMapView:mSailsMap];
            [accVerifyView setHidden:true];
            break;
        default:
            break;
    }
    _currentMode=mode;
    switch(_currentMode) {
        case NO_MODE:
            break;
        case ACCURACY_VERIFICATION:
            [AccVerify StartAccVerifyWithView:self.view
                                ProjectObject:projectObject
                              GeneralIconDict:generalMap
                            HighlightIconDict:highlightMap
                                CheckIconDict:checkMap
                                 SailsMapView:mSailsMap
                                        Floor:[mSailsMap getCurrentBrowseFloorName]];
            [accVerifyView setHidden:false];


            break;
        default:
            break;
    }
    return true;

}

- (IBAction)centerIconTapped:(id)sender {
    SailsMapControlMode mode = [mSailsMap getMapControlMode];

    if ([mSailsMap isCenterLock])
    {
        if ((mode & FollowPhoneHeagingMode) == FollowPhoneHeagingMode)
        {
            //if map control mode is follow phone heading, then set mode to location center lock when button click.
            [mSailsMap setMapControlMode:mode & ~FollowPhoneHeagingMode];
        } else {
            //if map control mode is location center lock, then set mode to follow phone heading when button click.
            [mSailsMap setMapControlMode:mode | FollowPhoneHeagingMode];
        }
    } else {
        if(!inLocating) {
            [self startPositioningProcedure];
            return;
        }
        //if map control mode is none, then set mode to loction center lock when button click.
        [mSailsMap setMapControlMode:mode | LocationCenterLockMode];
    }

}
- (IBAction)showMenu:(id)sender {
    // Dismiss keyboard (optional)
    //
    [self.view endEditing:YES];
    [self.frostedViewController.view endEditing:YES];
    
    // Present the view controller
    //
    [self.frostedViewController presentMenuViewController];

}
-(void) iconMappingProcedure {
    generalMap = [[NSMutableDictionary alloc] init];
    highlightMap = [[NSMutableDictionary alloc] init];
    checkMap = [[NSMutableDictionary alloc] init];
    generalMap[@"default"]= [UIImage imageNamed:@"cp_gray"];
    generalMap[@"check_point"]= [UIImage imageNamed:@"cp_gray"];
    highlightMap[@"default"]= [UIImage imageNamed:@"cp_red"];
    highlightMap[@"check_point"]= [UIImage imageNamed:@"cp_red"];
    checkMap[@"default"]= [UIImage imageNamed:@"cp_green"];
    checkMap[@"check_point"]= [UIImage imageNamed:@"cp_green"];
}
- (void) initSails
{
    // Map View
    //const float fPosY = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    //CGRect rect = CGRectMake(0, fPosY, self.view.frame.size.width, self.view.frame.size.height - fPosY - BOTTOM_BAR_HEIGHT);
    CGRect rect = self.view.bounds;
    mSailsMap = [[SailsLocationMapView alloc] initWithFrame:rect];
    [_mapView addSubview:mSailsMap];

    //rect.size.height -= (fPosY + 49);
//    [mSailsMap mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    //mSailsMap.layer.drawsAsynchronously = YES;
    //[mSailsMap setMapControlMode:LocationCenterLockMode];
    Paint *accuracyCirclePaint = [[Paint alloc] init];
    accuracyCirclePaint.strokeColor = [UIColor colorWithRed:53/255.0 green:179/255.0 blue:229/255.0 alpha:0/255.0];
    accuracyCirclePaint.fillColor = [UIColor colorWithRed:53/255.0 green:179/255.0 blue:229/255.0 alpha:0/255.0];
    accuracyCirclePaint.strokeWidth = 0;
    //    accuracyCirclePaint.strokeColor = [UIColor colorWithRed:53/255.0 green:179/255.0 blue:229/255.0 alpha:40/255.0];
    //    accuracyCirclePaint.fillColor = [UIColor colorWithRed:53/255.0 green:179/255.0 blue:229/255.0 alpha:40/255.0];
    //    accuracyCirclePaint.strokeWidth = 3;
    [mSailsMap setLocationMarker:[UIImage imageNamed:@"myloc_arr"] arrowImage:[UIImage imageNamed:@"myloc_arr"] accuracyCirclePaint:accuracyCirclePaint iconFrame:100];
    // Sails Engine
    mSails = [[Sails alloc] init];
    [mSails setMode:WITH_GPS];
    [mSails setSailsLocationMapView:mSailsMap];
    [mSailsMap setLocatorMarkerVisible:true];

    SailsLocationMapView* __weak weakSailsMap=mSailsMap;
    Sails* __weak weakSails=mSails;
    HomeController* __weak weakself=self;
    PopupInfoView* __weak weakPopInfo=mPopupInfoView;
    [mSailsMap setOnFloorChangedAfterBlock:^(NSString *floorName) {
        int i=[[mSails getFloorNameList] indexOfObject:floorName];
        [bFloor setTitle: [mSails getFloorDescList][i]  forState:UIControlStateNormal];

        switch(_currentMode) {
            case ACCURACY_VERIFICATION:
                [AccVerify ShowFloorPOIsWithSAILSMapView:mSailsMap Floor:floorName];
                break;
            default:break;
        }

    }];

    [mSailsMap setOnMapClickBlock:^(CGPoint tapPoint) {
        [weakself mapTouchEventProcedureWithPoint:tapPoint];

    }];
    [mSailsMap setOnMapMoveEventBlock:^{
        [weakPopInfo setHidden:true];
    }];
    [mSailsMap setOnMapRotateEventBlock:^{
        [weakPopInfo setHidden:true];
    }];
    [mSailsMap setOnMapScaleEventBlock:^{
        [weakPopInfo setHidden:true];
    }];
    UITapGestureRecognizer *tapZoomInGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomInTapped)];
    tapZoomInGesture.numberOfTapsRequired=1;
    [bZoomIn setImage:[UIImage imageNamed:@"zoomin_p"] forState:UIControlStateHighlighted];
    [bZoomIn setUserInteractionEnabled:true];
    [bZoomIn addGestureRecognizer:tapZoomInGesture];
    UITapGestureRecognizer *tapZoomOutGesture= [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomOutTapped)];
    tapZoomOutGesture.numberOfTapsRequired=1;
    [bZoomOut setImage:[UIImage imageNamed:@"zoomout_p"] forState:UIControlStateHighlighted];
    [bZoomOut setUserInteractionEnabled:true];
    [bZoomOut addGestureRecognizer:tapZoomOutGesture];

    // For Debug : 看map size
    //self.view.backgroundColor = [UIColor greenColor];
    //mSailsMap.backgroundColor = [UIColor redColor];
    __weak SailsLocationMapView* weakSailsMapView=mSailsMap;
    [mSails setOnLocationChangeEventBlock:^{
        if ([weakSailsMapView isCenterLock] && ![weakSailsMapView isInLocationFloor] && ![[weakSails getFloor] isEqualToString:@""] && [weakSails isLocationFix]) {
            [weakSailsMapView loadCurrentLocationFloorMap];
            [weakSailsMapView startAnimationToZoom:19];
        }
        
    }];

}

- (void)mapTouchEventProcedureWithPoint:(CGPoint)point {
    NSString* len;
    switch(_currentMode) {
        case ACCURACY_VERIFICATION:
            len =[AccVerify CheckCheckPointIsTouchedWithPoint:point
                                                        sails:mSails
                                                     sailsMap:mSailsMap];
            if(len.length>0) {
                CheckPoint* cp = [AccVerify GetCurrentCheckPoint];
                CGPoint centerPoint=[self CGPointFromGeoPoint:[cp.verifyCheckPoint getGeoPoint]];
                centerPoint.y-=50;
                [mPopupInfoView showInfo:cp.verifyCheckPoint
                                    Info:[len stringByAppendingString:ZpLocalizedString(@"m")]
                                  InView:mSailsMap
                                 clickOn:centerPoint
                                HideNavi:false];
            } else {
                [mPopupInfoView setHidden:true];
            }
            break;
    }

}- (CGPoint) CGPointFromGeoPoint:(GeoPoint*) geoPoint
{
    float fRadians = [mSailsMap getTotalRotationAngle];
    //float fAngle = fRadians * 180 / 3.14159;
    //NSLog(@"fRadians = %f   fAngle = %f", fRadians, fAngle);
    // Map Center
    CGPoint ptCenter = [mSailsMap lonLatToPointXY:[mSailsMap getViewCenter]];
    CGPoint ptLr = [mSailsMap lonLatToPointXY:geoPoint];
    CGPoint ptDelta = CGPointMake(ptLr.x - ptCenter.x, ptLr.y - ptCenter.y);
//    NSLog(@"ptDelta X = %f - %f" , ptDelta.x * cos(fRadians), ptDelta.y * sin(fRadians));
//    NSLog(@"ptDelta Y = %f + %f" , ptDelta.x * sin(fRadians), ptDelta.y * cos(fRadians));
    //NSLog(@"lonLatToPointXY : %@", NSStringFromCGPoint(testPoint));
    return CGPointMake(ptCenter.x + ptDelta.x * cos(fRadians) - ptDelta.y * sin(fRadians),
            ptCenter.y + ptDelta.x * sin(fRadians) + ptDelta.y * cos(fRadians));
}

- (void)initPopUpMenu {
    mPopupInfoView = [[PopupInfoView alloc] init];
    mPopupInfoView.delegate = self;
    mPopupInfoView.buttonColor = [UIColor blueColor];


}

- (void) onMapModeChanged
{
    SailsMapControlMode mode = [mSailsMap getMapControlMode];
    if (((mode & LocationCenterLockMode) == LocationCenterLockMode) &&
            ((mode & FollowPhoneHeagingMode) == FollowPhoneHeagingMode)) {
        [bCenter setImage:[UIImage imageNamed:@"mapmode_phoneheading"] forState:UIControlStateNormal];
    } else {
        if((mode & LocationCenterLockMode) == LocationCenterLockMode) {
            [bCenter setImage:[UIImage imageNamed:@"mapmode_selected"] forState:UIControlStateNormal];
        } else {
            [bCenter setImage:[UIImage imageNamed:@"mapmode_normal"] forState:UIControlStateNormal];

        }

    }

    if ((mode & LocationCenterLockMode) == LocationCenterLockMode)
    {
        // Lock Map
//        [self setFloorName:[mSails getFloor] Force:NO];
    }
}

- (void)zoomInTapped {
    [mSailsMap zoomIn];
}

- (void)zoomOutTapped {
    [mSailsMap zoomOut];
}
- (IBAction)tapPositioning:(id)sender {
    if(inLocating) {
        [self stopPositioningProcedure];
    } else {
        [self startPositioningProcedure];

    }
}

- (IBAction)tapFloor:(id)sender {
    NSArray *floorDescList = [mSails getFloorDescList];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    for (NSString *floorName in floorDescList) {
        [actionSheet addButtonWithTitle:floorName];
    }
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:ZpLocalizedString(@"Cancel")];
    [actionSheet showInView:self.view];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if([PFUser currentUser]==nil) {
        [self showLogInViewProcedure];
    }

}
-(void) runAccVerify {
    [self changeMode:ACCURACY_VERIFICATION];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self changeMode:NO_MODE];
    [self initPopUpMenu];
    [self initSails];
    [self iconMappingProcedure];
    [self checkCurrentUser];
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    maskLayer.path = [UIBezierPath bezierPathWithRoundedRect: accVerifyInnerView.bounds byRoundingCorners:  UIRectCornerTopRight cornerRadii: (CGSize){10.0, 10.0}].CGPath;

    accVerifyInnerView.layer.mask = maskLayer;
    // Do any additional setup after loading the view.
}

- (void)checkCurrentUser {
    NSString* projectId = [[NSUserDefaults standardUserDefaults] stringForKey:@"projectId"];
    if([PFUser currentUser]==nil) {
        [self showLogInViewProcedure];
    } else {
        PFUser *user= [PFUser currentUser];
        [self selectProjectProcedure];

    }

}

- (void)selectProjectProcedure {
    NSString* projectId = [[NSUserDefaults standardUserDefaults] stringForKey:@"projectId"];
    if(projectId!=nil&&projectId.length!=0) {
        [self fetchProjectParameter:projectId selectProjectAgainIfFail:true];
        return;
    }
    [PFObject unpinAllObjectsInBackgroundWithName:@"project" block:^(BOOL succeeded, NSError *error) {
        [CommonDefine showPleaseWaitHudToView:self.view withMSG:ZpLocalizedString(@"Progressing")];
        PFQuery *query= [[PFQuery alloc] initWithClassName:@"Project"];
        [query whereKey:@"visible" equalTo:@YES];
        [query setLimit:1000];
        [query findObjectsInBackgroundWithBlock:^(NSArray<id> *objects, NSError *error) {
            [CommonDefine hidePleaseWaitHudForView:self.view];
            if(error!=nil&&error.code!=kPFErrorObjectNotFound) {
                [CommonDefine showErrorDialog];
                [self selectProjectProcedure];
                return;
            }
            projectArray=objects;
            NSMutableArray *names= [[NSMutableArray alloc] init];
            if(error||objects.count==0) {
                [self addProjectProcedure];
                return;
            }
            for(PFObject *obj in objects) {
                [names addObject:[obj objectForKey:@"name"]];
            }
            UIViewController *controller = [[UIViewController alloc]init];
            UITableView *alertTableView;
            CGRect rect;
            if (names.count < 3) {
                rect = CGRectMake(0, 0, 272, 100);
                [controller setPreferredContentSize:rect.size];

            }
            else if (names.count < 4){
                rect = CGRectMake(0, 0, 272, 150);
                [controller setPreferredContentSize:rect.size];
            }
            else if (names.count < 5){
                rect = CGRectMake(0, 0, 272, 200);
                [controller setPreferredContentSize:rect.size];

            }
            else {
                rect = CGRectMake(0, 0, 272, 250);
                [controller setPreferredContentSize:rect.size];
            }
            alertTableView  = [[UITableView alloc]initWithFrame:rect];
            alertTableView.backgroundColor=[UIColor clearColor];
            alertTableView.delegate = self;
            alertTableView.dataSource = self;
            alertTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
            [alertTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            [controller.view addSubview:alertTableView];
            [controller.view bringSubviewToFront:alertTableView];
            [controller.view setUserInteractionEnabled:YES];
            [alertTableView setUserInteractionEnabled:YES];
            [alertTableView setAllowsSelection:YES];
            selectProjectController = [UIAlertController alertControllerWithTitle:ZpLocalizedString(@"select_project") message:nil preferredStyle:UIAlertControllerStyleAlert];
            [selectProjectController setValue:controller forKey:@"contentViewController"];
            UIAlertAction *addProjectAction = [UIAlertAction actionWithTitle:ZpLocalizedString(@"add_project") style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self addProjectProcedure];
            }];
            [selectProjectController addAction:addProjectAction];

//        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ZpLocalizedString(@"Cancel") style:UIAlertActionStyleDestructive handler:nil];
//        [selectProjectController addAction:cancelAction];
            [self presentViewController:selectProjectController animated:YES completion:nil];
        }];
    }];


}

- (void)addProjectProcedure {
    [CommonDefine showErrorDialogWithMsg:ZpLocalizedString(@"cannot_add_project_notify")];
    [self selectProjectProcedure];
}

- (void)fetchProjectParameter:(NSString *)id selectProjectAgainIfFail:(bool)fail {
    PFQuery *query = [[PFQuery alloc] initWithClassName:@"Project"];
    [query fromLocalDatastore];
    [query getObjectInBackgroundWithId:id block:^(PFObject *object, NSError *error) {
        if(error==nil&&object!=nil) {
            projectObject=object;
            [self loadProjectProcedure:projectObject];

        } else if(fail) {
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"projectId"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self selectProjectProcedure];
        }
    }];

}

- (void)loadProjectProcedure:(PFObject *)object {
    self.title=object[@"name"];
    [object pinInBackgroundWithName:@"project"];
    MenuController* menuController=(MenuController*)[self frostedViewController].menuViewController;
    [menuController setUserName:[PFUser currentUser].username
                          Email:[PFUser currentUser].email
                        IconURL:object[@"icon"]
                  backgroundURL:object[@"header_img"]];

    [[NSUserDefaults standardUserDefaults] setObject:object.objectId forKey:@"projectId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self loadBuildingProcedure:projectObject];

}

- (void)loadBuildingProcedure:(PFObject *)object {
    if(object[@"use_sails_cloud"]) {
        if(object[@"sails_cloud_token"]==nil||object[@"sails_cloud_buildingid"]==nil) {
            [CommonDefine showErrorDialogWithMsg:ZpLocalizedString(@"token_or_building_id_not_set")];
            return;
        }
        [CommonDefine showPleaseWaitHudToView:self.view];
        [mSails loadCloudBuilding:object[@"sails_cloud_token"]
                      buildingID:object[@"sails_cloud_buildingid"]
                         success:^{
                             [mSails setReverseFloorList:true];
                             [CommonDefine hidePleaseWaitHudForView:self.view];
//                             [mSails setGPSFloorLayer:@"B1"];
                             [mSails setGPSFloorLayer:object[@"gps_layer"]];
                             [mSails setGPSThresholdParameterInToOut:2 outToIn:3 powerThreshold:-75];
//                             [mSails setGPSThresholdParameterInToOut:1 outToIn:1 powerThreshold:-90];
                             [self mapViewInitial];
                             [self generateFloorSpinnerProcedure];
                         }
                         failure:^(NSError *error) {
                             [CommonDefine hidePleaseWaitHudForView:self.view];
                             [CommonDefine showErrorDialog];
                         }];

    }

}

- (void)generateFloorSpinnerProcedure {
    if([mSails getFloorNameList].count>1) {
        [bFloor setHidden:false];
        return;
    }
    [bFloor setHidden:true];

}

- (void)mapViewInitial {
    [mSailsMap loadFloorMap:[mSails getFloorNameList][0]];
    [mSailsMap setOnModeChangedBlock:^{
        [self onMapModeChanged];
    }];
    [bFloor setTitle:[mSails getFloorDescList][0] forState:UIControlStateNormal];


}
-(void) startPositioningProcedure {
    if(inLocating)
        return;
    [mSails startLocatingEngine];
    inLocating=true;

    [mSailsMap setLocatorMarkerVisible:true];
    [biPositioning setImage:[UIImage imageNamed:@"not_in_positioning"]];
    [mSailsMap setMapControlMode:FollowPhoneHeagingMode|LocationCenterLockMode];
}
-(void) stopPositioningProcedure {
    if(!inLocating)
        return;
    [mSails stopLocatingEngine];
    inLocating=false;
    [biPositioning setImage:[UIImage imageNamed:@"in_positioning"]];
    [mSailsMap setLocatorMarkerVisible:false];
    [mSailsMap setMapControlMode:GeneralMode];
}
- (void)showLogInViewProcedure {
    PFLogInViewController *logInViewController = [[PFLogInViewController alloc] init];
    logInViewController.delegate = self;
    UIView *blankRect=[[UIView alloc] initWithFrame:CGRectMake(0,
            0,
            logInViewController.logInView.logo.frame.size.width,
            logInViewController.logInView.logo.frame.size.height)];
    [blankRect setBackgroundColor:logInViewController.logInView.backgroundColor];
    [logInViewController.logInView.logo addSubview:blankRect];
    UIImageView *newLogo=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [newLogo setContentMode:UIViewContentModeScaleAspectFill];
    [newLogo setFrame:CGRectMake(0,0,logInViewController.logInView.logo.frame.size.width,logInViewController.logInView.logo.frame.size.height)];
    [logInViewController.logInView.logo addSubview:newLogo];
    PFSignUpViewController *sigUpController = [[PFSignUpViewController alloc] init];
    sigUpController.delegate=self;
    [blankRect setBackgroundColor:logInViewController.logInView.backgroundColor];
    UIView *blankRect1=[[UIView alloc] initWithFrame:CGRectMake(0,
            0,
            sigUpController.signUpView.logo.frame.size.width,
            sigUpController.signUpView.logo.frame.size.height)];
    [blankRect1 setBackgroundColor:sigUpController.signUpView.backgroundColor];

    [sigUpController.signUpView.logo addSubview:blankRect1];
    UIImageView *newLogo1=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    [newLogo1 setContentMode:UIViewContentModeScaleAspectFill];
    [newLogo1 setFrame:CGRectMake(0,0,sigUpController.signUpView.logo.frame.size.width,sigUpController.signUpView.logo.frame.size.height)];

    [sigUpController.signUpView.logo addSubview:newLogo1];
    [logInViewController setSignUpController:sigUpController];
    [self presentViewController:logInViewController animated:YES completion:nil];
}
- (void)logoutProcedure {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:ZpLocalizedString(@"confirm_to_logout")
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:ZpLocalizedString(@"yes")
                                              style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * action) {
                                                [self logout];
                                            }]];
    [alert addAction:[UIAlertAction actionWithTitle:ZpLocalizedString(@"no")
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)logout {
    [CommonDefine showPleaseWaitHudToView:self.view];
    [PFUser logOutInBackgroundWithBlock:^(NSError *error) {
        [CommonDefine hidePleaseWaitHudForView:self.view];
        if(error) {
            [CommonDefine showErrorDialog];
            return;
        }
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"projectId"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self checkCurrentUser];
        [self clearViewProcedure];
    }];

}
- (void)clearViewProcedure {
    [self changeMode:NO_MODE];
    [self stopPositioningProcedure];
    [mPopupInfoView setHidden:true];
    [mSailsMap clearMap];
    [bFloor setHidden:true];
    [self clearMeasurementTitle];

}
-(void) clearMeasurementTitle {
    labelSample.text =@"0";
    labelDeviation.text =@"-";
    labelAccuracy.text = @"-";
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark -
#pragma mark PFLogInViewControllerDelegate

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self selectProjectProcedure];

}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    // Do nothing, as the view controller dismisses itself
}

#pragma mark -
#pragma mark PFSignUpViewControllerDelegate

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self selectProjectProcedure];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    // Do nothing, as the view controller dismisses itself
}

#pragma mark - UITableViewDataSource -
const static CGFloat kCellHeight = 50;
static NSString *const kCellIdentifier = @"ResultCell";

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return projectArray.count;
}
// 取得 section 的 title
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return 0;
}
// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:kCellIdentifier];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text=((PFObject *)projectArray[indexPath.row])[@"name"];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.backgroundColor= [UIColor clearColor];
    return cell;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    projectObject=projectArray[indexPath.row];
    [self clearViewProcedure];
    if(selectProjectController)
        [selectProjectController dismissViewControllerAnimated:true completion:nil];
    [self loadProjectProcedure:projectObject];
    return;

}


// 處理 Header : 用來顯示 樓層
- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if (_floorNameList != nil && [_floorNameList count] > section)
//    {
//        NSArray* result = mSearchResultsOfFloors[_floorNameList[section]];
//        if (result != nil && [result count] > 0)
//            return 36;
//    }
    // 不能回傳 0 ，不然 有時 section 0 會消失
    return 0;
}
-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}
-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}
#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
        NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];
        NSArray *floorDescList = [mSails getFloorDescList];
        NSInteger index = [floorDescList indexOfObject:title];
        if (index != NSNotFound) {
            [mSailsMap loadFloorMap:[mSails getFloorNameList][index]];
            [bFloor setTitle:title forState:UIControlStateNormal];
        }
}
#pragma mark - PopupInfoViewDelegate -
-(void) gotoRouteSettingMapMode:(LocationRegion*) loRegion
{
}
// 點選 Navi Button
-(void) setRouteLocationRegion:(POI*) poi PopupInfoView:(PopupInfoView*) view
{
    [AccVerify Sample:mSailsMap];
    labelSample.text = [AccVerify GetSamples];
    labelDeviation.text = [AccVerify GetDeviation];
    labelAccuracy.text = [AccVerify GetAccuracy];

}
// 點選 Navi Button
-(void) ShowDetail:(POI*) poi PopupInfoView:(PopupInfoView*) view
{

}
-(void)mailComposeController:(MFMailComposeViewController*)controller
         didFinishWithResult:(MFMailComposeResult*)result
                       error:(NSError*)error
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
