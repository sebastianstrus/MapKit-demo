//
//  ViewController.swift
//  MapKitDemo
//
//  Created by Sebastian Strus on 2022-01-23.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate
{
    
    @IBOutlet weak var mapView: MKMapView!
    
    var route = [CLLocationCoordinate2D](/*...an array of coordinates...*/)
    var polyline = MKPolyline()//(coordinates: [], count: 2)
    
    
    var me = Point(title: "Me", imageName: "me", placeLatitude: 57.6888, placeLongitude: 11.9788)
    var cevt = Point(title: "Cevt", imageName: "cevt", placeLatitude: 57.710990, placeLongitude: 11.947730)
    var points: [Point]!
    
    var thumbnailImageByAnnotation = [NSValue : UIImage]()
    
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        points = [me, cevt]
        
        for meal in points {
            let location = CLLocationCoordinate2D(latitude: meal.placeLatitude, longitude: meal.placeLongitude)
            route.append(location)
        }
        polyline = MKPolyline(coordinates: route, count: 2)
        setupMapView()
        
        addImageAnnotations()
        
        locationManager = CLLocationManager()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setupMapView() {
        mapView.delegate = self
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    // MARK: - CLLocationManagerDelegate functions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
            mapView.setRegion(region, animated: true)
            locationManager.stopUpdatingLocation()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseID = "myAnnotationView"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView?.canShowCallout = true
        }
        /// Set the "pin" image of the annotation view
        annotationView?.image = getThumbnailForAnnotation(annotation: annotation)
        annotationView?.layer.borderWidth = 2
        annotationView?.layer.borderColor = UIColor.darkGray.cgColor
        return annotationView
    }
    
    // MARK: - Helpers
    func getThumbnailForAnnotation(annotation : MKAnnotation) -> UIImage?{
        return thumbnailImageByAnnotation[NSValue(nonretainedObject: annotation)]
    }
    
    func scaleImage(image: UIImage, maximumWidth: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let cgImage: CGImage = image.cgImage!.cropping(to: rect)!
        return UIImage(cgImage: cgImage, scale: image.size.width / maximumWidth, orientation: image.imageOrientation)
    }
    
    func addImageAnnotations() {
        for meal in (points) {
            let coordinate = CLLocationCoordinate2D(latitude: meal.placeLatitude, longitude: meal.placeLongitude)
            let  annotation = MKPointAnnotation()
            DispatchQueue.global(qos: .userInitiated).async {
                DispatchQueue.main.async {
                    var image = UIImage(named: meal.imageName)
                    image = self.scaleImage(image: image!, maximumWidth: 50)
                    self.thumbnailImageByAnnotation[NSValue(nonretainedObject: annotation)] = image
                    self.mapView(self.mapView, viewFor: annotation)?.annotation = annotation
                    annotation.coordinate = coordinate
                    
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
            self.createPath(sourceLocation: CLLocationCoordinate2D(latitude: self.me.placeLatitude, longitude: self.me.placeLongitude), destinationLocation: CLLocationCoordinate2D(latitude: self.cevt.placeLatitude, longitude: self.cevt.placeLongitude))
        
        
        

    }
    

    
    func createPath(sourceLocation : CLLocationCoordinate2D, destinationLocation : CLLocationCoordinate2D) {
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation, addressDictionary: nil)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation, addressDictionary: nil)
        
        
        let sourceMapItem = MKMapItem(placemark: sourcePlaceMark)
        let destinationItem = MKMapItem(placemark: destinationPlaceMark)

        
        let directionRequest = MKDirections.Request()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationItem
        //directionRequest.transportType = .automobile
        
        let direction = MKDirections(request: directionRequest)
        
        
        direction.calculate { (response, error) in
            guard let response = response else {
                if let error = error {
                    print("ERROR FOUND : \(error.localizedDescription)")
                }
                return
            }
            
            let route = response.routes[0]
            self.mapView.addOverlay(route.polyline, level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            
            self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
            
        }
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let rendere = MKPolylineRenderer(overlay: overlay)
        rendere.lineWidth = 5
        rendere.strokeColor = .systemBlue
        
        return rendere
    }
    

    
}





struct Point {
    var title: String
    var imageName: String
    var placeLatitude: Double
    var placeLongitude: Double
    
    init(title: String,
         imageName: String,
         placeLatitude: Double,
         placeLongitude: Double) {
        self.title = title
        self.imageName = imageName
        self.placeLatitude = placeLatitude
        self.placeLongitude = placeLongitude
    }
}

