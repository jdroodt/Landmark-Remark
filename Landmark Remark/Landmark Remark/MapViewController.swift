//
//  MapViewController.swift
//  Landmark Remark
//
//  Created by JD on 11/4/2022.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    private let map = MKMapView()
    private let locationManager = CLLocationManager()
    private var currentLng: CGFloat?
    private var currentLat: CGFloat?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // Reload annotation markers when new Notes come from the backend
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadMap),
                                               name: Notification.Name(DatabaseUtils.keyReloadNotes),
                                               object: nil)
    }
    
    func setupView() {
        self.view.backgroundColor = .white
        
        // Map
        map.delegate = self
        map.mapType = .standard
        map.isZoomEnabled = true
        map.isScrollEnabled = true
        map.showsUserLocation = true
        self.view.addSubview(map)
        map.translatesAutoresizingMaskIntoConstraints = false
        map.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        map.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        map.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        map.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        
        // GPS
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        // Note Button
        let noteButtonDiameter: CGFloat = 80
        let noteButton = UIButton()
        noteButton.backgroundColor = .systemRed
        noteButton.setImage(UIImage(systemName: "pencil.and.outline", size: 40), for: .normal)
        noteButton.tintColor = .white
        noteButton.clipsToBounds = true
        noteButton.layer.cornerRadius = noteButtonDiameter/2.0
        noteButton.layer.borderColor = UIColor.white.cgColor
        noteButton.layer.borderWidth = 3
        noteButton.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        self.view.addSubview(noteButton)
        noteButton.translatesAutoresizingMaskIntoConstraints = false
        noteButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        noteButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -16).isActive = true
        noteButton.widthAnchor.constraint(equalToConstant: noteButtonDiameter).isActive = true
        noteButton.heightAnchor.constraint(equalToConstant: noteButtonDiameter).isActive = true
    }
    
    
    // MARK: - Actions
    
    @objc func addNote() {
        // Ensure we have a location to save the message to
        guard let currentLat = currentLat, let currentLng = currentLng else {
            showMessage("Unable to find current location", message: "Please ensure Landmark Remark has access to Location from the Settings app, under permissions and try again")
            return
        }
        
        // Ensure the user has a username
        guard DatabaseUtils.getCurrentUsername() != nil else {
            showMessage("No username", message: "You have to be signed in to save a note. You can sign in from the profile button in the top right hand corner")
            return
        }

        // Get message text
        showInput(header: "Enter Message", placeholderText: "Message") { noteText in
            if let noteText = noteText, !noteText.isEmpty {
                // Save entire note
                DatabaseUtils.addNote(text: noteText, lat: currentLat, lng: currentLng) { success in
                    if !success {
                        self.showMessage("Failed to save message", message: "Please check internet connection and try again")
                    }
                }
            } else {
                self.showMessage("Message can't be empty")
            }
        }
    }
    
    
    // MARK: - MKMap
    
    @objc func reloadMap() {
        print("Reloading map: \(DatabaseUtils.shared.notes.count) notes found")
        
        // Clear previous annotations
        map.removeAnnotations(map.annotations)
        
        // Add annotations and callout info
        for note in DatabaseUtils.shared.notes {
            let pin = MKPointAnnotation()
            let centerCoordinate = CLLocationCoordinate2D(latitude: note.location.latitude, longitude: note.location.longitude)
            pin.coordinate = centerCoordinate
            pin.title = "\(note.username)"
            pin.subtitle = "\(note.text)"
            map.addAnnotation(pin)
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Distinguish between Note and User
        guard !annotation.isKind(of: MKUserLocation.self) else { return nil }
        
        let noteIdentifier = "note_identifier"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: noteIdentifier)
        if annotationView == nil {
            // Create annotation for the first time
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: noteIdentifier)
            if let aView = annotationView as? MKMarkerAnnotationView {
                aView.markerTintColor = .systemRed
            }
            
        } else {
            // Reuse
            annotationView!.annotation = annotation
        }
        
        annotationView?.canShowCallout = false
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let anno = view.annotation, let name = anno.title, let text = anno.subtitle {
            showMessage("\(name ?? "unknown user") says", message: text)
        }
        
    }
    
    
    // MARK: - Location Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        
        // Zoom to where the user is
        if currentLng == nil && currentLat == nil {
            let location = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
            let region = MKCoordinateRegion( center: location.coordinate, latitudinalMeters: CLLocationDistance(exactly: 5000)!, longitudinalMeters: CLLocationDistance(exactly: 5000)!)
            map.setRegion(map.regionThatFits(region), animated: true)
        }
        
        currentLat = locValue.latitude
        currentLng = locValue.longitude
    }

}
