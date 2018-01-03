//
//  NotesTableViewController.swift
//  Note.V2
//
//  Created by Thao Doan on 12/29/17.
//  Copyright © 2017 Thao Doan. All rights reserved.
//

import UIKit
import CoreData

class NotesTableViewController: UITableViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var notes = [Note]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    func loadData() {
        let noteRequest:NSFetchRequest<Note> = Note.fetchRequest()
        do {
            notes = try CoreDataStack.shared.context.fetch(noteRequest)
            self.tableView.reloadData()
        }catch {
            print("You have an Error")
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotesTableViewCell
        
        let noteItem = notes[indexPath.row]
        
        
        if let noteImage = UIImage(data: noteItem.image as! Data ) {
            
            cell.backgroundImageView.image = noteImage
        }
        cell.nameLabel.text = noteItem.name
        
        cell.descriptionLabel.text = noteItem.longText
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    @IBAction func addNote(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage{
            picker.dismiss(animated: true, completion: nil)
            showCreateNoteAlert(forImage: image)
        }
    }
    
    func showCreateNoteAlert(forImage image:UIImage) {
        
        // create alert with text fields
        let alert = UIAlertController(title: "New Note", message: "Enter place and description", preferredStyle: .alert)
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Place"
        }
        alert.addTextField { (textField:UITextField) in
            textField.placeholder = "Description"
        }
        
        // set create note action on alert (what happens when "Save" pressed)
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {(action:UIAlertAction) in
            self.createNewNote(photo: image,
                                name: alert.textFields?.first?.text,
                         description: alert.textFields?.last?.text)
        }))
    
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil)) // if user taps "Cancel"
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func createNewNote(photo: UIImage, name: String?, description: String?) {
        
        // creates note item in Core Data context
        let noteItem = Note(context: CoreDataStack.shared.context)
        
        // set properties of Note (to be saved in Core Data)
        noteItem.image = NSData(data: UIImageJPEGRepresentation(photo, 0.3)!) as Data
        noteItem.name = name
        noteItem.longText = description
        
        // tells Core Data to save the current state of its context (if there are changes)
        CoreDataStack.shared.saveIfNeeded()
    }
    
}


