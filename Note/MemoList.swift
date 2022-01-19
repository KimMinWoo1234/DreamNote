//
//  MemoList.swift
//  Note
//
//  Created by dream on 2021/10/13.
//

import SwiftUI
//DataBase
import CoreData
//Touch ID, Face ID
import LocalAuthentication

struct MemoList {
    
    @FetchRequest(
        entity: TreeNode.entity(),
        sortDescriptors: [NSSortDescriptor(key: "allOrder", ascending: true)]
    )var listItems: FetchedResults<TreeNode>

    @Environment(\.managedObjectContext) var managedObjectContext: NSManagedObjectContext

    var root: Folder?
    var fetchRequest: FetchRequest<TreeNode>
    var fetchedResults: FetchedResults<TreeNode> {
        fetchRequest.wrappedValue
    }

    var fetchedResults1: FetchedResults<TreeNode> {
        root == nil ? listItems : fetchRequest.wrappedValue
    }
    
    @State var selection = Set<TreeNode>()
    @State var isEditing = false
    @State var tag:Int? = nil
    @State var showPopUp = false
    @State var go: TreeNode?
    
    init(root: Folder? = nil) {
        self.root = root
        fetchRequest = FetchRequest(fetchRequest: TreeNode.getNodes(root: root))
    }

    //드래그 삭제
    func deleteItem(indexSet: IndexSet) {
        withAnimation{
            indexSet.map {fetchedResults1[$0]}.forEach(managedObjectContext.delete)
            order_reset()
            saveItems()
        }
    }

    //고정
    func pin(listItem: TreeNode?) {

        listItem?.pin.toggle()

        order_reset()
        saveItems()
    }

    //순서변경
    func moveItem(indexSet: IndexSet, destination: Int) {
        let source = indexSet.first!
        withAnimation {
            if root == nil {
                if source < destination {
                    
                    var startIndex = source + 1
                    let endIndex = destination - 1
                    var startOrder = fetchedResults1[source].allOrder
                    while startIndex <= endIndex {
                        fetchedResults1[startIndex].allOrder = startOrder
                        startOrder = startOrder + 1
                        startIndex = startIndex + 1
                    }
                    fetchedResults1[source].allOrder = startOrder
                } else if destination < source {
                    var startIndex = destination
                    let endIndex = source - 1
                    var startOrder = fetchedResults1[destination].allOrder + 1
                    let newOrder = fetchedResults1[destination].allOrder
                    while startIndex <= endIndex {
                        fetchedResults1[startIndex].allOrder = startOrder
                        startOrder = startOrder + 1
                        startIndex = startIndex + 1
                    }
                    fetchedResults1[source].allOrder = newOrder
                }
            }else {
                if source < destination {
                    
                    var startIndex = source + 1
                    let endIndex = destination - 1
                    var startOrder = fetchedResults1[source].order
                    while startIndex <= endIndex {
                        fetchedResults1[startIndex].order = startOrder
                        startOrder = startOrder + 1
                        startIndex = startIndex + 1
                    }
                    fetchedResults1[source].order = startOrder
                } else if destination < source {
                    var startIndex = destination
                    let endIndex = source - 1
                    var startOrder = fetchedResults1[destination].order + 1
                    let newOrder = fetchedResults1[destination].order
                    while startIndex <= endIndex {
                        fetchedResults1[startIndex].order = startOrder
                        startOrder = startOrder + 1
                        startIndex = startIndex + 1
                    }
                    fetchedResults1[source].order = newOrder
                }
            }
            saveItems()
            order_reset()
        }
    }

    //저장
    func saveItems() {
        do {
            try managedObjectContext.save()
        } catch {
            print(error)
        }
    }

    //선택 삭제
    private func deleteNumbers() {

        for node in selection {
            node.trash.toggle()
        }

        saveItems()
        selection = Set<TreeNode>()
    }


    //선택 고정
    func pinNumbers() {

        for node in selection {
            node.pin.toggle()
        }

        order_reset()
        saveItems()
        selection = Set<TreeNode>()
    }

    //선택 즐겨찾기
    func starNumbers() {

        for node in selection {
            node.star.toggle()
        }

        saveItems()
        selection = Set<TreeNode>()
    }

