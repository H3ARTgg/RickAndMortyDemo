import UIKit

extension UIImage {
    
    /// Изменяет размер изображения до указанного размера.
    ///
    /// - Parameter targetSize: Новый размер изображения.
    /// - Returns: Новое изображение, измененное до указанного размера.
    func resize(to targetSize: CGSize) -> UIImage? {
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        // Определяем масштабный коэффициент для сохранения пропорций
        let scaleFactor = min(widthRatio, heightRatio)
        
        let scaledImageSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Начинаем графический контекст
        UIGraphicsBeginImageContextWithOptions(scaledImageSize, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        
        draw(in: CGRect(origin: .zero, size: scaledImageSize))
        
        // Получаем новое изображение
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
