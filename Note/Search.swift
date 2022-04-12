import SwiftUI
import CoreData

struct Search: View {
    
    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext
    
    @FetchRequest(
        entity: File.entity(),
        sortDescriptors: [NSSortDescriptor(key: "allOrder", ascending: true)]
    )var listItems: FetchedResults<File>
    
    @State var searchText: String = ""
    
    var body: some View {
        List {
//            ForEach(searchText == "" ? listItems : listItems.last?.name.filter { $0.contains(searchText)}, id: \.self) { node in
            ForEach(listItems, id: \.self) { node in
                HStack {
                    Image(systemName: node.star ? "star.fill" : "doc.text")
                        .foregroundColor(node.star ? .yellow : nil)
                    
                    VStack(alignment: .leading) {
                        Text("\(node.name)")
                            .bold()
                            .environment(\.managedObjectContext, managedObjectContext)
                            .foregroundColor(.primary)
                            .contextMenu /*@START_MENU_TOKEN@*/{
                                Button{}
                            label:{Label("파일 고정", systemImage: "pin.fill")}
                                
//                                Button{star(listItem: node)}
//                            label:{Label(node.star ? "즐겨찾기 취소" : "즐겨찾기 추가",
//                                         systemImage: node.star ? "star.slash.fill" : "star.fill")}
                                
                                Button{}
                            label:{Label(node.lock ? "잠금 해제" : "파일 잠금",
                                         systemImage: node.lock ? "lock.slash.fill" : "lock.fill")}
                            }/*@END_MENU_TOKEN@*/
                        Text("\(node.editingDay)").foregroundColor(.gray)
                    }
                    
                    if node.lock == false {
                        NavigationLink(destination: memoview(root: node, Title: node.name, memo: node.memo)) {}.frame(width: 0)
                    }
                    
                    Spacer()
                    
                    if node.lock == true{
                        
                        Button(action: {}) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.primary)
                        }
                    }
                    
                    node.pin ? Image(systemName: "pin.fill") : nil
                }
            }
            .searchable(text: $searchText, placement: .toolbar)
            //.onDelete(perform: deleteItem)
            //.onMove(perform: moveItem)
        }
        
        .navigationBarTitle(Text("검색"))
    }
}
