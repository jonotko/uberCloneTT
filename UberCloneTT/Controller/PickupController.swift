//
//  PickupController.swift
//  UberCloneTT
//
//  Created by Jonathan Agarrat on 5/3/20.
//  Copyright © 2020 Jonathan Agarrat. All rights reserved.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: class {
    func didAcceptTrip(_ trip: Trip)
}

class PickupController: UIViewController {
    
    // MARK: - Properties
    private let mapView = MKMapView()
    
    let trip: Trip
    weak var delegate: PickupControllerDelegate?
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_clear_white_36pt_2x").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleDismissal), for: .touchUpInside)
        return button
    }()
    
    private let pickupLabel: UILabel = {
           let label = UILabel()
           label.text = "Would you like to pickup this passsenger?"
           label.font = UIFont.systemFont(ofSize: 16)
           label.textColor = .white
           return label
       }()
    
    private let acceptTripButton: UIButton = {
           let button = UIButton(type: .system)
           button.addTarget(self, action: #selector(handleAcceptTrip), for: .touchUpInside)
           button.backgroundColor = .white
           button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
           button.setTitleColor(.black, for: .normal)
           button.setTitle("ACCEPT TRIP", for: .normal)
           return button
       }()
    
    // MARK: - Lifecycle
    
    init(trip: Trip){
        self.trip = trip
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("DEBUG: Passenger UID is \(trip.passengerUid)")
        // Do any additional setup after loading the view.
        configureUI()
        configureMapView()
    }
    


    // MARK: - Selectors
    @objc func handleDismissal() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleAcceptTrip() {
        Service.shared.acceptTrip(trip: trip) { (error, ref) in
            self.delegate?.didAcceptTrip(self.trip)
        }
    }
    // MARK: - API
    
    // MARK: - Helper functions
    func configureMapView() {
        let region = MKCoordinateRegion(center: trip.pickupCoordinates, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: false)
        
        let anno = MKPointAnnotation()
        anno.coordinate = trip.pickupCoordinates
        mapView.addAnnotation(anno)
        mapView.selectAnnotation(anno, animated: true)
    }
    
   func configureUI() {
        view.backgroundColor = .backgroundColor
        
        view.addSubview(cancelButton)
        cancelButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor,
                            paddingLeft: 16)
        
        view.addSubview(mapView)
        mapView.setDimensions(height: 270, width: 270)
        mapView.layer.cornerRadius = 270/2
        mapView.centerX(inView: view)
        mapView.centerY(inView: view, constant: -124)
        
        view.addSubview(pickupLabel)
        pickupLabel.centerX(inView: view)
        pickupLabel.anchor(top: mapView.bottomAnchor, paddingTop: 16)
        
        view.addSubview(acceptTripButton)
        acceptTripButton.anchor(top: pickupLabel.bottomAnchor, left: view.leftAnchor,
                                right: view.rightAnchor, paddingTop: 16, paddingLeft: 32,
                                paddingRight: 32, height: 50)
        
    
    }
}
