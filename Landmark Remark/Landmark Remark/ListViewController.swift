//
//  ListViewController.swift
//  Landmark Remark
//
//  Created by JD on 11/4/2022.
//

import UIKit
import MapKit
import CoreLocation

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let keyCellIdentifier = "ListCellIdentifier"
    
    private var filteredNotes: [Note] = DatabaseUtils.shared.notes
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        // Reload and sort notes come from the backend
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sortNotesAndReload),
                                               name: Notification.Name(DatabaseUtils.keyReloadNotes),
                                               object: nil)
        
        // Keyboard Changes
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame(_:)), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        
        // Search Bar
        searchBar.delegate = self
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "Search notes"
        self.view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        searchBar.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 100).isActive = true
        
        // TableView
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: keyCellIdentifier)
        tableView.keyboardDismissMode = .interactive
        self.view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
    }
    
    // Create an array of notes that include filtered values
    @objc private func sortNotesAndReload() {
        // Skip the work if we know we're not filtering
        guard let currentSearchFilter = currentSearchFilter, currentSearchFilter != "" else {
            filteredNotes = DatabaseUtils.shared.notes
            self.tableView.reloadData()
            return
        }
        
        filteredNotes.removeAll()
        for note in DatabaseUtils.shared.notes {
            if note.username.lowercased().contains(currentSearchFilter.lowercased()) {
                filteredNotes.append(note)
                continue
            }
            if note.text.lowercased().contains(currentSearchFilter.lowercased()) {
                filteredNotes.append(note)
            }
        }
        
        self.tableView.reloadData()
    }
    
    
    // MARK: - TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: keyCellIdentifier) {
            let thisNote = filteredNotes[indexPath.row]
            cell.selectionStyle = .none
            
            var content = cell.defaultContentConfiguration()
            content.text = thisNote.username
            content.secondaryText = "loading..."
            
            /// Note: bug - When setting up a cell we can't rely on completion handlers to update the correct cell. ie - when you scroll really fast the wrong cell might be given the old data.
            /// I ran out of time but I would have liked to create a custom cell that stores the index.row and compares the cell's saved onboard index.row to the current one from this delegate.
            ///  Then I would have only updated if they matched - but it's such a quick API from MapKit that I'll have to pick my battles.
            let address = CLGeocoder.init()
            address.reverseGeocodeLocation(CLLocation.init(latitude: thisNote.location.latitude, longitude: thisNote.location.longitude)) { (places, error) in
                if error == nil {
                    if let place = places?.first {
                        content.secondaryText = place.locality
                        cell.contentConfiguration = content
                    }
                }
            }

            cell.contentConfiguration = content
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Note: I would have loved to create a protocol on MainMenu and redirect the user to the map screen and zoom to the location of the annotation but didn't due to time limitations
        showMessage("\(filteredNotes[indexPath.row].username) says", message: filteredNotes[indexPath.row].text)
    }
    
    
    
    // MARK: - SearchBar Delegate
    
    /// Note:  Search is delayed slightly to ensure bigger sets of data don't hurt performance when searching
    private var searchTimer = Timer()
    private var currentSearchFilter: String? = nil
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            currentSearchFilter = nil
            sortNotesAndReload()
        }
        
        if searchText == "" {
            // Immediate search
            searchTimer.invalidate()
            searchTimer = Timer.scheduledTimer(timeInterval: 0.0, target: self, selector: #selector(search), userInfo: searchText, repeats: false)
        } else {
            searchTimer.invalidate()
            searchTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(search), userInfo: searchText, repeats: false)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchTimer.invalidate()
        searchNotes()
        self.view.endEditing(true)
    }
    
    @objc func search(timer: Timer) {
        searchNotes()
    }
    
    func searchNotes() {
        currentSearchFilter = searchBar.text
        print("Searching: '\(searchBar.text ?? "nil")'")
        sortNotesAndReload()
    }
    
    
    // MARK: - Keyboard Delegate
    
    @objc func keyboardWillShow(_ notification:Notification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    @objc func keyboardWillHide(_ notification:Notification) {

        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    @objc func keyboardDidChangeFrame(_ notification:Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }

}
