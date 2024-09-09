extension ListCollectionContext {
    func reload(_ sectionController: ListSectionController, animated: Bool = true) {
        self.performBatch(animated: animated, updates: { batchContext in
            batchContext.reload(sectionController)
        })
    }
}
