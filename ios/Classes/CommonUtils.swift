import UIKit

// Utility class for showing Toast and Dialog
class CommonUtil {

    // Show a Toast (UIAlertController with a message that disappears after a while)
    static func showToast(message: String) {
        let toast = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(toast, animated: true, completion: nil)

            // Dismiss the toast after 2 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                toast.dismiss(animated: true, completion: nil)
            }
        }
    }

    // Show a Dialog (UIAlertController with a title, message, and "OK" button)
    static func showDialog(title: String, message: String) {
    // Check if title is empty or nil
     let titleString = title.isEmpty ? "Alert" : title

        let alertController = UIAlertController(title: titleString, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        if let rootViewController = UIApplication.shared.keyWindow?.rootViewController {
            rootViewController.present(alertController, animated: true, completion: nil)
        }
    }
}
