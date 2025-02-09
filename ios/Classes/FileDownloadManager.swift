import UIKit

class FileDownloadManager {

    // Function to download a file and save it locally
    func downloadFile(from url: URL, to destinationURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (tempLocalURL, response, error) in
            if let error = error {
                print("Error downloading file: \(error.localizedDescription)")
                completion(false, error)
                return
            }

            guard let tempLocalURL = tempLocalURL else {
                print("Failed to get temporary URL.")
                completion(false, nil)
                return
            }

            do {
                // Delete the file if it already exists at destination URL
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }

                // Move the downloaded file from temp location to the destination
                try FileManager.default.moveItem(at: tempLocalURL, to: destinationURL)
                print("File downloaded and saved to: \(destinationURL.path)")
                completion(true, nil)
            } catch let moveError {
                print("Error saving file: \(moveError.localizedDescription)")
                completion(false, moveError)
            }
        }

        task.resume()
    }

    // Example usage
    func startDownload() {
        let fileURL = URL(string: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf")! // Replace with your file URL
        let destinationPath = NSTemporaryDirectory() + "dummy.pdf" // Temporary directory or a specific local path
        let destinationURL = URL(fileURLWithPath: destinationPath)

        downloadFile(from: fileURL, to: destinationURL) { (success, error) in
            if success {
                print("Download complete!")
            } else {
                print("Download failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
