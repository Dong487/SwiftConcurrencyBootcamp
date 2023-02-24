//
//  TaskGroupBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/5/12.
//

// 1) AsyncLet
// 2) TaskGroup

import SwiftUI

class TaskGroupBootcampDataManager{
    
// --------------------  1  -------------------------------
    func fetchImagesWithAsyncLet() async throws -> [UIImage]{
        
        async let fetchImage1 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage2 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage3 = fetchImage(urlString: "https://picsum.photos/300")
        async let fetchImage4 = fetchImage(urlString: "https://picsum.photos/300")
        
        let (image1 ,image2 ,image3 ,image4) = await (try fetchImage1 , try fetchImage2 ,try fetchImage3 ,try fetchImage4)
        
        return [image1 ,image2 ,image3 ,image4]
    }
// ------------------- 1 End -----------------------------
    
    
// ------------------- 2 ---------------------------------
    // 可以在 urlStrings 做延伸
    func fetchImagesWithTaskGroup() async throws -> [UIImage] {
        // 建立 url Array 然後用ForEach 去 run
        let urlStrings = [
            "https://picsum.photos/300",
            "https://picsum/photos/200",
            "https://picsum/photos/300",
            "https://picsum/photos/300",
            "https://picsum/photos/300",
            "https://picsum/photos/300",
        ]
        
        // 使用這個 TaskGroup 能夠 throws error (有些group 完全不會throw error)
        
        // of:  -> (子)多個任務組 回傳的Type
        // 這邊的 return 才是回傳給 fetchImagesWithTaskGroup
        return try await withThrowingTaskGroup(of: UIImage?.self) { group in
            var images: [UIImage] = []
            // 提升效能
            // 預設內存空間(Array項目個數)沒預設情況下 swift本身空間配置會翻倍 2 -> 4 -> 8 -> 16 -> 32
            images.reserveCapacity(urlStrings.count)
            print("SBBBBBB")
            print(urlStrings.count)
            /*
            // 這邊的 Priority優先順序 繼承了父func (除非必要 不用特別更改)
            // operation 回傳 根據你給的 of: 型態
            // group.addTask(priority: , operation: )
//            group.addTask{
//                try await self.fetchImage(urlString: "https://picsum/photos/300")
//            }
//            group.addTask{
//                try await self.fetchImage(urlString: "https://picsum/photos/300")
//            }
//            group.addTask{
//                try await self.fetchImage(urlString: "https://picsum/photos/300")
//            }
//            group.addTask{
//                try await self.fetchImage(urlString: "https://picsum/photos/300")
//            }*/
            
            // 等同上方 註解掉的 部分
            
            for urlString1 in urlStrings{
                group.addTask{
                    try? await self.fetchImage(urlString: urlString1)
                }
                print("COOOL")
            }
            
            // 這邊的ForEach 會等待 接收循環內的所有結果 才會一次動作 or 某一項throws error 而停止 -> 否則將會一直等待接收未完成的項目
            // 循環中的task 哪個結果先回傳都可以 不用按照先後順序
            // group 為 async  使用 try await
            // 將UIImage 添加到 UIImage Array
            for try await image in group{
                if let image = image {
                    images.append(image)
                }
            }
            
            // 將 UIImage Array 回傳
            return images
        }
    }
// ------------------- 2 End -----------------------------
    
    private func fetchImage(urlString: String) async throws -> UIImage{
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            let (data ,_) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data){
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject{
    
    @Published var images: [UIImage] = []
    @Published var images2: [UIImage] = []
    
    let manager = TaskGroupBootcampDataManager()
    
    // 1) WithAsyncLet
    func getImage() async {
        // 從manager 獲取圖片
        // fetchImagesWithAsyncLet 型態 : async throws -> [UIImage]
        // 編譯錯誤時會 throws error 所以使用 try? 讓他有錯誤時為 nil
        // 有使用 async 所以 await 等待結果 (這個函數回傳出去 也要添加async)
        if let images = try? await manager.fetchImagesWithAsyncLet(){
            self.images.append(contentsOf: images)
        }
    }
    
    // 2) WithTaskGroup
    func getImage2() async {
        if let images = try? await manager.fetchImagesWithTaskGroup(){
            self.images2.append(contentsOf: images)
        }
    }
}

struct TaskGroupBootcamp: View {
    
    @StateObject private var viewmModel = TaskGroupBootcampViewModel()
    let columns = [GridItem(.flexible()) ,GridItem(.flexible())]
    
    var body: some View {
        NavigationView{
            ScrollView{
                LazyVGrid(columns: columns) {
                    ForEach(viewmModel.images2 ,id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150) // columns 會寬度上的調整
                    }
                }
            }
            .navigationBarTitle("Task Group 🐳")
            // 呼叫有 async 的 func (記得要加await)
            .task {
                await viewmModel.getImage2()
            }
        }
    }
}

struct TaskGroupBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskGroupBootcamp()
    }
}
