//
//  ContentView.swift
//  LapGrid
//
//  Created by Sergei Laptev on 25/04/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var draggedItem: TableElement?
    @State private var data: [TableElement] = [
        TableElement(id: 1, title: "1", spans: 1),
        TableElement(id: 2, title: "2", spans: 1),
        TableElement(id: 3, title: "3 Spans Two", spans: 2),
        TableElement(id: 4, title: "4", spans: 1),
        TableElement(id: 5, title: "5", spans: 1),
        TableElement(id: 6, title: "6 Spans Two", spans: 2),
        TableElement(id: 7, title: "7", spans: 1),
        TableElement(id: 8, title: "8", spans: 1),
        TableElement(id: 9, title: "9", spans: 1),
        TableElement(id: 10, title: "10 Spans Two", spans: 2),
        TableElement(id: 11, title: "11", spans: 1),
    ]
    @State private var data2: [TableElement] = [
        TableElement(id: 1, title: "1", spans: 1),
        TableElement(id: 2, title: "2", spans: 1),
        TableElement(id: 3, title: "3 Spans Two", spans: 2),
        TableElement(id: 4, title: "4", spans: 1),
        TableElement(id: 5, title: "5", spans: 1),
        TableElement(id: 6, title: "6 Spans Two", spans: 2),
        TableElement(id: 7, title: "7 Spans Three", spans: 3),
        TableElement(id: 8, title: "8", spans: 1),
        TableElement(id: 9, title: "9", spans: 1),
        TableElement(id: 10, title: "10 Spans Two", spans: 2),
        TableElement(id: 11, title: "11", spans: 1),
    ]
    @State private var data3: [TableElement] = [
        TableElement(id: 1, title: "1", spans: 1),
        TableElement(id: 2, title: "2", spans: 1),
        TableElement(id: 3, title: "3 Spans Two", spans: 2),
        TableElement(id: 4, title: "4", spans: 1),
        TableElement(id: 5, title: "5", spans: 1),
        TableElement(id: 6, title: "6 Spans Two", spans: 2),
        TableElement(id: 7, title: "7", spans: 1),
        TableElement(id: 8, title: "8", spans: 1),
        TableElement(id: 9, title: "9", spans: 1),
        TableElement(id: 10, title: "10 Spans Two", spans: 2),
        TableElement(id: 11, title: "11", spans: 1),
    ]
    
    var randomHeight: CGFloat {
        CGFloat.random(in: 30...80)
        }
    
    var body: some View {
        ScrollView {
            LapGrid {
                ForEach(data) { dataItem in
                    Text(dataItem.title)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.secondary)
                        )
                        .onDrag {
                            draggedItem = dataItem
                            return NSItemProvider(object: "\(dataItem.id)" as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: DragDropDelegate(draggedItem: $draggedItem, item: dataItem, data: $data)
                        )
                        // Share span to the layout
                        .span(dataItem.spans)
                }
            }
            .padding(.bottom, 50)
            
            LapGrid(maxColumns: 3, spacing: 16) {
                ForEach(data2) { dataItem in
                    Text(dataItem.title)
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.secondary)
                        )
                        .onDrag {
                            draggedItem = dataItem
                            return NSItemProvider(object: "\(dataItem.id)" as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: DragDropDelegate(draggedItem: $draggedItem, item: dataItem, data: $data2)
                        )
                    // Share span to the layout
                        .span(dataItem.spans)
                }
            }
            .padding(.bottom, 50)
            
            LapGrid(spacing: 12) {
                ForEach(data3) { dataItem in
                    Text(dataItem.title)
                        .frame(maxWidth: .infinity, minHeight: randomHeight)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.secondary)
                        )
                        .onDrag {
                            draggedItem = dataItem
                            return NSItemProvider(object: "\(dataItem.id)" as NSString)
                        }
                        .onDrop(
                            of: [.text],
                            delegate: DragDropDelegate(draggedItem: $draggedItem, item: dataItem, data: $data3)
                        )
                    // Share span to the layout
                        .span(dataItem.spans)
                }
            }
        }
        .scrollIndicators(.hidden)
        .padding(.horizontal)
    }
}

#Preview {
    ContentView()
}

struct TableElement: Identifiable, Hashable {
    let id: Int
    let title: String
    let spans: Int
}

struct DragDropDelegate: DropDelegate {
    @Binding var draggedItem: TableElement?
    let item: TableElement
    @Binding var data: [TableElement]

    func performDrop(info: DropInfo) -> Bool {
        return true
    }

    func dropEntered(info: DropInfo) {
        if let draggedItem = draggedItem, draggedItem.id != item.id {
            let fromIndex = data.firstIndex { $0.id == draggedItem.id }!
            let toIndex = data.firstIndex { $0.id == item.id }!

            withAnimation {
                data.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        return DropProposal(operation: .move)
    }
}
