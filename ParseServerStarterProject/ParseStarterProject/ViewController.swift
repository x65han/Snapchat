/**
* Copyright (c) 2015-present, Parse, LLC.
* All rights reserved.
*
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree. An additional grant
* of patent rights can be found in the PATENTS file in the same directory.
*/

import UIKit
import Parse

class ViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func loginAction(_ sender: Any) {
        if usernameTextField.text == "" {
            errorLabel.text = "Username cannot be empty"
        } else {
            PFUser.logInWithUsername(inBackground: usernameTextField.text!, password: "password", block: { (user, error) in
                print("first")
                if error != nil {
                    let user = PFUser()
                    user.username = self.usernameTextField.text
                    user.password = "password"
                    print("second")
                    user.signUpInBackground(block: { (success, err) in
                        if err != nil{
                            let errorMessage = "Signup Failed"
                            self.errorLabel.text = errorMessage
                            self.usernameTextField.text = ""
                        } else {
                            self.performSegue(withIdentifier: "showUserTable", sender: self)
                        }
                    })
                } else {
                    print("Logged In Already")
                    self.performSegue(withIdentifier: "showUserTable", sender: self)
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        if PFUser.current()?.username != nil {
            self.performSegue(withIdentifier: "showUserTable", sender: self)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
