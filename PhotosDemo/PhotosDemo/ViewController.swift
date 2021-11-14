//
//  ViewController.swift
//  PhotosDemo
//
//  Created by Ben Scheirman on 10/24/20.
//

import UIKit
import Photos
import Combine

class ViewController: UIViewController {
    
    private var cancellables: Set<AnyCancellable> = []
    private var loadPhototCancellable: AnyCancellable?
    private var loadImagesCancellable: AnyCancellable?
    private var datasource: UICollectionViewDiffableDataSource<Int, UIImage>!
    
    @IBOutlet var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasource = UICollectionViewDiffableDataSource(collectionView: collectionView, cellProvider: { (cv, indexPath, image) -> UICollectionViewCell? in
            let photoCell = cv.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
            photoCell.imageView.image = image
            return photoCell
        })
    }
    
    private func fetchPhotos() {
        let options = PHFetchOptions()
        options.fetchLimit = 50
        let fetchResult = PHAsset.fetchAssets(with: options)
        print("Fetched \(fetchResult.count) photos")
        
                let targetSize = CGSize(width: 512, height: 512)
        let assetSubject = PassthroughSubject<PHAsset, Never>()
        
        loadImagesCancellable = assetSubject
            .collect()
            .flatMap { $0.publisher }
            .print("Asset array")
            .flatMap(maxPublishers: .max(2)) {
                self.imagePublisher(for: $0, targetSize: targetSize, contentMode: .aspectFill)
                    .print("Image|: \($0.localIdentifier)")
            }
            .print("FLATMAP")
            .compactMap { $0 }
            .collect()
            .sink { images in
                var snapshot = NSDiffableDataSourceSnapshot<Int, UIImage>()
                snapshot.appendSections([0])
                snapshot.appendItems(images)
                self.datasource.apply(snapshot, animatingDifferences: true)
            }
        
        fetchResult.enumerateObjects { asset, index, _ in
            print("Sending assets: \(asset.localIdentifier)")
            assetSubject.send(asset)
        }
        
        print("Done with assets")
        assetSubject.send(completion: .finished)
    }
    private var authorizationStatusPublisher: AnyPublisher<PHAuthorizationStatus, Never> = {
        Deferred {
            Future { promise in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    promise(.success(status))
                }
            }
        }
        .eraseToAnyPublisher()
    }()
    
    @IBAction func loadPhotosTapped(_ sender: Any) {
        loadPhototCancellable = authorizationStatusPublisher
            .drop(while: { $0 != .authorized })
            .sink { [weak self] _ in
                self?.fetchPhotos()
            }
    }
    
    
    
    private func imagePublisher(for asset: PHAsset, targetSize: CGSize, contentMode: PHImageContentMode) -> AnyPublisher<UIImage?, Never> {
        let requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        requestOptions.deliveryMode = .fastFormat
        requestOptions.resizeMode = .exact
        
        return Future { promise in
            PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: contentMode, options: requestOptions) { image, info in
                promise(.success(image))
            }
        }
        .eraseToAnyPublisher()
    }
}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
