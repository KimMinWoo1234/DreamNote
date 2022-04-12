//
//  SwiftUIView.swift
//  Note2
//
//  Created by Dream on 2020/10/26.
//

import SwiftUI

struct memotext: View {
   
   @FetchRequest(
       entity: File.entity(),
       sortDescriptors: [NSSortDescriptor(key: "allOrder", ascending: true)]
   )var listItems: FetchedResults<File>
   
   var root: Folder?
   @State var Title:String = ""
   @State var memo:String = ""
   
   @Environment(\.managedObjectContext) var managedObjectContext
   
   @Environment(\.presentationMode) var presentationMode

   //화면
   var body: some View {
      
      TextEditor(text: $memo)
         .padding(1)
         .simultaneousGesture(DragGesture(minimumDistance: 100)
         .onChanged{_ in UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)})
         
         .toolbar {
            ToolbarItem(placement: .principal) {
               TextField("제목없는 파일", text: $Title)
                  .font(.title)
                  .foregroundColor(.white)
                  .multilineTextAlignment(.center)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
               Button(action: {addItem()}) {
                  Text("완료")
                     .font(.title2)
                     .foregroundColor(Color.white)
                     .bold()
                     .multilineTextAlignment(.center)
                     .frame(width: 50.0, height: 50.0)
               }
            }
         }
   }
   
   //추가
   func addItem() {
      
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      let date = formatter.string(from: Date())
         
      let node = File(context: managedObjectContext)
      
      node.name = Title == "" ? "제목없는 파일" : Title
      node.memo = memo
      node.order = root?.children!.count ?? 0
      node.allOrder = (listItems.last?.allOrder ?? -1) + 1
      node.creationDate = date
      node.editingDay = date
      node.trash = false
      root?.childrenCount = (root?.childrenCount ?? 0) + 1
         
      node.parent = root
      saveItems()
         
      self.presentationMode.wrappedValue.dismiss()
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