    //순서 리셋
    func order_reset() {
        var count = 0

        order_reset_file(trash: false, pin: true)
        order_reset_file(trash: false, pin: false)
        order_reset_file(trash: true, pin: true)
        order_reset_file(trash: true, pin: false)

        saveItems()

        func order_reset_file(trash: Bool, pin: Bool) {
            for node in fetchedResults1 {
                if node.memoName != "" && node.trash == trash && node.pin == pin {
                    if root == nil {
                        node.allOrder = count
                    }else {
                        node.order = count
                    }
                    count = count + 1
                }
            }
        }
    }


    //모두선택
    func AllChoose() {
        if fetchedResults1.count != selection.count{
            selection = Set<TreeNode>(fetchedResults1)
        }else{
            selection = Set<TreeNode>()
        }
    }

    //파일 잠금
    func Lock(listItem: TreeNode?, LockCk: String?) {

        let authContext = LAContext()

        var error: NSError?

        var description: String!

        // Touch ID・Face ID를 사용할 수 있는경우
        if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {

            if authContext.biometryType == .faceID {
                description = "계정 정보를 열람하기 위해서 Face ID로 인증 합니다."
            }
            if authContext.biometryType == .touchID {
                description = "계정 정보를 열람하기 위해서 Touch ID로 인증 합니다."
            }

            //암호입력 버튼 비활성화
            authContext.localizedFallbackTitle = ""

            //생체인증 실행
            authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: description) { (success, error) in
                if success {
                    if LockCk == "이동" {
                        go = listItem
                        tag = 333
                    }
                    if LockCk == "잠금/해제" {
                        listItem!.lock.toggle()
                    }
                    
                    if LockCk == "선택 잠금/해제" {
                        for node in selection {
                            node.lock.toggle()
                        }
                        selection = Set<TreeNode>()
                    }

                    print(success)
                } else {
                    print(error!.localizedDescription)
                }
            }
        }else{
            // Touch ID・Face ID를 사용할 수 없지만, Pin잠금은 사용할 수 있는경우
            if authContext.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
                description = "계정 정보를 열람하기 위해서는 로그인하십시오."

                //Pin인증 실행
                authContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: description) { (success, error) in
                    if success {
                        if LockCk == "이동" {
                            go = listItem
                            tag = 333
                        }
                        if LockCk == "잠금/해제" {
                            listItem!.lock.toggle()
                        }
                        
                        if LockCk == "선택 잠금/해제" {
                            for node in selection {
                                node.lock.toggle()
                            }
                            selection = Set<TreeNode>()
                        }
                    } else {

                    }
                }
            }else{
                // Touch ID・Face ID를 사용할 수 없고, Pin잠금도 사용할 수 없는경우
                let alert = UIAlertController(title: "단말기의 잠금을 설정해 주세요.", message: "", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "확인", style: .cancel) { _ in })
                showAlert(alert: alert)
            }
        }
    }
}

//화면
extension MemoList: View {
    
