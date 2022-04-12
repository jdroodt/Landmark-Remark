//
//  LandingViewController.swift
//  Landmark Remark
//
//  Created by JD on 11/4/2022.
//

import UIKit


// Segmented control options
enum SegmentOption: Int {
    case map = 0
    case list = 1
}


class MainMenuViewController: UIViewController {
    
    let segmentedControl = UISegmentedControl(items: ["map", "search"])
    private var map: MapViewController?
    private var list: ListViewController?
    
    
    // MARK: - Setup
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // SegmentedControl and NavBar setup
        let font = UIFont.systemFont(ofSize: 21)
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        segmentedControl.setWidth(100, forSegmentAt: SegmentOption.list.rawValue)
        segmentedControl.setWidth(100, forSegmentAt: SegmentOption.map.rawValue)
        segmentedControl.addTarget(self, action: #selector(selectedTabChanged), for: .valueChanged)
        self.navigationItem.titleView = segmentedControl
        let profileButton = UIBarButtonItem(image: UIImage(systemName: "person.crop.circle", size: 25),
                                            style: .plain,
                                            target: self,
                                            action: #selector(profilePressed))
        profileButton.tintColor = .systemRed
        self.navigationItem.rightBarButtonItem = profileButton
        
        // Container View setup
        // Map View
        map = MapViewController()
        addViewControllerToContainer(map)
        
        // List View
        list = ListViewController()
        addViewControllerToContainer(list)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // SegmentControl's default start
        segmentedControl.selectedSegmentIndex = SegmentOption.map.rawValue
        selectedTabChanged()
        
        // Start listening to Database
        DatabaseUtils.startListeningToNotes()
    }
    
    fileprivate func addViewControllerToContainer(_ viewController: UIViewController?) {
        
        // Layout and setup of ChildViewControllers
        if let vc = viewController {
            self.addChild(vc)
            self.view.addSubview(vc.view)
            vc.view.frame = self.view.frame
            vc.didMove(toParent: self)
            vc.view.isHidden = true
        } else {
            // Note: Remember to initialize the ViewController before trying to lay it out.
            print("Warning: Container View Controller must be initialized before adding to ")
        }
    }
    
    
    // MARK: - Actions
    
    @objc private func selectedTabChanged() {
        
        switch segmentedControl.selectedSegmentIndex {

        // List selected
        case SegmentOption.list.rawValue:
            list?.view.isHidden = false
            map?.view.isHidden = true
            
        // Map selected
        case SegmentOption.map.rawValue:
            list?.view.isHidden = true
            map?.view.isHidden = false
            list?.viewWillDisappear(false)
            
        default:
            // Do nothing. (Code may need to be updated to include new functionality)
            print("Warning: SegmentedController was switched to a value outside of intended range!")
            break
        }
    }
    
    @objc private func profilePressed() {
        showInput(header: "Enter Username", placeholderText: "Username") { username in
            if let username = username, !username.isEmpty {
                DatabaseUtils.setCurrentUsername(username)
                self.showMessage("Welcome \(username)")
            } else {
                self.showMessage("Username can't be empty")
            }
        }
    }
    
}


