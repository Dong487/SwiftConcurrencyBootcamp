//
//  AsyncLetBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/5/10.
//

// 1) async let 適合獲取少量不同來源的data 獲取完後 再同時顯示 (10個上下)
// 2) 
import SwiftUI

struct AsyncLetBootcamp: View {
    
    @State private var images: [UIImage] = []
    let columns = [GridItem(.flexible()) ,GridItem(.flexible())]
    let url = URL(string: "https://picsum.photos/300")!
    
    var body: some View {
        NavigationView{
            ScrollView{
                LazyVGrid(columns: columns) {
                    ForEach(images  ,id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150) // columns 會寬度上的調整
                    }
                }
            }
            .navigationBarTitle("Async Let Bootcamp🐳")
            .onAppear {
                Task{
                    do {
                        // 使用 async let 這邊4個 fetchImage 會同步執行
                        async let fetchImage1 = fetchImage()
                        async let fetchImage2 = fetchImage()
                        async let fetchImage3 = fetchImage()
                        async let fetchImage4 = fetchImage()
                        async let fetchTitle1 = fetchTitle()
                        
                        
                        // 然後在這邊等待 4 個的結果 再一次發佈
                        // 若裡面任何有1項 錯誤 則會執行 catch
                        // 如果想要有彈性 try -> try?  使錯誤的項目只會回傳nil 不會 throw error 而跑去執行 catch
                        let (image1 ,image2 ,image3 ,image4 ,title1) = await (try fetchImage1 , try fetchImage2 ,try fetchImage3 ,try fetchImage4 , fetchTitle1)
                        self.images.append(contentsOf: [image1 , image2 ,image3 , image4])
                        
//                        let image1 = try await fetchImage()
//                        self.images.append(image1)
//
//                        let image2 = try await fetchImage()
//                        self.images.append(image2)
//
//                        let image3 = try await fetchImage()
//                        self.images.append(image3)
//
//                        let image4 = try await fetchImage()
//                        self.images.append(image4)
                        
                    } catch  {
                        
                    }
                }
                
                
            }
        }
    }
    
    func fetchTitle() async -> String{
        return "123站著穿"
    }
    
    func fetchImage() async throws -> UIImage{
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

struct AsyncLetBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncLetBootcamp()
    }
}
