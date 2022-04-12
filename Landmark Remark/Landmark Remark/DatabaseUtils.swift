//
//  DatabaseUtils.swift
//  Landmark Remark
//
//  Created by JD on 11/4/2022.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift


// Database ref (initialised according to Firebase documentation in AppDelegate
var db: Firestore? = nil

class DatabaseUtils {
    
    static var shared = DatabaseUtils()
    var notes: [Note] = []
    
    // keys
    fileprivate static let keyUsername = "current_username"
    fileprivate static let keyNotes = "notes"
    static let keyReloadNotes = "force_reload_notes"
    
    
    
    // MARK: - Note Functionality
    
    static func startListeningToNotes() {
        db?.collection(keyNotes).addSnapshotListener({ querySnapshot, err in
            if let err = err {
                print("Error: Failed to get notes: \(err)")
                return
            }
            
            // Get documents
            guard let documents = querySnapshot?.documents else {
                print("Warning: No notes in database")
                return
            }
            
            // Convert document data to Note objects
            let downloadedNotes = documents.compactMap { document -> Note? in
                do {
                    var note = try document.data(as: Note.self)
                    note?.id = document.documentID
                    return note
                } catch {
                    return nil
                }
            }
            
            // Reload all notes on map VC
            shared.notes = downloadedNotes
            print("Notes:")
            for note in downloadedNotes {
                print(note)
            }
            NotificationCenter.default.post(name: Notification.Name(keyReloadNotes), object: nil)
        })
    }
    
    static func addNote(text: String, lat: CGFloat, lng: CGFloat, completion: @escaping (Bool) -> Void) {
        
        // Ensure username is set.
        guard let username = getCurrentUsername() else {
            print("Error: Username not found. Can't save without Username")
            completion(false)
            return
        }
        
        // Make a unique ID
        let ref = db?.collection(keyNotes)
        guard let noteID = ref?.document().documentID else {
            print("Error: Failed to create NoteID")
            completion(false)
            return
        }
        
        // Save note
        let saveNote = Note(id: noteID, text: text, username: username, location: GeoPoint(latitude: lat, longitude: lng))
        do {
            try ref?.document(noteID).setData(from: saveNote, completion: { err in
                completion(true)
                
                /// Note: this will happen on it's own thanks to Firebase's live listening. If it wasn't for that, we could ask for a refresh here after adding the note manually to our stack first.
//                NotificationCenter.default.post(name: Notification.Name(keyReloadNotes), object: nil)
            })
        } catch let error {
            print("Error: Failed to save note: \(saveNote) due to: \(error)")
            completion(false)
        }
    }
    
    
    // MARK: - User Details
    
    static func setCurrentUsername(_ name: String) {
        UserDefaults.standard.set(name, forKey: keyUsername)
    }
    
    static func getCurrentUsername() -> String? {
        UserDefaults.standard.string(forKey: keyUsername)
    }
    
}


// MARK: - Note

struct Note: Identifiable, Codable, CustomStringConvertible {
    
    @DocumentID public var id: String?
    let text: String
    let username: String
    let location: GeoPoint
    
    
    enum CodingKeys: String, CodingKey {
        case text
        case username
        case location
    }
    
    var description: String {
        return "\(username) at (\(location)) says: \(text)"
    }
}


