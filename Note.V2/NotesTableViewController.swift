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
        
        loadAndDisplayData()
    }
    
    func loadAndDisplayData() {
        
        // create request (search) for all Notes in Core Data
        let noteRequest:NSFetchRequest<Note> = Note.fetchRequest()
        
        // execute the request, save results in the notes array, and crash (!) if failed
        notes = try! CoreDataStack.shared.context.fetch(noteRequest)
        
        // refresh table view
        self.tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    // table view asks for a cell for each row (determined by numberOfRowsInSection)
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // create a custom cell from template "cell" on Storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotesTableViewCell
        
        // get Note from Core Data for row
        let noteItem = notes[indexPath.row]
        
        // format cell based on Note's data
        if let noteImage = UIImage(data: noteItem.image!) {
            cell.backgroundImageView.image = noteImage
        }
        cell.nameLabel.text = noteItem.name
        cell.descriptionLabel.text = noteItem.longText
        
        return cell // cell should be ready for display
    }
    
    // for each row, table view asks how tall the cell is
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120 // each cell will be 120 points tall
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
        
        // save the current state of Core Data (if there are changes)
        CoreDataStack.shared.saveIfNeeded()
        
        // re-fetch notes and reload table view
        loadAndDisplayData()
    }
    
}


