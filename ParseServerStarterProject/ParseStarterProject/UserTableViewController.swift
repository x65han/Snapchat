//
//  UserTableViewController.swift
//  ParseStarterProject-Swift
//
//  Created by Johnson Han on 2017-07-04.
//  Copyright © 2017 Parse. All rights reserved.
//

import UIKit
import Parse

class UserTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var titleBar: UINavigationItem!
    var usernames = [String]()
    var recipientUsername = ""
    var currentUsername = ""
    var timer = Timer()
    
    func checkForMessages() {
        let query = PFQuery(className: "Image")
        query.whereKey("recipientUsername", equalTo: self.currentUsername)
        do {
            let images = try query.findObjects()
            if images.count > 0 {
                var senderUsername = "Unknown User"
                if let username = images[0]["senderUsername"] as? String {
                    senderUsername = username
                }
                if let pfFile = images[0]["photo"] as? PFFile {
                    pfFile.getDataInBackground(block: { (data, error) in
                        if let imageData = data {
                            images[0].deleteInBackground()
                            self.timer.invalidate()
                            if let imageToDisplay = UIImage(data: imageData) {
                                let alertController = UIAlertController(title: "You have a message", message: "Message from " + senderUsername, preferredStyle: .alert)
                                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                    let backgroundImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    backgroundImageView.backgroundColor = .black
                                    backgroundImageView.alpha = 0.8
                                    backgroundImageView.tag = 10
                                    self.view.addSubview(backgroundImageView)
                                    let displayedImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height))
                                    displayedImageView.image = imageToDisplay
                                    displayedImageView.tag = 10
                                    displayedImageView.contentMode = UIViewContentMode.scaleToFill
                                    self.view.addSubview(displayedImageView)
                                    _ = Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                                        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(UserTableViewController.checkForMessages), userInfo: nil, repeats: true)
                                        for subview in self.view.subviews {
                                            if subview.tag == 10 {
                                                subview.removeFromSuperview()
                                            }
                                        }
                                    })
                                }))
                                self.present(alertController, animated: true, completion: nil)
                            }
                        }
                    })
                }
            }
        } catch {
            print("Fails to fetch images")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(UserTableViewController.checkForMessages), userInfo: nil, repeats: true)
        self.navigationController?.navigationBar.isHidden = false
        let query = PFUser.query()
        query?.whereKey("username", notEqualTo: (PFUser.current()?.username)!)
        do {
            let users = try query?.findObjects()
            if let users = users as? [PFUser] {
                for user in users {
                    self.usernames.append(user.username!)
                }
                tableView.reloadData()
            }
        } catch {
            print("Fails to get users")
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        currentUsername = (PFUser.current()?.username)!
        self.title = "User List - " + currentUsername
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return usernames.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = usernames[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logout" {
            PFUser.logOut()
            self.navigationController?.navigationBar.isHidden = true
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        recipientUsername = usernames[indexPath.row]
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = false
        
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let imageData = UIImageJPEGRepresentation(image, 0.5)
            print("Image returned")
            let imageToSend = PFObject(className: "Image")
            imageToSend["photo"] = PFFile(name: "photo.png", data: imageData!)
            imageToSend["senderUsername"] = PFUser.current()?.username
            imageToSend["recipientUsername"] = recipientUsername
            let acl = PFACL()
            acl.getPublicWriteAccess = true
            acl.getPublicReadAccess = true
            imageToSend.acl = acl
            imageToSend.saveInBackground( block: { (success, error) in
                var title = "Sending Failed"
                var description = "Please try again later"
                if success {
                    title = "Message Sent!"
                    description = "Your message has been sent."
                }
                let alertController = UIAlertController(title: title, message: description, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    alertController.dismiss(animated: true, completion: nil)
                }))
                    self.present(alertController, animated: true, completion: nil)
            })
        }
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
