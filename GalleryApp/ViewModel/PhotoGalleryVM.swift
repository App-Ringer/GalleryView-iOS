//
//  PhotoGalleryVM.swift
//  GalleryApp
//
//  Created by Sourav Mishra on 27/04/23.
//

import UIKit
import Photos

class PhotoGalleryVM {
    //MARK: - Properties -
    var allPhotos: [String: [ImageAssetModel]] = [:]
    var createdDate = [String]()
    var displayCreatedDate = [String]()
    var storedDisplayCreatedDate = [String]()
    
    var sectionData: Int = 10
    var isFetchingData: Bool = true
    
    var selectedIndex: IndexPath?
    var toolTipIndex: IndexPath?
    
    var lastIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var insertedIndexArr = [IndexPath]()
    var firstTime: Bool = true
    
    var portraitRowCellCount = PORTRAIT_MODE_MIN
    var landscapeRowCellCount = LANDSCAPE_MODE_MIN
    
    var shouldDismiss: ((Bool) -> ())?
    
    func getRowNumber(collectionView: UICollectionView) {
        if let tIndex = self.toolTipIndex, let sIndex = self.selectedIndex {
            if (sIndex.row >= tIndex.row) && (sIndex.section == tIndex.section) {
                self.selectedIndex = IndexPath(item: (sIndex.row - 1), section: sIndex.section)
            }
        }
        self.removeToolTipObj(collectionView: collectionView)
        
        guard let index = selectedIndex else { return }
        guard var assetModelArr = allPhotos[displayCreatedDate[index.section]] else { return }
        
        let assetModel = assetModelArr[selectedIndex?.row ?? 0]
        let rowCount = Int(UIDevice.current.orientation.isLandscape ? landscapeRowCellCount : portraitRowCellCount)
        var currentRow = 0
        let val = index.row + 1
        let item = val % rowCount
        if item != 0 {
            currentRow = currentRow + 1
        }
        
        let balance = assetModelArr.count % rowCount
        if balance != 0 {
            let needToAdd = rowCount - balance
            if needToAdd != 0 {
                for _ in 0..<(needToAdd) {
                    var dummyObj = ImageAssetModel(assest: PHAsset())
                    dummyObj.isDummyCell = true
                    assetModelArr.append(dummyObj)
                }
            }
        }
        
        let dVal = val / rowCount
        
        currentRow = currentRow + Int(dVal)
        
        var toolTipObj = ImageAssetModel(assest: PHAsset())
        toolTipObj.isToolTip = true
        let fileName = assetModel.asset.originalFilename
        let valArr = fileName.components(separatedBy: ".")
        let type = valArr.last ?? ""
        toolTipObj.fileName = fileName
        toolTipObj.fileType = type
        
        var newRow = currentRow*rowCount
        if newRow < assetModelArr.count {
            assetModelArr.insert(toolTipObj, at: newRow)
        } else {
            assetModelArr.append(toolTipObj)
            newRow = assetModelArr.count - 1
        }
        self.allPhotos[self.displayCreatedDate[index.section]] = assetModelArr
        
        self.toolTipIndex = IndexPath(item: newRow, section: index.section)
    }
    
    
    func removeToolTipObj(collectionView: UICollectionView) {
        if let tIndex = self.toolTipIndex {
            var oldData = allPhotos[displayCreatedDate[tIndex.section]]
            oldData?.remove(at: tIndex.row)
            oldData?.removeAll(where: {$0.isDummyCell == true})
            allPhotos[displayCreatedDate[tIndex.section]] = oldData
            self.toolTipIndex = nil
            if !insertedIndexArr.isEmpty {
                collectionView.deleteItems(at: insertedIndexArr)
                insertedIndexArr.removeAll()
            }
        }
    }
    
