//
//  DoCatchTryThrowsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by DONG SHENG on 2022/4/26.
//

import SwiftUI

// do - catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager{
    
    let isActive: Bool = true
    
    func getTitle() -> (title: String? , error: Error?) {
        if isActive {
            return ("更換標題了COOL" , nil)
        } else {
            return (nil ,URLError(.badURL))
        }
    }
    
    func getTitle2() -> Result<String ,Error>{
        if isActive {
            return .success("更換標題了COOL")
        } else {
            return .failure(URLError(.appTransportSecurityRequiresSecureConnection))
        }
    }
    
    func getTitle3() throws -> String{
        if isActive{
            return "我是 Title333333"
        } else {
            throw URLError(.backgroundSessionRequiresSharedContainer)
        }
    }
    
    func getTitle5() throws -> String{
        if isActive{
            return "Final TEXT!!"
        } else {
            throw URLError(.backgroundSessionRequiresSharedContainer)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject{
    
    @Published var text: String = "第一個Title"
    let manager = DoCatchTryThrowsBootcampDataManager()
    
    func fetchTitle(){
        /*
        let returnedValue = manager.getTitle()
        if let newTitle = returnedValue.title {
            self.text = newTitle
        } else if let error = returnedValue.error{
            self.text = error.localizedDescription
        }
        */
        /*
        let result = manager.getTitle2()
        
        switch result{
        case .success(let newTitle):
            self.text = newTitle
        case .failure(let error):
            self.text = error.localizedDescription
        }
         */
        
//        let newTitle = try? manager.getTitle3()
//        if let newTitle = newTitle{
//            self.text = newTitle
//        }
        
        do {
            let newTitle = try? manager.getTitle3()
            if let newTitle1 = newTitle{
                self.text = newTitle1
            }

            let finalTitle = try manager.getTitle5()
            self.text = finalTitle
        } catch let error {
            self.text = error.localizedDescription
        }
    }
}

struct DoCatchTryThrowsBootcamp: View {
    
    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()
    
    var body: some View {
        Text(viewModel.text)
            .frame(width: 300, height: 300)
            .background(Color.pink)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

struct DoCatchTryThrowsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        DoCatchTryThrowsBootcamp()
    }
}
