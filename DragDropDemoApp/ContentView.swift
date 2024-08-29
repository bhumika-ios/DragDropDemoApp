//
//  ContentView.swift
//  DragDropDemoApp
//
//  Created by Bhumika Patel on 27/08/24.
//

import SwiftUI

enum Progress: Codable {
    case ToDo
    case InProgress
    case Done
}

struct ProgressStatus: Hashable {
    var name: String
    var tasks: [Task]
    var status: Progress
}

struct Task: Hashable, Transferable, Codable {
    var name: String
    var storypoints: Int
    var status: Progress
    
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .vCard)
    }
}




struct ContentView: View {
    @State var progress = [
        ProgressStatus(name: "To Do", tasks: [Task(name: "Implement Customer's Feedback on Refferal Program", storypoints: 6, status: .ToDo),Task(name: "Enhance UI/UX", storypoints: 4, status: .Done)], status: .ToDo),
        ProgressStatus(name: "In Progress", tasks: [Task(name: "Add Payment Gateways Option", storypoints: 3, status: .InProgress), Task(name: "Update Data", storypoints: 4, status: .InProgress)], status: .InProgress),
//        ProgressStatus(name: "Done", tasks: [Task(name: "Enhance UI/UX", storypoints: 4, status: .Done)], status: .ToDo)
    ]
    
    @State var draggingTask: Task?
    @State var theColorScheme: ColorScheme = .light

    var body: some View {
        VStack {
            Spacer()
            Text("SwiftUI Sample Kanban Board")
                .foregroundStyle((theColorScheme == .dark) ? .white : .black)
                .font(.system(size: 20))
                .bold()
            ScrollView{
                VStack {
                    ForEach($progress, id: \.self) { $progressStatus in
                        StatusColumn(name: progressStatus.name, tasks: progressStatus.tasks, theColorScheme: $theColorScheme)
                            .dropDestination(for: Task.self) { droppedTasks, location in
                                draggingTask = droppedTasks.first
                                var temp: [ProgressStatus] = []
                                
                                for var progress in progress {
                                    if progress.status != progressStatus.status {
                                        progress.tasks.removeAll {$0 == droppedTasks.first}
                                    } else {
                                        if var dropTask = droppedTasks.first, dropTask.status != progressStatus.status {
                                            dropTask.status = progressStatus.status
                                            progress.tasks.append(dropTask)
                                        }
                                    }
                                    temp.append(progress)
                                }
                                
                                progress = temp
                                
                                return true
                            } isTargeted: { status in
                                print("We are hovering at \(progressStatus.tasks)")
                            }
                    }
                }
            }
            .padding()
            Spacer()
            HStack {
                Button(action: self.toggleColorScheme) {
                    Text((theColorScheme == .dark) ? "Enable Light Mode" : "Enable Dark Mode")
                        .font(.title3)
                }
                .padding()
                .background(.gray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                Spacer()
                Text("ABDUL KARIM KHAN")
                    .foregroundStyle((theColorScheme == .dark) ? .white : .black)
                    .font(.system(size: 16))
                    .bold()
                    .padding()
            }
        }
        .frame(width: 400)
        .background((theColorScheme == .dark) ? .black : .white)
    }
    
    func toggleColorScheme() {
        theColorScheme = (theColorScheme == .dark) ? .light : .dark
    }
}


#Preview {
    ContentView()
}
//class ListViewModel: ObservableObject {
//    @Published var leftList: [ListItem] = []
//    @Published var rightList: [ListItem] = []
//    
//    func loadList(for buttonItem: ButtonItem, intoList listSide: String) {
//        switch listSide {
//        case "left":
//            leftList = buttonItem.associatedList
//        case "right":
//            rightList = buttonItem.associatedList
//        default:
//            break
//        }
//    }
//}

//struct DropViewDelegate: DropDelegate {
//    let listSide: String
//    @ObservedObject var viewModel: ListViewModel
//    let buttonItems: [ButtonItem]
//    
//    func performDrop(info: DropInfo) -> Bool {
//        guard let item = info.itemProviders(for: [.text]).first else { return false }
//        
//        item.loadItem(forTypeIdentifier: "public.text", options: nil) { (data, error) in
//            DispatchQueue.main.async {
//                if let data = data as? Data, let title = String(data: data, encoding: .utf8) {
//                    if let buttonItem = buttonItems.first(where: { $0.title == title }) {
//                        viewModel.loadList(for: buttonItem, intoList: listSide)
//                    }
//                }
//            }
//        }
//        return true
//    }
//}

struct StatusColumn: View {
    
    @State var name: String
    @State var tasks: [Task]
    @Binding var theColorScheme: ColorScheme

    var body: some View {
        ZStack {
            Color.gray.opacity(0.45).ignoresSafeArea()
            VStack (alignment: .leading) {
                Text(name)
                    .font(.caption)
                    .bold()
                    .foregroundStyle((theColorScheme == .dark) ? .white : .black)
                    .padding()
                VStack (spacing: 10) {
                    List(tasks, id: \.self) { task in
                        TaskView(name: task.name, storyPoints: task.storypoints)
                            .draggable(task)
                            .listRowBackground(Color.clear)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .scrollIndicators(.hidden)
                    .background(.clear)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 500)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TaskView: View {
    
    @State var name: String
    @State var storyPoints: Int
    
    var body: some View {
        HStack (alignment: .bottom) {
            VStack (alignment: .leading, spacing: 10) {
                Text(name)
                    .font(.caption)
                    .foregroundStyle(.black)
                HStack {
                    Image("ic-task-type")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text("CT-123")
                        .font(.title3)
                        .foregroundStyle(.black)
                }
            }
            .padding()
            Spacer()
            Image("ic-profile")
                .resizable()
                .frame(width: 20, height: 20)
                .clipShape(Circle())
                .padding()
        }
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .zIndex(2)
    }
}

#Preview {
    TaskView(name: "CT-121", storyPoints: 6)
}

extension Color {
    static var random: Color {
        return Color(red: .random(in: 0...1),
                     green: .random(in: 0...1),
                     blue: .random(in: 0...1))
    }
}
