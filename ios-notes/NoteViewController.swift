//
//  NoteViewController.swift
//  ios-notes
//
//  Created by Оля Галягина on 19.02.2023.
//

import UIKit

class NoteViewController: UIViewController {
    
    var note: NoteModel!
    
    var noteIndex: Int!
    
    weak var delegate: NoteDelegate?
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    func setupView() {
        titleTextField.text = note.title
        titleTextField.borderStyle = .none
        textView.text = note.text
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        dateLabel.text = dateFormatter.string(from: note.date!)
        disableEditing()
    }
    
    func enableEditing() {
        navigationItem.setHidesBackButton(true, animated:true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        textView.isEditable = true
        titleTextField.isUserInteractionEnabled = true
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneTapped))
    }
    
    func disableEditing() {
        navigationItem.leftBarButtonItem = nil
        navigationItem.setHidesBackButton(false, animated:true)
        textView.isEditable = false
        titleTextField.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editTapped))
    }
    
    @objc func editTapped() {
        enableEditing()
    }
    
    @objc func cancelTapped() {
        disableEditing()
        titleTextField.text = note.title
        textView.text = note.text
    }
    
    @objc func doneTapped() {
        disableEditing()
        note.title = titleTextField.text
        note.text = textView.text
        note.date = Date()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        delegate?.update()
    }
    
}
