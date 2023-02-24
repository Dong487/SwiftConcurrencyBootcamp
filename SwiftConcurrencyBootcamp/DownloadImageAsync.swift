//
//  DownloadImageAsync.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/4/30.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader{
    
    let url = URL(string: "https://picsum.photos/200")!
    
    // 方便重複使用
    func handleResponse(data: Data? ,response: URLResponse?) -> UIImage?{
        guard
            let data = data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse,
            response.statusCode >= 200 && response.statusCode < 300 else {
                return nil
            }
        return image
    }
    
    //
    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage? ,_ error: Error?) -> () ){
        URLSession.shared.dataTask(with: url) { [weak self] data, response , error in
            
            let image = self?.handleResponse(data: data, response: response)
            
            completionHandler(image, error)
        }
        .resume()
    }
    
    // Combine 用法
    func downloadWithCombine() -> AnyPublisher<UIImage?, Error>{
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 }) // 123123  將ERROR轉換成 AnyPublisher可辨識的ERROR
            .eraseToAnyPublisher()
            
    }
    
    // Async
    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data ,response) = try await URLSession.shared.data(from: url, delegate: nil)
            let image = handleResponse(data: data, response: response)
            print(data)
            return image
            
        } catch  {
            throw error
        }
    }
}

class DownloadImageAsyncViewModel: ObservableObject{
    
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()
    
    // escaping
    func fetchImage(){
        
        // 如果沒有 DispatchQueue.main.async
        // 有時候會有紫色Error 是因為 downloadWithEscaping 裡面的 URLSession.shared.dataTask 是在後台線程中執行
        // 而要在畫面UI讀取前 先回到主線程
        loader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    // Combine
    func fetchImage2(){
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main) // 取代 DispatchQueue.main.async{ }
            .sink { _ in
                // 懶得打 (成功 、失敗)
            } receiveValue: { [weak self] image in
                    self?.image = image
            }
            .store(in: &cancellables)
    }
    
    func fetchImage3() async{
        // 更好的話可以用 do - catch
        // 優點是 錯誤的時候 可以更容易找到 error點
        let image = try? await loader.downloadWithAsync()
        // 回到主線程
        await MainActor.run{
            self.image = image
        }
    }
    
}

struct DownloadImageAsync: View {
    
    @StateObject private var viewModel = DownloadImageAsyncViewModel()
    
    var body: some View {
        ZStack{
            if let image = viewModel.image{
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250)
            }
        }
//        .onAppear {
//            viewModel.fetchImage()
//            viewModel.fetchImage2()
//        }
        .onAppear {
            Task{
                await viewModel.fetchImage3()
            }
        }
    }
}

struct DownloadImageAsync_Previews: PreviewProvider {
    static var previews: some View {
        DownloadImageAsync()
    }
}
