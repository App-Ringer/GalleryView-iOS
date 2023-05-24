//
//  ViewController.swift
//  GalleryApp
//
//  Created by Mohit Kumar on 09/03/23.
//

import UIKit
import Photos

class PhotoGalleryVC: UIViewController {
    //MARK: - IBOutlet -
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewHeight: NSLayoutConstraint!
    
    //MARK: - Properties -
    var gesture: UIPinchGestureRecognizer!    
    var photoGalleryVM = PhotoGalleryVM()
    
    //MARK: - ViewController Life Cycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadOps()
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(handleTapEmptySpaceGesture))
        tapGestureRecogniser.delegate = self
        collectionView.addGestureRecognizer(tapGestureRecogniser)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        if let index = photoGalleryVM.selectedIndex {
            (collectionView.cellForItem(at: index) as? SelectPhotoCell)?.contentView.layer.borderWidth = 0
        }
        photoGalleryVM.selectedIndex = nil
        photoGalleryVM.removeToolTipObj(collectionView: self.collectionView)
        
        self.collectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.collectionView.scrollToItem(at: self.photoGalleryVM.lastIndexPath, at: .top, animated: false)
        }
    }
    
    func viewDidLoadOps() {
        setCollectionView()
        photoGalleryVM.fetchPhotos(activityIndicator: self.activityIndicator, collectionView: self.collectionView, bottomView: bottomView, bottomViewHeight: bottomViewHeight)
        
        gesture = UIPinchGestureRecognizer(target: self, action: #selector(didReceivePinchGesture(gesture:)))
        collectionView.addGestureRecognizer(gesture)
        
        photoGalleryVM.shouldDismiss = { dismissVC in
            guard dismissVC else {
                return
            }
            
            self.dismissGalleryView()
        }
    }
    
    func setCollectionView() {
        let podBundle = Bundle(for: SelectPhotoCell.self)
        collectionView.register(UINib(nibName: "SelectPhotoCell", bundle: podBundle), forCellWithReuseIdentifier: "SelectPhotoCell")
        collectionView.register(UINib(nibName: "CollectionHeaderView", bundle: podBundle), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier:"CollectionHeaderView")
        collectionView.register(UINib(nibName: "ToolTipCell", bundle: podBundle), forCellWithReuseIdentifier: "ToolTipCell")
    }
    
    @objc func didReceivePinchGesture(gesture: UIPinchGestureRecognizer) {
        if gesture.state == UIPinchGestureRecognizer.State.began {
            if let index = photoGalleryVM.selectedIndex {
                (collectionView.cellForItem(at: index) as? SelectPhotoCell)?.contentView.layer.borderWidth = 0
            }
            photoGalleryVM.selectedIndex = nil
            photoGalleryVM.removeToolTipObj(collectionView: self.collectionView)
            self.collectionView.reloadData()
        } else if gesture.state == UIPinchGestureRecognizer.State.changed {

        } else if gesture.state == UIPinchGestureRecognizer.State.ended ||
                    gesture.state == UIPinchGestureRecognizer.State.cancelled {
            
            if gesture.scale < 1 {
                if UIDevice.current.orientation.isLandscape {
                    guard (photoGalleryVM.landscapeRowCellCount < LANDSCAPE_MODE_MAX) else {
                        return
                    }
                    photoGalleryVM.landscapeRowCellCount += 1
                } else {
                    guard (photoGalleryVM.portraitRowCellCount < PORTRAIT_MODE_MAX) else {
                        return
                    }
                    photoGalleryVM.portraitRowCellCount += 1
                }
            } else {
                if UIDevice.current.orientation.isLandscape {
                    guard (photoGalleryVM.landscapeRowCellCount > PORTRAIT_MODE_MAX) else {
                        return
                    }
                    photoGalleryVM.landscapeRowCellCount -= 1
                } else {
                    guard (photoGalleryVM.portraitRowCellCount > PORTRAIT_MODE_MIN) else {
                        return
                    }
                    photoGalleryVM.portraitRowCellCount -= 1
                }
            }
            
            let newLayout = UICollectionViewFlowLayout()
            self.collectionView.setCollectionViewLayout(newLayout, animated: true) {_ in
                
            }
        }
    }
    
    //MARK: - IBAction
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        let json = ["success": false, "imageData": ""] as [String : Any]
        GalleryView.resultCallBack?(json)
        self.dismissGalleryView()
    }
    
    func dismissGalleryView() {
        if GalleryView.isNaigationControllerPresent {
            self.dismiss(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - CollectionView Delegate And DataSource -
extension PhotoGalleryVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return photoGalleryVM.getNumberOfSections()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoGalleryVM.getNumberOfRows(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let assetVM = photoGalleryVM.getItemAtIndex(indexPath) else {
            return UICollectionViewCell()
        }
        if assetVM.isToolTip {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "ToolTipCell", for: indexPath) as! ToolTipCell
            let rowCount = UIDevice.current.orientation.isLandscape ? photoGalleryVM.landscapeRowCellCount : photoGalleryVM.portraitRowCellCount
            let cellWidth = self.collectionView.frame.size.width / rowCount
            cell.setData(photoGalleryVM: photoGalleryVM, assetModel: assetVM, cellWidth: cellWidth, rowCount: rowCount)
            return cell
        } else {
            let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "SelectPhotoCell", for: indexPath) as! SelectPhotoCell
            cell.setData(photoGalleryVM: photoGalleryVM, assetModel: assetVM, indexPath: indexPath)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SelectPhotoCell else {
            guard let selectedAssetIndex = photoGalleryVM.selectedIndex else {
                return
            }
            guard let assetVMArr = photoGalleryVM.getItemListAtIndex(selectedAssetIndex) else {
                return
            }
            let assetVM = assetVMArr[selectedAssetIndex.row]
            self.photoGalleryVM.presentImageViewer(selectedAsset: assetVM.asset, collectionView: self.collectionView, viewController: self)
            return
        }
        
        if photoGalleryVM.selectedIndex == indexPath {
            self.photoGalleryVM.selectedIndex = nil
            photoGalleryVM.removeToolTipObj(collectionView: self.collectionView)
            cell.contentView.layer.borderWidth = 0
            return
        } else {
            if let index = photoGalleryVM.selectedIndex {
                (collectionView.cellForItem(at: index) as? SelectPhotoCell)?.contentView.layer.borderWidth = 0
            }
        }
        
        guard let assetModelArr = photoGalleryVM.getItemListAtIndex(indexPath), !assetModelArr[indexPath.row].isDummyCell else {
            self.photoGalleryVM.selectedIndex = nil
            photoGalleryVM.removeToolTipObj(collectionView: self.collectionView)
            return
        }
        
        photoGalleryVM.selectedIndex = indexPath
        cell.contentView.layer.borderWidth = 1
        cell.contentView.layer.borderColor = UIColor.red.cgColor
        self.photoGalleryVM.collectionDidSelect(indexPath: indexPath, collectionView: self.collectionView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionHeaderView", for: indexPath) as! CollectionHeaderView
            headerView.lblText.text = photoGalleryVM.getDisplayDate(indexPath: indexPath)
            return headerView
        case UICollectionView.elementKindSectionFooter:
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionHeaderView", for: indexPath)
            
            footerView.backgroundColor = UIColor.green
            return footerView
            
        default:
            assert(false, "Unexpected element kind")
            return UIView(frame: .zero) as! UICollectionReusableView
        }
    }
    
    @objc func goToImageViewer(sender: UIButton) {
        guard let selectedAssetIndex = photoGalleryVM.selectedIndex else {
            return
        }
        guard let assetVMArr = photoGalleryVM.getItemListAtIndex(selectedAssetIndex) else { return }
        
        let assetVM = assetVMArr[selectedAssetIndex.row]
        self.photoGalleryVM.presentImageViewer(selectedAsset: assetVM.asset, collectionView: self.collectionView, viewController: self)
    }
}

//MARK: - ScrollView Delegate -
extension PhotoGalleryVC {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !photoGalleryVM.storedDisplayCreatedDate.isEmpty {
            photoGalleryVM.appendStoreDateToDisplayDate()
            self.collectionView.reloadData()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        calculateVisibleIndexPath()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        calculateVisibleIndexPath()
        if ((collectionView.contentOffset.y + collectionView.frame.size.height) >= collectionView.contentSize.height) && (photoGalleryVM.createdDate.count > photoGalleryVM.sectionData) {
            if (photoGalleryVM.createdDate.count - 1)  > photoGalleryVM.sectionData {
                photoGalleryVM.bottomView(isHidden: false, bottomView: bottomView, bottomViewHeight: bottomViewHeight)
            }
        }
    }
    
    func calculateVisibleIndexPath() {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.minX, y: visibleRect.minY)
        
        if let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint) {
            photoGalleryVM.lastIndexPath = visibleIndexPath
        }
    }
}

//MARK: - CollectionView  FlowLayout -
extension PhotoGalleryVC : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) // margin between cells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath == photoGalleryVM.toolTipIndex {
            return CGSize(width: (self.collectionView.bounds.size.width), height: 120)
        } else {
            let rowCount = UIDevice.current.orientation.isLandscape ? photoGalleryVM.landscapeRowCellCount : photoGalleryVM.portraitRowCellCount
            let width = collectionView.frame.size.width / CGFloat(rowCount)
            return CGSize(width: width, height: width)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}

//MARK: - Gesture Delegate -
extension PhotoGalleryVC: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // only handle tapping empty space (i.e. not a cell)
        let point = gestureRecognizer.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: point)
        return indexPath == nil
    }
    
    @objc func handleTapEmptySpaceGesture() {
        if let index = photoGalleryVM.selectedIndex {
            (collectionView.cellForItem(at: index) as? SelectPhotoCell)?.contentView.layer.borderWidth = 0
        }
        self.photoGalleryVM.selectedIndex = nil
        photoGalleryVM.removeToolTipObj(collectionView: self.collectionView)
    }
}

