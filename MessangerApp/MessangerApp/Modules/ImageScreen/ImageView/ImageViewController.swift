//
//  ImageViewController.swift
//  MessangerApp
//
//  Created by Mikita Glavinski on 2/8/22.
//

import UIKit

class ImageViewController: UIViewController {
    
    var presenter: ImagePresenterProtocol!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backgroundView: UIView!
    
    private var superviewImageRect: CGRect!
    
    private lazy var zoomTap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(zoomingTap))
        tap.numberOfTapsRequired = 2
        return tap
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.alpha = 0
        presenter.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
        setupGestures()
    }
    
    private func setupGestures() {
        zoomTap.delegate = self
        imageView.addGestureRecognizer(zoomTap)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        panGesture.delegate = self
        imageView.addGestureRecognizer(panGesture)
    }
    
    private func zoom(point: CGPoint, animated: Bool) {
        let currectScale = scrollView.zoomScale
        let minScale = scrollView.minimumZoomScale
        let maxScale = scrollView.maximumZoomScale
        
        if minScale == maxScale && minScale > 1 {
            return
        }
        let toScale = maxScale
        let finalScale = currectScale == minScale ? toScale : minScale
        let zoomRect = zoomRect(scale: finalScale, center: point)
        scrollView.zoom(to: zoomRect, animated: animated)
    }
    
    private func zoomRect(scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        let bounds = scrollView.bounds
        
        zoomRect.size.width = bounds.size.width / scale
        zoomRect.size.height = bounds.size.height / scale
        
        zoomRect.origin.x = center.x - (zoomRect.size.width / 2)
        zoomRect.origin.y = center.y - (zoomRect.size.height / 2)
        return zoomRect
    }
    
    private func handleImagePanHide() {
        let parentRect = view.convert(imageView.frame, from: imageView.superview)
        
        let animatedImageView = UIImageView()
        animatedImageView.contentMode = .scaleAspectFit
        animatedImageView.image = imageView.image
        animatedImageView.frame = parentRect
        animatedImageView.layer.cornerRadius = 15
        animatedImageView.clipsToBounds = true
        
        view.addSubview(animatedImageView)
        navigationController?.navigationBar.alpha = 1
        self.imageView.removeFromSuperview()
        UIView.animate(withDuration: 0.2) {
            self.backgroundView.alpha = 0
            animatedImageView.frame = self.superviewImageRect
        } completion: { _ in
            self.presenter.dismissView()
        }
    }
    
    @IBAction func closeImage(_ sender: Any) {
        handleImagePanHide()
    }
    
    @objc private func zoomingTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sender.view)
        zoom(point: location, animated: true)
    }
    
    @objc private func handlePan(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        switch sender.state {
        case .changed:
            imageView.center.y += translation.y
            sender.setTranslation(.zero, in: view)
        case .ended:
            if abs(imageView.center.y - scrollView.center.y) > 100 {
                handleImagePanHide()
            } else if sender.velocity(in: view).y >= 1400 || sender.velocity(in: view).y <= -1400 {
                handleImagePanHide()
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.imageView.center = self.scrollView.center
                }
            }
        default:
            break
        }
    }
}

extension ImageViewController: ImageViewInput {
    
    func presentImage(_ image: UIImage, superviewImageRect: CGRect) {
        imageView.image = image
        self.superviewImageRect = superviewImageRect
    }
}

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    private var scrollViewVisibleSize: CGSize {
        let contentInset = scrollView.contentInset
        let scrollViewSize = scrollView.bounds.standardized.size
        let width = scrollViewSize.width - contentInset.left - contentInset.right
        let height = scrollViewSize.height - contentInset.top - contentInset.bottom
        return CGSize(width:width, height:height)
    }
    
    private var scrollViewCenter: CGPoint {
        let scrollViewSize = self.scrollViewVisibleSize
        return CGPoint(x: scrollViewSize.width / 2.0,
                       y: scrollViewSize.height / 2.0)
    }
    
    private func centerScrollViewContents() {
        
        let scrollViewSize = scrollViewVisibleSize

        var imageCenter = CGPoint(x: scrollView.contentSize.width / 2.0,
                                  y: scrollView.contentSize.height / 2.0)

        let center = scrollViewCenter

        if scrollView.contentSize.width < scrollViewSize.width {
            imageCenter.x = center.x
        }

        if scrollView.contentSize.height < scrollViewSize.height {
            imageCenter.y = center.y
        }

        imageView.center = imageCenter
    }
}

extension ImageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer == zoomTap {
            return true
        }
        if otherGestureRecognizer == scrollView.panGestureRecognizer && scrollView.zoomScale > 1.0 {
            return true
        }
        return false
    }
}
