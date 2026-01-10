//
//  ImageService.swift
//  SwiggyAssignment
//
//  Created by Ayush Goyal on 10/01/26.
//
import SwiftUI

final class ImageService {
    static let shared = ImageService()
    private let memoryCache = NSCache<NSString, UIImage>()
    private init() {
        memoryCache.countLimit = 100
        memoryCache.totalCostLimit = 50 * 1024 * 1024
    }

    struct StoredImage {
        let originalURL: URL
        let thumbnailURL: URL?
        let fileSize: Int64
    }

    func saveImage(
        _ image: UIImage,
        compressionQuality: CGFloat = 0.85,
        thumbnailMaxSize: CGFloat = 100
    ) -> StoredImage? {

        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            return nil
        }

        let filename = "\(UUID().uuidString).jpg"

        let documentsURL = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0]

        let originalURL = documentsURL.appendingPathComponent(filename)

        do {
            try data.write(to: originalURL)

            let thumbnailURL = generateThumbnail(
                from: image,
                maxSize: thumbnailMaxSize
            )

            let fileSize = Int64(data.count)

            return StoredImage(
                originalURL: originalURL,
                thumbnailURL: thumbnailURL,
                fileSize: fileSize
            )
        } catch {
            print("Image save failed:", error)
            return nil
        }
    }

    private func generateThumbnail(
        from image: UIImage,
        maxSize: CGFloat
    ) -> URL? {

        let maxDimension = max(image.size.width, image.size.height)

        guard maxDimension > maxSize else {
            return nil
        }

        let scale = maxSize / maxDimension
        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let thumbnail = thumbnailImage,
              let data = thumbnail.jpegData(compressionQuality: 0.5)
        else { return nil }

        let filename = "thumb_\(UUID().uuidString).jpg"

        let cachesURL = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )[0]

        let fileURL = cachesURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Thumbnail save failed:", error)
            return nil
        }
    }

    func loadImage(from path: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = path as NSString

        if let cached = memoryCache.object(forKey: cacheKey) {
            completion(cached)
            return
        }

        guard let url = URL(string: path) else {
            completion(nil)
            return
        }

        if url.scheme == "http" || url.scheme == "https" {
            Task {
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    if let img = UIImage(data: data) {
                        memoryCache.setObject(img, forKey: cacheKey)
                        DispatchQueue.main.async { completion(img) }
                    } else {
                        DispatchQueue.main.async { completion(nil) }
                    }
                } catch {
                    DispatchQueue.main.async { completion(nil) }
                }
            }
        } else if url.isFileURL {
            DispatchQueue.global(qos: .userInitiated).async {
                guard let data = try? Data(contentsOf: url),
                      let img = UIImage(data: data) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                self.memoryCache.setObject(img, forKey: cacheKey)
                DispatchQueue.main.async { completion(img) }
            }
        } else {
            completion(nil)
        }
    }
    
    func cache(image: UIImage, for url: String) {
        memoryCache.setObject(image, forKey: url as NSString)
    }
    
    func formatFileSize(_ bytes: Int64) -> String {
        ByteCountFormatter.string(
            fromByteCount: bytes,
            countStyle: .file
        )
    }
}