    var body: some View {
        ZStack{
            //휴지통
            NavigationLink(
                destination: Trash(),
                tag: 1,
                selection: self.$tag){}

            //메모 수정
            NavigationLink(
                destination: memoview(root: go, Title: go?.memoName ?? "", memo: go?.memo ?? ""),
                tag: 333,
                selection: self.$tag){}

            List(selection: $selection) {

                Section(header: Text("파일: \(fetchedResults1.count)개"), content: {

                    //모두선택 버튼
                    if(self.isEditing == true){

                        Button(action: {AllChoose()}) {
                            HStack {
                                Image(systemName: fetchedResults1.count == selection.count &&
                                      fetchedResults1.count != 0 ? "checkmark.circle.fill" : "circle")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(fetchedResults1.count == selection.count && fetchedResults1.count != 0 ? .green : .gray)
                                    .font(.system(size: 20, weight: .bold, design: .default))
                                    .onTapGesture {
                                        AllChoose()
                                    }
                                Button(action: {AllChoose()}) {
                                    Text("모두 선택")
                                        .foregroundColor(.primary)
                                    Spacer()
                                }
                            }
                        }
                    }

                    //파일
                    ForEach(fetchedResults1, id: \.self) { node in
                        if node.trash == false {
                            HStack {
                                Image(systemName: node.star ? "star.fill" : "doc.text")
                                    .foregroundColor(node.star ? .yellow : nil)

                                VStack(alignment: .leading) {
                                    Text("\(node.memoName)")
                                        .bold()
                                        .environment(\.managedObjectContext, managedObjectContext)
                                        .foregroundColor(.primary)
                                        .contextMenu /*@START_MENU_TOKEN@*/{
                                            Button{pin(listItem: node)}
                                        label:{Label("파일 고정", systemImage: "pin.fill")}

                                            Button{star(listItem: node)}
                                        label:{Label(node.star ? "즐겨찾기 취소" : "즐겨찾기 추가",
                                                     systemImage: node.star ? "star.slash.fill" : "star.fill")}

                                            Button{Lock(listItem: node, LockCk: "잠금/해제")}
                                        label:{Label(node.lock ? "잠금 해제" : "파일 잠금",
                                                     systemImage: node.lock ? "lock.slash.fill" : "lock.fill")}
                                        }/*@END_MENU_TOKEN@*/
                                    Text("\(node.editingDay)").foregroundColor(.gray)
                                }

                                if isEditing == false && node.lock == false {
                                    NavigationLink(destination: memoview(root: node, Title: node.memoName, memo: node.memo)) {}.frame(width: 0)
                                }

                                Spacer()

                                if node.lock == true{

                                    Button(action: {Lock(listItem: node, LockCk: "이동")}) {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.primary)
                                    }
                                }

                                node.pin ? Image(systemName: "pin.fill") : nil
                            }
                        }
                    }
                    .onDelete(perform: deleteItem)
                    .onMove(perform: moveItem)
                })
            }
            .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive)).animation(Animation.spring(), value: self.isEditing)
            .listStyle(InsetGroupedListStyle())

            //플로팅 버튼
            if(self.isEditing == true) {
                ZStack {
                    if showPopUp {
                        HStack(spacing: 15) {
                            Button(action: {pinNumbers()}) {
                                floting(iconName: "pin.circle.fill")
                            }.offset(y: -40)
                            Button(action: {starNumbers()}) {
                                floting(iconName: "star.circle.fill")
                            }.offset(y: -60)
                            Button(action: {Lock(listItem: nil, LockCk: "선택 잠금/해제")}) {
                                floting(iconName: "lock.circle.fill")
                            }.offset(y: -40)
                        }
                        .transition(.scale)
                    }
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                            .frame(width: 45.0, height: 45.0)
                            .shadow(radius: 4)
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40.0, height: 40.0)
                            .foregroundColor(Color("AccentColor"))
                            .rotationEffect(Angle(degrees: showPopUp ? 135 : 0))
                    }
                    .onTapGesture {
                        withAnimation {
                            showPopUp.toggle()
                        }
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            }
        }
        
        .navigationBarTitle("\(root?.name ?? "모든 파일")")
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                //검색 버튼
                NavigationLink(destination: Search()) {
                    topBarIcon(iconName: "magnifyingglass")
                }
                
                Button(action: {
                    self.isEditing.toggle();order_reset();selection = Set<TreeNode>();showPopUp = false
                }) {
                    topBarIcon(iconName: isEditing ? "ellipsis.circle.fill" : "ellipsis.circle")
                }
            }
            
            ToolbarItemGroup(placement: .bottomBar) {
                
                Button(action: {isEditing ? deleteNumbers() : (self.tag = 1)}) {
                    trashicon(colorRed: isEditing)
                }
                
                Spacer()
                
                if(self.isEditing == true){
                    Text("\(selection.count)개 선택")
                        .frame(width: 100)
                }
                
                Spacer()
                
                //메모 작성
                NavigationLink(destination: memotext(root: root)) {
                    Image(systemName: "doc.badge.plus")
                        .resizable()
                        .frame(width: 30.0, height: 30.0)
                        .foregroundColor(.gray)
                }
            }
        }
        .onAppear(perform: order_reset)
        .onDisappear {saveItems()}
    }
}
