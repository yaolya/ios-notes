//
//  AddNoteViewController.swift
//  ios-notes
//
//  Created by Оля Галягина on 19.02.2023.
//

import UIKit

class AddNoteViewController: UIViewController {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var textView: UITextView!
    
    weak var delegate: NoteDelegate?
    
    lazy var touchView: UIView = {
        
        let _touchView = UIView()
        
        _touchView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0)
        
        let touchViewTapped = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        
        _touchView.addGestureRecognizer(touchViewTapped)
        
        _touchView.isUserInteractionEnabled = true
        
        _touchView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        
        return _touchView
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationItem = UINavigationItem(title: "Add Note")
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(barButtonDidTouch))
        navigationBar.items = [navigationItem]
        
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = CGFloat(1)
        textView.layer.cornerRadius = CGFloat(3)
        textView.isEditable = true
        
        titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        titleTextField.layer.borderWidth = CGFloat(1)
        titleTextField.layer.cornerRadius = CGFloat(3)
        titleTextField.borderStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        registerForKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        deregisterFromKeyboardNotification()
    }
    
    @objc func barButtonDidTouch() {
        dismiss(animated: true, completion: nil)
    }
    
    func registerForKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification: )), name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasHidden(notification: )), name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotification() {
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIWindow.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        view.addSubview(touchView)
    }
    
    @objc func keyboardWasHidden(notification: NSNotification) {
        touchView.removeFromSuperview()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        guard let title = titleTextField.text, !title.isEmpty else {
            reportError(title: "Invalid title", message: "Title is required")
            return
        }
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let newNote = NoteModel(context: context)
        newNote.id = UUID()
        newNote.title = titleTextField.text
        newNote.text = textView.text
        newNote.date = Date()
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        
        delegate?.update()
        dismiss(animated: true, completion: nil)
    }
    
    func reportError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard(_ sender: Any) {
        view.endEditing(true)
    }
    
}
