import CoreData
import UIKit
import MapKit
import CoreLocation

class mapsViewController: UIViewController , MKMapViewDelegate , CLLocationManagerDelegate {

    @IBOutlet weak var isimTextField: UITextField!
    @IBOutlet weak var notTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var secilenLongitude = Double()
    var secilenLatitude = Double()
    var secilenIsim = ""
    var secilenId : UUID?
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLongitude = Double()
    var annotationLatitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(konumSec(gestureRecognizer: )))
        gestureRecognizer.minimumPressDuration = 3
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if secilenIsim != "" {
            // core datadan verileri çek
            if let uuidString = secilenId?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Yer")
                fetchRequest.predicate =  NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                do {
                    let sonuclar = try context.fetch(fetchRequest)
                    if sonuclar.count > 0 {
                        for sonuc in sonuclar as! [NSManagedObject] {
                            
                            if let isim = sonuc.value(forKey: "isim") as? String {
                               annotationTitle = isim
                                
                                if let not = sonuc.value(forKey: "not") as? String {
                                    annotationSubtitle  = not
                                }
                                if let latitude = sonuc.value(forKey: "latitude") as? Double {
                                    annotationLatitude = latitude
                                }
                                
                                 if let longitude = sonuc.value(forKey: "longitude") as? Double {
                                     annotationLongitude = longitude
                                 }
                                let annotation = MKPointAnnotation()
                                annotation.subtitle = annotationSubtitle
                                annotation.title = annotationTitle
                                let coordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                annotation.coordinate = coordinate
                                mapView.addAnnotation(annotation)
                                isimTextField.text = annotationTitle
                                notTextField.text = annotationSubtitle
                                
                                locationManager.stopUpdatingLocation()
                                let span = MKCoordinateSpan(latitudeDelta: 0.1 , longitudeDelta: 0.1)
                                let region = MKCoordinateRegion(center: coordinate , span: span)
                                mapView.setRegion(region, animated: true)
                            }
                        }
                    }
                }
                catch {
                    print("hata")
                }
            }
        }
        else {
             
        }
    }
    @objc func konumSec (gestureRecognizer : UILongPressGestureRecognizer) {
        
        if gestureRecognizer.state == .began {
            let dokunulanNokta = gestureRecognizer.location(in: mapView)
            let dokunulanKoordinat = mapView.convert(dokunulanNokta, toCoordinateFrom: mapView)
            
            secilenLatitude = dokunulanKoordinat.latitude
            secilenLongitude = dokunulanKoordinat.longitude
            
            let annoation = MKPointAnnotation()
            annoation.coordinate = dokunulanKoordinat
            annoation.title =  isimTextField.text
            annoation.subtitle = notTextField.text
            mapView.addAnnotation(annoation)
            
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0].coordinate.latitude)
        //print(locations[0].coordinate.longitude)
        let location = CLLocationCoordinate2D.init(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
    }
    
    @IBAction func kaydetButtonu(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let yeniYer = NSEntityDescription.insertNewObject(forEntityName: "Yer", into: context)
        yeniYer.setValue(isimTextField.text, forKey: "isim")
        yeniYer.setValue(notTextField.text, forKey: "not")
        yeniYer.setValue(UUID() , forKey: "id")
        yeniYer.setValue(secilenLatitude, forKey: "latitude")
        yeniYer.setValue(secilenLongitude, forKey: "longitude")
        
        do {
            try context.save()
            print("kayıt edildi ")
        }
        catch {
            print("hata")
        }
    }
    
}

