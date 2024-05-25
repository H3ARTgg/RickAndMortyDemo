import Foundation

// MARK: - NetworkTask Protocol
protocol NetworkTask {
    func cancel()
}

// MARK: - DefaultNetworkTask
struct DefaultNetworkTask: NetworkTask {
    let dataTask: URLSessionDataTask

    func cancel() {
        dataTask.cancel()
    }
}
