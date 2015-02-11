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

- (void)verificaPermissaoDeLocalizacao
{
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"verificapermissaodelocalizacao",self.textView.text];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    
    if(![CLLocationManager locationServicesEnabled])
    {
        self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"!locationServicesEnabled",self.textView.text];
    }
    if(![CLLocationManager isMonitoringAvailableForClass:[CLRegion class]])
    {
        self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"!isMonitoringAvailableForClass-ClRegion",self.textView.text];
    }
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
       [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted  )
    {
        self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"!authorizationStatus-ClRegion",self.textView.text];
    }
    
    if (IS_OS_8_OR_LATER)
    {
        self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"ios8 requestalwaysauthorization",self.textView.text];
        [self.locationManager requestAlwaysAuthorization];//requestWhenInUseAuthorization];
    }
    
    if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
    {
        if (IS_OS_8_OR_LATER)
        {
            self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"ios8 solicita autorização caso tenha negado acima",self.textView.text];
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
            self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"<ios8 alerta sobre não ter serviço de localização",self.textView.text];
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
        self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"já está autorizado",self.textView.text];
    }
    
    [self iniciaMonitoramento];
    
}

- (void)iniciaMonitoramento
{
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"iniciamonitoramento",self.textView.text];
    
    [self.locationManager stopMonitoringForRegion:self.regiao];
    [self.locationManager startMonitoringForRegion:self.regiao];
    
    NSArray *regions = [self.locationManager.monitoredRegions allObjects];
    if (!regions.count)
    {
        self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"nenhuma região",self.textView.text];
    }
    else
    {
        self.textView.text = [NSString stringWithFormat:@"%lu %@\n%@",(unsigned long)[regions count],@"regioes",self.textView.text];
        
        for (int i = 0; i < [regions count]; i++)
        {
            CLRegion *region = [regions objectAtIndex:i];
            //[self.locationManager startMonitoringForRegion:region];
            
            self.textView.text = [NSString stringWithFormat:@"região %@\n%@",[region identifier],self.textView.text];
            
        }
    }
}

#pragma mark - ViewController life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.textView.text = [NSString stringWithFormat:@"%@\n%@",@"didload",self.textView.text];
    
    [self verificaPermissaoDeLocalizacao];
    
    /*UILocalNotification *notification = [[UILocalNotification alloc] init];
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
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];*/
    
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
    
    self.textView.text = [NSString stringWithFormat:@"%@ %f,%f %@\n%@",@"updatelocations",coordenadas.latitude, coordenadas.longitude,estaDentro,self.textView.text];
    
}


- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
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
    
    self.textView.text = [NSString stringWithFormat:@"EnterRegion %@\n%@",[region identifier],self.textView.text];
    
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
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
    
    self.textView.text = [NSString stringWithFormat:@"ExiteRegion %@\n%@",[region identifier],self.textView.text];
    
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    self.textView.text = [NSString stringWithFormat:@"StartMonitoringForRegion %@\n%@",[region identifier],self.textView.text];
    
}

#pragma mark - Notification center

@end
