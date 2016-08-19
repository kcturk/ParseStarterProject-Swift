
import UIKit
import Parse //Note the imported Parse framework which lets us use PFObjects

@available(iOS 8.0, *)
class ViewController: UIViewController {
    
    @IBOutlet var username: UITextField!

    @IBOutlet var password: UITextField!
    
    @IBOutlet var topButton: UIButton!
    
    @IBOutlet var registeredText: UILabel!
    
    @IBOutlet var bottomButton: UIButton!
    
    var signupActive = true
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    func indicatorStart() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0,0,50,50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()//stops user interactions
    }
    
    func indicatorStop() {
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()//restarts user interactions
    }
    
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction((UIAlertAction(title: "OK", style: .Default, handler: { (action) in
            
            self.dismissViewControllerAnimated(true, completion: nil)
            
        })))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    @IBAction func signUp(sender: AnyObject) {
        
        if username.text == "" || password.text == "" {
        
            displayAlert("Error in form", message: "Please enter your Username and Password")
            
        } else {
            
        indicatorStart()
            var errorMessage = "Please try again later."

            if signupActive == true {
            
            let user = PFUser()
            user.username = username.text
            user.password = password.text
            
                
            //Attempt to sign user up
            user.signUpInBackgroundWithBlock({ (success, error) in
                
                self.indicatorStop()
                
                if error == nil {
                
                    self.performSegueWithIdentifier("login", sender: self)
                    
                    
                } else { //Signup not successful
                    
                    if let errorString = error!.userInfo["error"] as? String { //if there is an error save it
                        errorMessage = errorString
                        
                    }
                    
                    self.displayAlert("Failed SignUp", message: errorMessage)
                }
                
            })
            
            } else {
                
                PFUser.logInWithUsernameInBackground(username.text!, password: password.text!, block: { (user,error) in
                    
                    self.indicatorStop()
                    
                    if user != nil {
                        self.performSegueWithIdentifier("login", sender: self)
                    } else {
                        if let errorString = error!.userInfo["error"] as? String { //if there is an error save it
                            errorMessage = errorString
                            
                        }
                        
                        self.displayAlert("Failed Log In", message: errorMessage)
                    }
                    
                })
                
            }
            
        }
        
    }
    
    @IBAction func login(sender: AnyObject) {
        
        if signupActive == true {
            
            topButton.setTitle("Log In", forState: UIControlState.Normal)
            
            registeredText.text = "Not registered?"
            
            bottomButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            signupActive = false
            
        } else {
            
            topButton.setTitle("Sign Up", forState: UIControlState.Normal)
            
            registeredText.text = "Already registered?"
            
            bottomButton.setTitle("Login", forState: UIControlState.Normal)
            
            signupActive = true
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
 
    }

    override func viewDidAppear(animated: Bool) {
        
        
        
        //if PFUser.currentUser() != nil {
        //    self.performSegueWithIdentifier("login", sender: self)
        //}
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