    func redirectToSetting() {
        let alertController = UIAlertController(
            title: "Photos Access Disabled",
            message: "Photos Access Disabled. please enable it from setting.",
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (action) in
            if let url = URL(string:UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        }
        alertController.addAction(openAction)
        if let viewController = UIApplication.shared.delegate?.window??.rootViewController {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    func presentImageViewer( selectedAsset: PHAsset, collectionView: UICollectionView, viewController: UIViewController) {
        if let index = selectedIndex {
            (collectionView.cellForItem(at: index) as? SelectPhotoCell)?.contentView.layer.borderWidth = 0
        }
        selectedIndex = nil
        removeToolTipObj(collectionView: collectionView)
        
        let options = PHImageRequestOptions()
        options.version = .original
        PHImageManager.default().requestImage(for: selectedAsset, targetSize: CGSize(width: 1000, height: 1000), contentMode: .aspectFit, options: options) { image, _ in
            guard let image = image else { return }
            let vc = viewController.storyboard?.instantiateViewController(withIdentifier: "ImageViewerVC") as! ImageViewerVC
            vc.image = image
            vc.shouldDismiss = { [weak self] dismissVC in
                self?.shouldDismiss?(dismissVC)
            }
            viewController.present(vc, animated: true)
        }
    }
    
    
    func collectionDidSelect(indexPath: IndexPath, collectionView: UICollectionView) {
        collectionView.performBatchUpdates {
            getRowNumber(collectionView: collectionView)
            if let index = self.toolTipIndex,let oldData = allPhotos[displayCreatedDate[index.section]]  {
                let dummyArr = oldData.filter({$0.isDummyCell == true})
                if !dummyArr.isEmpty {
                    let actualCellCount = (oldData.count-1) - dummyArr.count
                    for val in actualCellCount..<(oldData.count - 1) {
                        if val > index.item {
                            insertedIndexArr.append(IndexPath(item: val+1, section: index.section))
                        } else {
                            insertedIndexArr.append(IndexPath(item: val, section: index.section))
                        }
                    }
                }
                insertedIndexArr.append(index)
                print(insertedIndexArr)
                collectionView.insertItems(at: insertedIndexArr)
            }
        } completion: { finish in
            if finish, let tIndex = self.toolTipIndex {
                let attributes = collectionView.layoutAttributesForItem(at: tIndex)
                if let frameValue = attributes?.frame, !collectionView.bounds.contains(frameValue ) {
                    collectionView.scrollToItem(at: tIndex, at: .bottom, animated: true)
                }
            }
        }
    }
}

//MARK: - Fetch Images and Pagination -
extension PhotoGalleryVM {
    func getImages(date: String, index: Int, dateIndex: Int, activityIndicator: UIActivityIndicatorView, collectionView: UICollectionView) {
        if let assestModel =  allPhotos[date]?[index] {
            let options = PHImageRequestOptions()
            options.version = .original
            PHImageManager.default().requestImage(for: assestModel.asset, targetSize: CGSize(width: 250, height: 250), contentMode: .aspectFill, options: options) { image, val in
                guard let image = image else {
                    self.allPhotos[date]?.remove(at: index)
                    if let arr = self.allPhotos[date], arr.count > index {
                        let dIndex = dateIndex
                        let d = self.createdDate[dIndex]
                        self.getImages(date: d, index: index, dateIndex: dIndex, activityIndicator: activityIndicator, collectionView: collectionView)
                    } else {
                        self.createdDate.remove(at: dateIndex)
                        if self.displayCreatedDate.indices.contains(dateIndex) {
                            self.displayCreatedDate.remove(at: dateIndex)
                        }
                        
                        if (self.createdDate.count - 1) >= dateIndex {
                            let dIndex = dateIndex
                            let d = self.createdDate[dIndex]
                            self.getImages(date: d, index: 0, dateIndex: dIndex, activityIndicator: activityIndicator, collectionView: collectionView)
                        } else {
                            activityIndicator.isHidden = true
                        }
                    }
                    
                    return
                }
                
                self.allPhotos[date]?[index].image = image
                if let arrCount = self.allPhotos[date]?.count, (arrCount - 1) > index {
                    self.getImages(date: date, index: index + 1, dateIndex: dateIndex, activityIndicator: activityIndicator, collectionView: collectionView)
                } else {
                    print("createdDate.count => \((self.createdDate.count - 1)) dateIndex => \(dateIndex)")
                    if (self.createdDate.count - 1) > dateIndex , dateIndex < self.sectionData{
                        let dIndex = dateIndex + 1
                        let d = self.createdDate[dIndex]
                        self.getImages(date: d, index: 0, dateIndex: dIndex, activityIndicator: activityIndicator, collectionView: collectionView)
                    } else {
                        if self.firstTime {
                            collectionView.reloadData()
                            activityIndicator.isHidden = true
                            self.firstTime = false
                        } else {
                            self.storedDisplayCreatedDate.append(self.createdDate[dateIndex])
                        }
                        self.isFetchingData = false
                        self.paginationData(activityIndicator: activityIndicator, collectionView: collectionView)
                    }
                }
            }
        }
    }
    
    func fetchPhotos(activityIndicator: UIActivityIndicatorView, collectionView: UICollectionView) {
        activityIndicator.isHidden = false
        PHPhotoLibrary.requestAuthorization { (status) in
            switch status {
            case .authorized:
                print("Good to proceed")
                let fetchOptions = PHFetchOptions()
                let photos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                
                for n in 0..<(photos.count) {
                    let asset = photos.object(at: n)
                    if self.createdDate.isEmpty {
                        if let cDate = asset.creationDate?.convertDateToString() {
                            self.createdDate.append(cDate)
                            self.allPhotos[cDate] = [ImageAssetModel(assest: asset)]
                        }
                    } else {
                        if let cDate = asset.creationDate?.convertDateToString() {
                            if var allAsset = self.allPhotos[cDate] {
                                let m = ImageAssetModel(assest: asset)
                                allAsset.append(m)
                                self.allPhotos[cDate] = allAsset
                                
                            } else {
                                self.createdDate.append(cDate)
                                self.allPhotos[cDate] = [ImageAssetModel(assest: asset)]
                            }
                        }
                    }
                    print(asset.creationDate?.convertDateToString() ?? "")
                }
                self.createdDate.sort(by: { $0.convertStringToDate().compare($1.convertStringToDate()) == .orderedDescending })
                self.sectionData = self.createdDate.count > self.sectionData ? self.sectionData : self.createdDate.count
                self.displayCreatedDate = Array(self.createdDate[0..<self.sectionData])
                self.getImages(date: self.createdDate.first ?? "", index: 0, dateIndex: 0, activityIndicator: activityIndicator, collectionView: collectionView)
                DispatchQueue.main.async {
                    //                    self.collectionView.reloadData()
                }
            case .denied, .restricted:
                print("Not allowed")
                DispatchQueue.main.async {
                    activityIndicator.isHidden = true
                    self.redirectToSetting()
                }
            case .notDetermined:
                print("Not determined yet")
                activityIndicator.isHidden = true
            case .limited:
                print("limited ")
                activityIndicator.isHidden = true
            @unknown default:
                break
            }
        }
    }
    
    func paginationData(activityIndicator: UIActivityIndicatorView, collectionView: UICollectionView) {
        if !isFetchingData && createdDate.count > sectionData {
            isFetchingData = true
            let newIndex = sectionData
            sectionData = sectionData + 1
            self.getImages(date: createdDate[newIndex], index: 0, dateIndex: newIndex, activityIndicator: activityIndicator, collectionView: collectionView)
        }
    }
}

extension PhotoGalleryVM {
    func getNumberOfSections() -> Int {
        return self.displayCreatedDate.count
    }
    
    func getNumberOfRows(inSection section: Int) -> Int {
        return self.allPhotos[self.displayCreatedDate[section]]?.count ?? 0
    }
    
    func getItemAtIndex(_ indexPath: IndexPath) -> ImageAssetVM? {
        guard let assetModel = self.allPhotos[self.displayCreatedDate[indexPath.section]]?[indexPath.row] else {
            return nil
        }
        
        let vm = ImageAssetVM(model: assetModel)
        return vm
    }
    
    func getItemListAtIndex(_ indexPath: IndexPath) -> [ImageAssetVM]? {
        guard let assetModel = self.allPhotos[self.displayCreatedDate[indexPath.section]] else {
            return nil
        }
        
        let vm = assetModel.map({ImageAssetVM(model: $0)})  
        return vm
    }
    
    func appendStoreDateToDisplayDate() {
        self.displayCreatedDate.append(contentsOf: self.storedDisplayCreatedDate)
        self.storedDisplayCreatedDate.removeAll()
    }
    
    func getDisplayDate(indexPath: IndexPath) -> String {
        return self.displayCreatedDate[indexPath.section]
    }
}
