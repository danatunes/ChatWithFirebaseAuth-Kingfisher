//
//  ChatViewController.swift
//  ChatWithAuth
//
//  Created by Магжан Бекетов on 27.04.2021.
//

import UIKit
import Firebase
import FirebaseStorage
import SVProgressHUD

class ChatViewController: UIViewController {
    
    @IBOutlet private weak var inputTextField: UITextField!
    @IBOutlet private weak var containerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var sendButton: UIButton!
    
    
    private var messages : [MessageEntity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startConfiguration()
        fetchMessagesFromFirebase()
    }
    
    private func startConfiguration() {
        inputTextField.delegate = self
        inputTextField.layer.cornerRadius = 15.0
        inputTextField.layer.masksToBounds = true
        
        sendButton.layer.cornerRadius = 8
        sendButton.layer.masksToBounds = true
        
        let tapOneTableView = UITapGestureRecognizer(target: self, action: #selector(tappedOnTableView))
        
        tableView.addGestureRecognizer(tapOneTableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.register(MessageCell.nib, forCellReuseIdentifier: MessageCell.identifier)
        tableView.register(ImageCell.nib, forCellReuseIdentifier: ImageCell.identifier)
        
    }
    
    @IBAction func logoutPressed(_ sender: UIButton) {
        do{
            try Auth.auth().signOut()
            self.navigationController?.popToRootViewController(animated: true)
        }catch let error{
            print(error)
        }
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {

        ///IF MESSAGE IS EMPTY BORDER WILL BE RED
        if let message = inputTextField.text{
            if message.isEmpty || message == " "{
                inputTextField.layer.borderWidth = 1.5
                inputTextField.layer.borderColor = UIColor.systemRed.cgColor
                sendButton.layer.backgroundColor = UIColor.systemRed.cgColor
            }
            else {
                inputTextField.layer.borderColor = UIColor.clear.cgColor
                sendButton.layer.backgroundColor = UIColor.clear.cgColor
                sendMessagesToFirebase(message: message)
            }
        }else{
            inputTextField.layer.borderColor = UIColor.systemRed.cgColor
        }
    }
    
    @IBAction func choicePhotoButton(_ sender: UIButton) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    ///Upload image to storage and then send url to realtime db
    private func uploadImage(photo : UIImage){
        DatabaseManager.shared.uploadImageToStorage(photo: photo) { (result) in
            switch result {
            case .success(let url):
                print("\(url)")
                DatabaseManager.shared.sendMessagesToFirebase(message: "\(url)") { (result) in
                    switch result {
                    case .success(let message):
                        print("... \(message)")
                    case .failure(let error):
                        print(".... \(error)")
                    }
                }
            case .failure(let error):
                print(".... \(error)")
            }
        }
    }
    
}

//MARK: -INNER FUNCTIONS sendMessagesToFirebase(),fetchMessagesFromFirebase()
extension ChatViewController{
    @objc private func tappedOnTableView(){
        inputTextField.endEditing(true)
    }
    
    private func sendMessagesToFirebase(message : String){
        
        sendButton.isEnabled = false
        DatabaseManager.shared.sendMessagesToFirebase(message: message) { [weak self] (result) in
            self?.inputTextField.text = ""
            switch result {
            case .success(let message):
                print("... \(message)")
                self?.sendButton.isEnabled = true
                
            case .failure(let error):
                print(".... \(error)")
            }
        }
        
    }
    
    private func fetchMessagesFromFirebase(){
        DatabaseManager.shared.fetchMessagesFromFirebase { [weak self] (result) in
            switch result {
            case .success(let message):
                self?.messages.append(message)
                self?.tableView.reloadData()
                self?.scrollToLastMessage()
            case .failure(let error):
                print("....\(error)")
                return
            }
        }
    }
    
    private func scrollToLastMessage(){
        if messages.count - 1 > 0{
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ChatViewController : UITextFieldDelegate{
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.layoutIfNeeded()
        //        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.containerViewHeightConstraint.constant = 50 + 310
            self.view.layoutIfNeeded()
        }
        scrollToLastMessage()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.layoutIfNeeded()
        //        view.setNeedsLayout()
        UIView.animate(withDuration: 0.2) {
            self.containerViewHeightConstraint.constant = 50
            self.view.layoutIfNeeded()
        }
        scrollToLastMessage()
    }
}

// MARK: - UITableViewDelegate , UITableViewDataSource
extension ChatViewController : UITableViewDelegate , UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indicateImage(message: messages[indexPath.row].message){
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
            let message = messages[indexPath.row]
            cell.message = message
            return cell
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.identifier, for: indexPath) as! MessageCell
            let message = messages[indexPath.row]
            print("..... \(messages[indexPath.row].messageID)")
            cell.message = message
            return cell
        }
    }
    
}

///after tapped the "+" button open imagePicker from gallerey then send to uploadImage func
extension ChatViewController : UIImagePickerControllerDelegate , UINavigationControllerDelegate{
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            print(".... image is nil extension chatVC")
            return
        }
        
        uploadImage(photo: image)
    }
    
}

extension ChatViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleting = removeFilm(at: indexPath)
        return UISwipeActionsConfiguration(actions: [deleting])
    }
    
    private func removeFilm(at indexPath : IndexPath) -> UIContextualAction{
        
        let action = UIContextualAction(style: .destructive, title: "DELETE") { [weak self] (action , view ,completion) in
            
            var title = ""
            var message = ""
            
            guard let email = Auth.auth().currentUser?.email else {
                return
            }
            if email == self?.messages[indexPath.row].sender{
                title = "DELETE?"
                message = "Data can not be returned after deletion"
            }else{
                title = "Access denied"
                message = "You can modify only own messages"
            }
            
            let alert = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            if let email = Auth.auth().currentUser?.email {
                if email == self?.messages[indexPath.row].sender{
                    
                    alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [weak self] action in
                        
                        guard let messageID = self?.messages[indexPath.row].messageID else{
                            print("..... self?.messages[indexPath.row].messageID is nil")
                            return
                        }
                        DatabaseManager.shared.removeMessage(messageID: messageID) { (result) in
                            switch result {
                            case .success(let message):
                                print(message)
                            case .failure(let error):
                                print(".... \(error)")
                            }
                        }
                        self?.messages.remove(at: indexPath.row)
                        self?.tableView.reloadData()
                    }))
                }
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self?.present(alert, animated: true)
        }
        action.backgroundColor = .red
        return action
    }
}

extension ChatViewController{
    private func indicateImage(message : String) -> Bool {
        if message.contains("firebasestorage"){
            return true
        }
        return false
    }
}
