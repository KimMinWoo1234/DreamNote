//
//  SwiftUIView.swift
//  Note2
//
//  Created by Dream on 2020/10/26.
//

import SwiftUI

struct memoview: View {
    var root: File?
    @State var Title:String
    @State var memo:String
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @Environment(\.presentationMode) var presentationMode
    
    //화면
    var body: some View {
        
        TextEditor(text: $memo)
            .onChange(of: memo, perform: { newValue in addItem()})
//            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
            .gesture(DragGesture().onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
            .padding(1)
        
            .toolbar {
                
                ToolbarItem(placement: .principal) {
                    TextField("제목없는 파일", text: $Title)
                        .onChange(of: Title, perform: { newValue in addItem()})
                        .font(.title)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {self.presentationMode.wrappedValue.dismiss()}) {
                        Text("완료")
                            .font(.title2)
                            .foregroundColor(Color.white)
                            .bold()
                            .multilineTextAlignment(.center)
                            .frame(width: 50.0, height: 50.0)
                    }
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Text("생성일 : \(root!.creationDate)").foregroundColor(.gray)
                    Spacer()
                    Text("편집일 : \(root!.editingDay)").foregroundColor(.gray)
                }
            }
    }
    
    //수정
    func addItem() {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: Date())
        self.root!.name = Title == "" ? "제목없는 파일" : Title
        self.root!.memo = memo
        self.root!.editingDay = date
                
        saveItems()
    }
    
    //db 저장
    func saveItems() {
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }
    
}
