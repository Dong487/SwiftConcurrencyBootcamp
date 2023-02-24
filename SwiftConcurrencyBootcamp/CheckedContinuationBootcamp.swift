//
//  CheckedContinuationBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/5/17.
//

// 將非 async 的代碼 -> 轉換成 async
// 注意
// You must resume the continuation exactly once

import SwiftUI

class CheckedContinuationBootcampNetworkManager{
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data , _) = try await URLSession.shared.data(from: url, delegate: nil)
            return data
        } catch {
            print("下載DATA 發生錯誤")
            throw error
        }
    }
    
    // 常見的 @escaping func 轉成 async await throws
    func getData2(url: URL) async throws -> Data {
        // 由自己檢查的錯誤 (可能效能上較好一點點)
        // withUnsafeContinuation(<#T##fn: (UnsafeContinuation<T, Never>) -> Void##(UnsafeContinuation<T, Never>) -> Void#>)
        
        // return -> T
        // 回傳 所接收到的型態
        return try await withCheckedThrowingContinuation { continuation in
         
            URLSession.shared.dataTask(with: url) { data, response, error in
                // 只能有一個resume 準確地回傳
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error = error{
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume() // 記得要加 重要
        }
    }
    
    // 123123
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> ()){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    // 將上面的常見的 @escaping
    // 利用 checkedContinuation
    // 轉換成 async
    
    func getHeartImageFromDatabase() async -> UIImage {
        // 可以省略 return
        await withCheckedContinuation { continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        }
    }
}

class CheckedContinuationBootcampViewModel: ObservableObject{
    
    @Published var image: UIImage? = nil
    let networkManager = CheckedContinuationBootcampNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        
        do {
            let data = try await networkManager.getData2(url: url)
            
            if let image = UIImage(data: data){
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch {
            print("從data轉成 UIImage 發生錯誤")
        }
    }
    
//    func getHeartImage(){
//        networkManager.getHeartImageFromDatabase { [weak self] image in
//            self?.image = image
//        }
//    }
    
    func getHeartImage() async {
        self.image = await networkManager.getHeartImageFromDatabase()
    }
}

struct CheckedContinuationBootcamp: View {
    
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    
    var body: some View {
        ZStack{
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
