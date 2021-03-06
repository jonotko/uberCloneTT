//
//  HomeController.swift
//  UberCloneTT
//
//  Created by Jonathan Agarrat on 2/24/20.
//  Copyright © 2020 Jonathan Agarrat. All rights reserved.
//

import UIKit
import Firebase
import MapKit

private let reuseIdentifier = "LocationCell"
private let annotationIdentifier = "DriverAnnotation"

private enum ActionButtonConfiguration {
    case showMenu
    case dismissActionView
    
    init() {
        self = .showMenu
    }
}

class HomeController: UIViewController {
    
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = LocationHandler.shared.locationManager
    private let inputActivationView = LocationInputActivationView()
    private let locationInputView = LocationInputView()
    private let tableView = UITableView()
    private var searchResults = [MKPlacemark]()
    private var actionButtonConfig = ActionButtonConfiguration()
    private var route: MKRoute?
    private var rideActionView = RideActionView()
    private final let rideActionViewHeight: CGFloat = 300
    
    private var user: User? {
        didSet {
            locationInputView.user = user
            if user?.accountType == .passenger {
                fetchDrivers()
                configureLocationInputActivationView()
                observeCurrentTrip()
            } else {
                observeTrips()
            }
        }
    }
    
    private var trip: Trip? {
        didSet{
            guard let user = user else { return }
            
            if user.accountType == .driver {
                guard let trip = trip else { return }
               let controller = PickupController(trip: trip)
               controller.delegate = self
               controller.modalPresentationStyle = .fullScreen
               self.present(controller, animated: true, completion: nil)
            } else {
                print("DEBUG: Show ride action view for accepted trip");
            }
        }
    }
    
    private final let locationInputViewHeight: CGFloat = 200
    
    private let actionButton: UIButton = {
           let button = UIButton(type: .system)
           button.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
           button.addTarget(self, action: #selector(actionButtonPressed), for: .touchUpInside)
           return button
       }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        enableLocationServices()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let trip = trip else { return }
        print("DEBUG:  Trip state is \(trip.state)")
    }
    
    // MARK: - Selectors
    
    @objc func actionButtonPressed() {
        switch actionButtonConfig {
        case .showMenu:
            print("DEBUG: Handel show menu...")
        case .dismissActionView:
            removeAnnotationsAndOverlays()
            
            mapView.showAnnotations(mapView.annotations, animated: true)
            
            UIView.animate(withDuration: 0.3) {
                self.inputActivationView.alpha = 1
                self.configureActionButton(config: .showMenu)
                self.animateRideActionView(shouldShow: false)
            }
            
           
        }
        
    }
    
    // MARK: - API
    
