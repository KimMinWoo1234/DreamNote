import SwiftUI
import CoreData

struct ContentView: View {
    
    var body: some View {
        NavigationView{
            index()
        }.navigationViewStyle(StackNavigationViewStyle())
        
    }
}

//alert 띄우기 속성
func showAlert(alert: UIAlertController) {
    if let controller = topMostViewController() {
        controller.present(alert, animated: true)
    }
}

private func keyWindow() -> UIWindow? {
    return UIApplication.shared.connectedScenes
        .filter {$0.activationState == .foregroundActive}
        .compactMap {$0 as? UIWindowScene}
        .first?.windows.filter {$0.isKeyWindow}.first
}

private func topMostViewController() -> UIViewController? {
    guard let rootController = keyWindow()?.rootViewController else {
        return nil
    }
    return topMostViewController(for: rootController)
}

private func topMostViewController(for controller: UIViewController) -> UIViewController {
    if let presentedController = controller.presentedViewController {
        return topMostViewController(for: presentedController)
    } else if let navigationController = controller as? UINavigationController {
        guard let topController = navigationController.topViewController else {
            return navigationController
        }
        return topMostViewController(for: topController)
    } else if let tabController = controller as? UITabBarController {
        guard let topController = tabController.selectedViewController else {
            return tabController
        }
        return topMostViewController(for: topController)
    }
    return controller
}

//뒤로가기 버튼 속성
extension UINavigationController {
    // Remove back button text
    open override func viewWillLayoutSubviews() {
        navigationBar.topItem?.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

//즐겨찾기 추가/삭제
func star(listItem: TreeNode?) {
    listItem?.star.toggle()
}

//즐겨찾기 추가/삭제
func folderStar(listItem: Folder?) {
    listItem?.star.toggle()
}

//휴지통 아이콘
struct trashicon: View {
    
    let colorRed: Bool
    
    var body: some View {
        Image(systemName: "trash.fill")
            .resizable()
            .frame(width: 30.0, height: 30.0)
            .foregroundColor(colorRed ? .red : .gray)
    }
}

//상단 바 아이콘(검색, 편집)
struct topBarIcon: View {
    
    let iconName: String?
    
    var body: some View {
        Image(systemName: iconName!)
            .resizable()
            .frame(width: 25.0, height: 25.0)
            .foregroundColor(.white)
    }
}

//플로팅 버튼
struct floting: View {
    
    let iconName: String?
    
    var body: some View {
        ZStack {
            Circle()
                .foregroundColor(.white)
                .frame(width: 35, height: 35)
                .shadow(radius: 3)
            
            Image(systemName: iconName!)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(Color("AccentColor"))
        }
    }
}

//struct nv: View {
//    @State var tag:Int? = nil
//    
//    let listItem: TreeNode?
//    
//    var body: some View {
//        //휴지통
//        NavigationLink(
//            destination: Trash(),
//            tag: 1,
//            selection: self.$tag){}
//    
//        //메모 수정
//        NavigationLink(
//            destination: memoview(root: listItem),
//            tag: 333,
//            selection: self.$tag){}
//    }
//}

