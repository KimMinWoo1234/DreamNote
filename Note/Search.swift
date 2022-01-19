import SwiftUI

struct Search: View {
    
//    @State var root: TreeNode?
//    @State var Choicelist = ""
//    @State var folder = [""]
//    @State var pinFolder = [""]
//    @State var memoName = [""]
//    @State var memo = ""
//    @State var count1 = 0
//    @State var count2 = 0
//    @State var count = 0
//    @State var tag:Int? = nil
//    @State var editingDay = [""]
//    @State var Title:String = ""
//    @State var creationDate:String = ""
//    @State var EditingDay = ""
//
//    @State private var searchText : String = ""
//
//    @FetchRequest(
//        entity: TreeNode.entity(),
//        sortDescriptors: [NSSortDescriptor(key: "order", ascending: true)]
//    )var listItems: FetchedResults<TreeNode>
//
    var body: some View {Text("a")}
//
//        //폴더
////        NavigationLink(
////            destination: MemoList(root: root),
////            tag: 1,
////            selection: self.$tag){}
//
//        //파일
//        NavigationLink(
//            destination: memoview(root: root, Title: root!.memoName, memo: root!.memo),
//            tag: 2,
//            selection: self.$tag){}
//
//
//        SearchBar(text: $searchText, placeholder: "Search").background(Color("Color"))
//
//        List {
//
//            Section(header: Text("폴더: \(count1+pinFolder.count)개")
//                , content: {
//
//                    ForEach(self.pinFolder.filter {
//                        self.searchText.isEmpty ? true : $0.lowercased().contains(self.searchText.lowercased())
//                    }, id: \.self) { node in
//                        //NavigationLink(destination: index(root: root)) {
//                        Button(action: {self.Choicelist = node;folderClick();self.tag = 1}) {
//                            HStack {
//                                Image(systemName: "folder")
//                                    .foregroundColor(.primary/*@END_MENU_TOKEN@*/)
//                                Text(node)
//                                    .foregroundColor(.primary/*@END_MENU_TOKEN@*/)
//                                Spacer()
//                                Image(systemName: "pin.fill")
//                                    .foregroundColor(.primary/*@END_MENU_TOKEN@*/)
//                            }
//                        }
//                        //  }
//                    }
//
//                    ForEach(self.folder.filter {
//                        self.searchText.isEmpty ? true : $0.lowercased().contains(self.searchText.lowercased())
//                    }, id: \.self) { node in
//                        //NavigationLink(destination: index(root: root)) {
//                        HStack{
//                            Image(systemName: "folder")
//
//                            Button(action: {self.Choicelist = node;folderClick();self.tag = 1}) {
//                                Text(node)
//                                    .foregroundColor(.primary/*@END_MENU_TOKEN@*/)
//                            }
//                        }
//                        //  }
//                    }
//                })
//
//            Section(header: Text("파일: \(count2)개")
//                , content: {
//
//                    ForEach(self.memoName.filter {
//                        self.searchText.isEmpty ? true : $0.lowercased().contains(self.searchText.lowercased())
//                    }, id: \.self) { node in
//                        ///NavigationLink(destination: memoview(editingDay: editingDay[count], root: root)) {
//
//                        HStack{
//                            Image(systemName: "doc.text")
//
//                            Button(action: {self.Choicelist = node;memoClick();self.tag = 2}) {
//                                VStack(alignment: .leading) {
//                                    Text(node)
//                                        .foregroundColor(.primary/*@END_MENU_TOKEN@*/)
//                                    Text(editingDay[count]).foregroundColor(.gray)
//                                }
//                            }
//                                        //}
//                        }
//                    }
//            })
//        }.listStyle(InsetGroupedListStyle())
//         .padding(.top, -15.0)
//
//
//        .navigationBarTitle(Text("검색"))
//        .onAppear(perform: {
//            pinFolder = []
//            editingDay = []
//            memoName = []
//            folder = []
//            count1 = 0
//            count2 = 0
//
//            for node in listItems {
//                if node.folderName != "" {
//                    if node.pin == true {
//                        pinFolder.insert(node.folderName, at: count1)
//                        count1 = count1 + 1
//                    }
//                }
//            }
//            count1 = 0
//            for node in listItems {
//                if node.folderName != "" {
//                    if node.pin == false {
//                        folder.insert(node.folderName, at: count1)
//                        count1 = count1 + 1
//                    }
//                }
//            }
//
//
//            for node in listItems {
//                if node.memoName != "" {
//                    memoName.insert(node.memoName, at: count2)
//                    editingDay.insert(node.editingDay, at: count2)
//                    count2 = count2 + 1
//                }
//            }
//
//        })
//    }
//
//    //폴더 클릭
//    func folderClick() {
//
//        for node in listItems {
//            if node.folderName == Choicelist {
//                root = node
//            }
//        }
//    }
//
//    //메모 클릭
//    func memoClick() {
//
//        for node in listItems {
//            if node.memoName == Choicelist {
//                root = node
//                Title = Choicelist
//                memo = node.memo
//                creationDate = node.creationDate
//                EditingDay = node.editingDay
//            }
//        }
//    }
    
}

//검색 바
struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    var placeholder: String
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
}
