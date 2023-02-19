//
//  ViewController.swift
//  ios-notes
//
//  Created by Оля Галягина on 19.02.2023.
//

import UIKit

protocol NoteDelegate: AnyObject {
    func update()
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var notes: [NoteModel] {
        do {
            return try context.fetch(NoteModel.fetchRequest())
        } catch {
            print("couldn't fetch data")
        }
        return [NoteModel]()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "Notes"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        
        if notes.count == 0 {
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            let newNote = NoteModel(context: context)
            newNote.id = UUID()
            newNote.title = "Sample Note"
            newNote.text = "This application allows users to create and delete notes. Tap '+' button on the first screen in order to add a new note and choose 'Edit' to delete notes. Selecting one of the notes from the list opens it and allows to modify that specific note."
            newNote.date = Date()
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tableView.setEditing(false, animated: false)
    }
    
    @objc func addTapped() {
        
        performSegue(withIdentifier: "AddNoteSegue", sender: nil)
    }
    
    @objc func editTapped() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        if tableView.isEditing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editTapped))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            let note = self.notes[indexPath.row]
            self.context.delete(note)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = self.notes[indexPath.row]
        performSegue(withIdentifier: "NoteDetailsSegue", sender: (indexPath.row, selectedItem))
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let note = notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Note")!
        cell.textLabel?.text = note.title
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        cell.detailTextLabel?.text = dateFormatter.string(from: note.date!)
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NoteDetailsSegue" {
            guard let destinationVC = segue.destination as? NoteViewController else { return }
            guard let note = sender as? (Int, NoteModel) else { return }
            destinationVC.noteIndex = note.0
            destinationVC.note = note.1
            destinationVC.delegate = self
        }
        if segue.identifier == "AddNoteSegue" {
            guard let destinationVC = segue.destination as? AddNoteViewController else { return }
            destinationVC.delegate = self
        }
    }
    
}
extension ViewController: NoteDelegate {
    func update() {
        tableView.reloadData()
    }
    
}