    func fetchUserData() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        Service.shared.fetchUserData(uid: currentUid) { (user) in
            self.user = user
        }
    }
    
    func fetchDrivers() {
        guard user?.accountType == .passenger else { return }
        guard let location = locationManager?.location else { return }
        Service.shared.fetchDrivers(location: location) { (driver) in
            guard let coordinate = driver.location?.coordinate else { return }
            let annotation = DriverAnnotation(uid: driver.uid, coordinate: coordinate)
            var driverVisible: Bool {
                
                self.mapView.annotations.contains(where: { annotation -> Bool in
                    guard let driverAnno = annotation as? DriverAnnotation else { return false}
                    if driverAnno.uid == driver.uid {
                        driverAnno.updateAnnotationPosition(withCoordinate: coordinate)
                       return true
                   }
                    return false
                })
                
            }
            
            if !driverVisible {
                self.mapView.addAnnotation(annotation)
            }
            
        }
    }
    
    func observeTrips(){
        Service.shared.observeTrips { (trip) in
            self.trip = trip
            print("DEBUG: Trip state is \(trip.state)")
        }
    }
    
    func observeCurrentTrip(){
        Service.shared.observeCurrentTrip { (trip) in
            print("DEBUG \(trip)")
            self.trip = trip
            
            if trip.state == .accepted {
                self.shouldPresentLoadingView(false)
            }
        }
    }
    
    func checkIfUserIsLoggedIn()  {
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User not logged in")
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            print("DEBUG: User id is \(Auth.auth().currentUser?.uid)")
            configure()
    }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                           let nav = UINavigationController(rootViewController: LoginController())
                           nav.modalPresentationStyle = .fullScreen
                           self.present(nav, animated: true, completion: nil)
                       }
        } catch {
            print("DEBUG: Error signing out")
        }
    }
    
    // MARK: - Helper functions
        
        func configure() {
            configureUI()
            fetchUserData()
        }
    
    fileprivate func configureActionButton(config: ActionButtonConfiguration) {
        switch config {
        case .showMenu:
            self.actionButton.setImage(#imageLiteral(resourceName: "baseline_menu_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            self.actionButtonConfig = .showMenu
        case .dismissActionView:
            actionButton.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp").withRenderingMode(.alwaysOriginal), for: .normal)
            actionButtonConfig = .dismissActionView
        }
    }
    
    func configureRideActionView() {
           view.addSubview(rideActionView)
        rideActionView.delegate = self
           rideActionView.frame = CGRect(x: 0, y: view.frame.height,
                                         width: view.frame.width, height: rideActionViewHeight)
       }
    
    func configureUI() {
        
        configureMapView()
        configureRideActionView()
        view.addSubview(actionButton)
        actionButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingTop: 16, paddingLeft: 20, width: 30, height: 30)
        
       
        
        
        configureTableView()
    }
    
    func configureLocationInputActivationView(){
        view.addSubview(inputActivationView)
               inputActivationView.centerX(inView: view)
               
               inputActivationView.setDimensions(height: 50, width: view.frame.width - 64)
               inputActivationView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 60)
               
               inputActivationView.alpha = 0
               inputActivationView.delegate = self
        
        
        UIView.animate(withDuration: 2) {
            self.inputActivationView.alpha = 1
        }
    }
    
    func configureMapView() {
        view.addSubview(mapView)
               mapView.frame = view.frame
               mapView.showsUserLocation = true
               mapView.userTrackingMode = .follow
                mapView.delegate = self
    }
    
    func configureLocationInputView(){
        locationInputView.delegate = self
        view.addSubview(locationInputView)
               locationInputView.anchor(top: view.topAnchor, left: view.leftAnchor,
                                        right: view.rightAnchor, height: 200)
        
        locationInputView.alpha = 0
              
              UIView.animate(withDuration: 0.5, animations: {
                  self.locationInputView.alpha = 1
              }) { _ in
                UIView.animate(withDuration: 0.3) {
                     self.tableView.frame.origin.y = self.locationInputViewHeight
                }
              }
    }
    
    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(LocationCell.self, forCellReuseIdentifier: reuseIdentifier)
        
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        
        let height = view.frame.height - locationInputViewHeight
        tableView.frame = CGRect(x: 0, y: view.frame.height,
                                       width: view.frame.width, height: height)
        
        view.addSubview(tableView)
    }
    
    func dismissLocationView(completion: ((Bool) -> Void)? = nil){
        
        UIView.animate(withDuration: 0.5, animations: {
             self.locationInputView.alpha = 0
                       self.tableView.frame.origin.y = self.view.frame.height
                       self.locationInputView.removeFromSuperview()
        }, completion: completion)
        
    }
    
    func animateRideActionView(shouldShow: Bool, destination: MKPlacemark? = nil) {
        
        let yOrigin = shouldShow ? self.view.frame.height - self.rideActionViewHeight : self.view.frame.height
        
        if shouldShow {
            guard let destination = destination else { return }
            rideActionView.destination = destination
        }
        
        UIView.animate(withDuration: 0.3) {
            self.rideActionView.frame.origin.y = yOrigin
        }
    }
    
    
}

