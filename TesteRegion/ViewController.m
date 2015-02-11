//
//  ViewController.m
//  TesteRegion
//
//  Created by Elis Nunes Ficos on 11/02/15.
//  Copyright (c) 2015 Casa da Árvore. All rights reserved.
//

#import "ViewController.h"
#import <MapKit/MapKit.h>

@interface ViewController ()<CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (strong, nonatomic) CLCircularRegion *regiao;

@end

@implementation ViewController

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#pragma mark - Getters overriders

- (CLLocationManager *)locationManager
{
    if(!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        [_locationManager startUpdatingLocation];
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    }
    return _locationManager;
}

- (CLCircularRegion *)regiao
{
    if(!_regiao)
    {
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(-16.620842, -49.254790);
        CLCircularRegion *novaRegiao = [[CLCircularRegion alloc] initWithCenter:location radius:50 identifier:@"CasaElis"];
        _regiao = novaRegiao;
    }
    return _regiao;
}

#pragma mark - Setters overriders

#pragma mark - Designated initializers

#pragma mark - Public methods

#pragma mark - Private methods

- (void)escreveLog:(NSString *)log
{
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",log,self.textView.text];
}

- (void)verificaPermissaoDeLocalizacao
{
    [self escreveLog:@"verificapermissaodelocalizacao"];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    if(![CLLocationManager locationServicesEnabled])
    {
        [self escreveLog:@"!locationServicesEnabled"];
    }
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
    {
        [self escreveLog:@"!isMonitoringAvailableForClass-ClRegion"];
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        [self escreveLog:@"!authorizationStatus-ClRegion"];
    }
    
    if (IS_OS_8_OR_LATER)
    {
        [self escreveLog:@"ios8 requestalwaysauthorization"];
        [self.locationManager requestAlwaysAuthorization];//requestWhenInUseAuthorization];
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        if (IS_OS_8_OR_LATER)
        {
            [self escreveLog:@"ios8 solicita autorização caso tenha negado acima"];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Onde você está?"
                                                                           message:@"Ative sua localização para você saber exatamente a distância que está da TecnoshowComigo."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ativarLocalizacao = [UIAlertAction actionWithTitle:@"Ativar Localização"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * action) {
                                                                          [[UIApplication sharedApplication] openURL:[NSURL  URLWithString:UIApplicationOpenSettingsURLString]];
                                                                      }];
            
            UIAlertAction *continuarSemLocalizacao = [UIAlertAction actionWithTitle:@"Depois"
                                                                              style:UIAlertActionStyleDefault
                                                                            handler:^(UIAlertAction * action) {
                                                                                
                                                                            }];
            
            [alert addAction:continuarSemLocalizacao];
            [alert addAction:ativarLocalizacao];
            
            [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            [self escreveLog:@"<ios8 alerta sobre não ter serviço de localização"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Onde você está?"
                                                            message:@"Ative sua localização para você saber exatamente a distância que está da TecnoshowComigo. Vá para sua tela inicial > Ajustes > Privacidade > Serv. Localização e ative o TecnoshowComigo."
                                                           delegate:self
                                                  cancelButtonTitle:@"Depois"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        [self escreveLog:@"já está autorizado"];
    }
    
    [self iniciaMonitoramento];
    
}

- (void)iniciaMonitoramento
{
    [self escreveLog:@"iniciamonitoramento"];
    
    [self escreveLog:@"stopMonitoringForRegion"];
    [self.locationManager stopMonitoringForRegion:self.regiao];

    [self escreveLog:@"startMonitoringForRegion"];
    [self.locationManager startMonitoringForRegion:self.regiao];
    
    [self verificaRegioes];
}

- (void)verificaRegioes
{
    NSArray *regions = [self.locationManager.monitoredRegions allObjects];
    if (!regions.count)
    {
        [self escreveLog:@"nenhuma região"];
    }
    else
    {
        [self escreveLog:[NSString stringWithFormat:@"%lu %@ sendo monitorada(s)",(unsigned long)[regions count],[regions count]==1?@"regiao":@"regiões"]];
        
        for (int i = 0; i < [regions count]; i++)
        {
            CLRegion *region = [regions objectAtIndex:i];
            //[self.locationManager startMonitoringForRegion:region];
            
            [self escreveLog:[NSString stringWithFormat:@"região %@",[region identifier]]];
            
        }
    }
}

#pragma mark - ViewController life cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self escreveLog:@"didload"];
    
    [self verificaPermissaoDeLocalizacao];
    
}

#pragma mark - Overriden methods

#pragma mark - Target/Actions

#pragma mark - Delegates

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocationCoordinate2D coordenadas = manager.location.coordinate;
    
    NSString *estaDentro;
    CLLocationCoordinate2D theLocationCoordinate = [[self.locationManager location] coordinate];
    BOOL doesItContainMyPoint = [self.regiao containsCoordinate:theLocationCoordinate];
    if(doesItContainMyPoint)
    {
        estaDentro = @"ESTÁ DENTRO";
    }
    else
    {
        estaDentro = @"NÃO ESTÁ";
    }
    
    [self escreveLog:[NSString stringWithFormat:@"updatelocations %f,%f %@",coordenadas.latitude, coordenadas.longitude, estaDentro]];
    
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    [self escreveLog:[NSString stringWithFormat:@"EnterRegion %@",[region identifier]]];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Enter region (push)";
    notification.soundName = UILocalNotificationDefaultSoundName;
    NSArray *keyss = @[
                       @"titulo",
                       @"mensagem"
                       ];
    NSArray *objetoss = @[
                          @"push",
                          @"enter region."
                          ];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objetoss forKeys:keyss];
    notification.userInfo = dic;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    [self escreveLog:[NSString stringWithFormat:@"ExiteRegion %@",[region identifier]]];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Exit region (push)";
    NSArray *keyss = @[
                       @"titulo",
                       @"mensagem"
                       ];
    NSArray *objetoss = @[
                          @"push",
                          @"exit region."
                          ];
    NSDictionary *dic = [NSDictionary dictionaryWithObjects:objetoss forKeys:keyss];
    notification.userInfo = dic;
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    [self escreveLog:[NSString stringWithFormat:@"StartMonitoringForRegion %@",[region identifier]]];
    [self verificaRegioes];
}


#pragma mark - Notification center

@end