// MARK: - Map Helper Functions

private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        var results = [MKPlacemark]()
        
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            
            response.mapItems.forEach({ item in
                results.append(item.placemark)
            })
            
            completion(results)
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem) {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        directionRequest.calculate { (response, error) in
            guard let response = response else { return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else { return }
            self.mapView.addOverlay(polyline)
        }
    }
    
     func removeAnnotationsAndOverlays() {
           mapView.annotations.forEach { (annotation) in
               if let anno = annotation as? MKPointAnnotation {
                   mapView.removeAnnotation(anno)
               }
           }
           
           if mapView.overlays.count > 0 {
               mapView.removeOverlay(mapView.overlays[0])
           }
       }
    
}

// MARK: - MKMapViewDelegate

extension HomeController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? DriverAnnotation {
            
            let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            view.image = #imageLiteral(resourceName: "chevron-sign-to-right")
            return view
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlue
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}

// MARK: - LocationServices

extension HomeController {
    
    func enableLocationServices() {
        
        switch CLLocationManager.authorizationStatus() {
            
        case .notDetermined:
            print("DEBUG: Not determined...")
            locationManager?.requestWhenInUseAuthorization()
        case .restricted, .denied:
             print("DEBUG: Denied...")
           break
        case .authorizedAlways:
            print("DEBUG: Auth Always...")
            locationManager?.startUpdatingLocation()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        case .authorizedWhenInUse:
            print("DEBUG: Auth When in use...")
            locationManager?.requestAlwaysAuthorization()
        @unknown default:
            break
        }
       
    }
    
}

// MARK: - LocationInputActivationView Delegate

extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        inputActivationView.alpha = 0
        configureLocationInputView()
    }
}


// MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate {
    
    func dismissLocationInputView() {
        
        dismissLocationView { _ in
            UIView.animate(withDuration: 0.5) {
                 self.inputActivationView.alpha = 1
            }
        }
    }
    
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { (placemarks) in
            self.searchResults = placemarks
            self.tableView.reloadData()
        }
    }
}

// MARK: - UITableViewDelegate/DataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "TEST"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            print("DEBUG: HI")
            return 2
        }
        
        return searchResults.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! LocationCell
        
        if indexPath.section == 1{
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPlacemark = searchResults[indexPath.row]
        configureActionButton(config: .dismissActionView)
        
        let destination = MKMapItem(placemark: selectedPlacemark)
        generatePolyline(toDestination: destination)
        
        dismissLocationView { (Bool) in
            let annotation = MKPointAnnotation()
            annotation.coordinate = selectedPlacemark.coordinate
            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
             let annotations = self.mapView.annotations.filter({ !$0.isKind(of: DriverAnnotation.self) })
            
            self.mapView.zoomToFit(annotations: annotations)
            
            self.animateRideActionView(shouldShow: true, destination: selectedPlacemark)
        }
    }
    
   
}

// MARK: - RideActionViewDelegate

extension HomeController: RideActionViewDelegate {
    func uploadTrip(_ view: RideActionView) {
        guard let pickupCoordinates = locationManager?.location?.coordinate else { return }
        guard let destinationCoordinates = view.destination?.coordinate else { return }
         
        shouldPresentLoadingView(true, message: "Finding you a ride")
        Service.shared.uploadTrip(pickupCoordinates, destinationCoordinates) { (error, ref) in
            
            if let error = error {
                print("DEBUG: Failed to upload trip with error")
                return
            }
            
            print("DEBUG: Did upload trip successfully")
            UIView.animate(withDuration: 0.3) {
                self.rideActionView.frame.origin.y = self.view.frame.height
            }
        }
    }
    
    

}

// MARK: - Pickupcontroller Delegate

extension HomeController: PickupControllerDelegate {
    func didAcceptTrip(_ trip: Trip) {
        self.trip?.state = .accepted
        self.dismiss(animated: true, completion: nil)
    }
    
   
}
