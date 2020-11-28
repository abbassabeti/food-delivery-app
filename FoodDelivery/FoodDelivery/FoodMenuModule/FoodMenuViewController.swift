//
//  FoodMenuViewController.swift
//  FoodDelivery
//
//  Created by Abbas on 11/26/20.
//
//

import UIKit
import RxSwift
import RxCocoa
import Moya
import ObjectMapper

enum DDAppState {
  case loading
  case loaded
}

class FoodMenuViewController: UIViewController, UICollectionViewDelegate, UITableViewDelegate {
    
    let carouselHeight = UIScreen.main.bounds.height * 0.7 + 61
    
    // MARK: - Outlets
    @IBOutlet weak private var foodPromoItemsView: UICollectionView!
    @IBOutlet weak private var foodPromoItemsViewYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak private var foodCartButton: BadgeButton!
    
    @IBOutlet weak private var foodPromoItemsPageCtrl: FDPageControl!
    
    @IBOutlet weak private var foodCategoriesView: UICollectionView!
    
    @IBOutlet weak private var foodItemsView: UITableView!
    @IBOutlet weak private var foodItemsViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Properties
    var foodMenuPresenter: ViewToPresenterFoodMenuProtocol?
    
    private let disposeBag = DisposeBag()
    private var appState: BehaviorRelay<DDAppState> = BehaviorRelay(value: .loading)
    
    private var loadingImgViewTimer: Timer? = nil
    private var loadingImageAnimationFlag: Bool = false
    private var previousOffset: CGFloat = 0.0
    private var needsWhiteStatus: Bool = true
    private var lastIndex: Int = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return needsWhiteStatus ? .lightContent : .darkContent
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        initAppState()
        startLoading()
        foodMenuPresenter?.startReceivingFoodItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}

extension FoodMenuViewController: PresenterToViewFoodMenuProtocol {
    
    func showToast(_ message: String) {
        self.toast(message)
    }
    
    func onNewCategorySelected(isLtoR: Bool){
        guard let displayFoodItems = self.foodMenuPresenter?.viewModel.displayFoodItemsRelay.value else {return}
        if let viewToAnimate = self.foodItemsView {
            // L -> R
            var l2rFrame: CGRect = viewToAnimate.frame

            l2rFrame.origin.x = viewToAnimate.frame.size.width * (isLtoR ? 1 : -1);
            
            UIView.animate(withDuration:0.4, delay:0.0, options: .curveEaseIn,
                           animations: {
                            viewToAnimate.frame = l2rFrame
                            viewToAnimate.alpha = 0.4
                        }, completion: {
                            (finished: Bool) -> Void in
                            self.foodItemsView.reloadData()
                            if displayFoodItems.count > 0 {
                                self.foodItemsView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                            }
                            
                            // R <- L
                            var r2lFrame: CGRect = viewToAnimate.frame;
                            viewToAnimate.frame.origin.x = viewToAnimate.frame.size.width * (isLtoR ? -1 : 1)
                            r2lFrame.origin.x = 0;
                            
                            UIView.animate(withDuration:0.7, delay:0.0, options: .curveEaseOut,
                               animations: {
                                viewToAnimate.frame = r2lFrame
                                viewToAnimate.alpha = 1
                            }, completion: {
                                (finished: Bool) -> Void in
                            });
                        });
            
            
        }
    }
    
    func onReceivingFoodItemsSuccessResponse() {
        
       
        
        self.appState.accept(.loaded)
    }
    
    func onReceivingFoodItemsFailureResponse(_ error: Error) {
        // TODO:
        // as of now repsonse is mocked with delay of 2 secs.. so no error will happen !!
        print(error)
    }
}

extension FoodMenuViewController {
    func initFoodMenuView() {
        self.foodPromoItemsView.superview?.isHidden = false
        self.foodItemsView.superview?.isHidden = false
        self.foodCartButton.isHidden = false
        
        self.view.bringSubviewToFront(self.foodItemsView)
        
        initFoodPromoItemsView()
        initFoodPromoItemsPageCtrl()
        
        initFoodItemsView()
        initFoodCategoriesView()
        
        initFoodCartButton()
    }
    
    @IBAction func onFoodCartAction(_ sender: BadgeButton) {
        let foodCartViewController: FoodCartViewController = FoodCartRouter.createFoodCartModule()
        foodCartViewController.modalPresentationStyle = .fullScreen

        self.present(foodCartViewController, animated: true, completion: nil)
    }
    
    private func moveToNextPromo(_ nextPage: Int) {
        var cellToSwipe: Int = nextPage
        guard let foodPromoItemsSource = self.foodMenuPresenter?.viewModel.foodPromoItemsSource else {return}
        
        if (cellToSwipe >= foodPromoItemsSource.count) {
            cellToSwipe = 0
        }
            
        DispatchQueue.main.async {
            guard let rect = self.foodPromoItemsView.layoutAttributesForItem(at: IndexPath(row: cellToSwipe, section: 0))?.frame else {return}
            self.foodPromoItemsView.scrollRectToVisible(rect, animated: true)
        }
        
        self.foodPromoItemsPageCtrl.currentPage = cellToSwipe
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee = scrollView.contentOffset // set acceleration to 0.0

        let pageWidth: CGFloat = self.foodPromoItemsView.bounds.size.width;
        let minSpace: CGFloat = 0

        // cell width + min spacing for lines
        let cellToSwipe: Int = Int((self.foodPromoItemsView.contentOffset.x)/(pageWidth + minSpace) + 0.5)
        
        moveToNextPromo(cellToSwipe)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView == foodItemsView {

             let delta =  scrollView.contentOffset.y - previousOffset
            
            let newY: CGFloat = -self.foodPromoItemsViewYConstraint.constant + delta
            
            if newY >= carouselHeight {
                self.foodPromoItemsViewYConstraint.constant = -1 * carouselHeight
                needsWhiteStatus = false
            }else if newY < 0 {
                self.foodPromoItemsViewYConstraint.constant = 0
            }else {
                // Make status dark when there is a 180 point distance to the top
                needsWhiteStatus = (carouselHeight + foodPromoItemsViewYConstraint.constant > 180)
                //we compress the top view
                if delta > 0 {
                   foodPromoItemsViewYConstraint.constant -= delta
                    scrollView.contentOffset.y -= delta
                }

                //we expand the top view
                if delta < 0 {
                   foodPromoItemsViewYConstraint.constant -= delta
                    scrollView.contentOffset.y -= delta
                }
                previousOffset = scrollView.contentOffset.y
            }
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
}

// Loading Stuffs
extension FoodMenuViewController {
    
    func startLoading() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
    }
    
    func stopLoading() {
        activityIndicator.stopAnimating()

    }
}

// Rx Stuffs
extension FoodMenuViewController {
    func initAppState() {
        appState.asObservable()
            .subscribe(onNext: {
                [unowned self] app_state in
                            
                if app_state == .loaded {
                    self.stopLoading()
                    self.initFoodMenuView()
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func scrollAuto() {
        moveToNextPromo(self.foodPromoItemsPageCtrl.currentPage + 1)
    }
    
    func initFoodPromoItemsView() {
        foodPromoItemsView.delegate = self
        foodPromoItemsView.isPagingEnabled = true
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.7)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        foodPromoItemsView.setCollectionViewLayout(flowLayout, animated: true)
        
        guard let displayFoodPromoItemsRelay = self.foodMenuPresenter?.viewModel.displayFoodPromoItemsRelay else {return}
        
        displayFoodPromoItemsRelay
            .bind(to: foodPromoItemsView
                .rx
                .items(cellIdentifier: FoodPromoItemsCell.Identifier,
                       cellType: FoodPromoItemsCell.self)) {
                        row, foodItem, cell in
                        cell.setValues(foodItem)

            }
            .disposed(by: disposeBag)
        
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(scrollAuto), userInfo: nil, repeats: true)
    }
    
    func initFoodPromoItemsPageCtrl() {
        foodPromoItemsPageCtrl.layer.cornerRadius = 10
        foodPromoItemsPageCtrl.layer.masksToBounds = true
        
        foodPromoItemsPageCtrl.currentPageIndicatorTintColor = .white
        foodPromoItemsPageCtrl.pageIndicatorTintColor = .white

        self.foodMenuPresenter?.viewModel.displayFoodPromoItemsRelay.map({$0.count}).asObservable().bind(to: foodPromoItemsPageCtrl.rx.numberOfPages).disposed(by: disposeBag)
        
        foodPromoItemsPageCtrl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { value in
                self.moveToNextPromo(self.foodPromoItemsPageCtrl.currentPage + 1)
                
            })
            .disposed(by: disposeBag)
    }
    
    func initFoodCategoriesView() {
        foodCategoriesView.allowsMultipleSelection = false
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width / 3 - 20, height: 35)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        foodCategoriesView.collectionViewLayout = flowLayout
        
        if let categories = self.foodMenuPresenter?.viewModel.foodCategoriesSource {
            Observable.just(categories)
            .bind(to: foodCategoriesView
                .rx
                .items(cellIdentifier: FoodCategoriesCell.Identifier,
                       cellType: FoodCategoriesCell.self)) {
                        item, category, cell in
                        cell.setValue(category)
                        cell.updateAsSelectedUI()
            }
            .disposed(by: disposeBag)
        }
        
        foodCategoriesView
            .rx
            .itemSelected
            .subscribe(onNext:{ [unowned self] indexPath in
                
                let cell = self.foodCategoriesView.cellForItem(at: indexPath) as? FoodCategoriesCell
                cell?.updateAsSelectedUI()
                self.foodCategoriesView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
                
                // need to check, is already same category in display !! :)
                self.foodMenuPresenter?.updateDisplayFoodItems(newCategory: indexPath.item,previousCategory: lastIndex)
                self.lastIndex = indexPath.item
            })
            .disposed(by: disposeBag)
        
        foodCategoriesView
            .rx
            .itemDeselected
            .subscribe(onNext:{ [unowned self] indexpath in
                let cell = self.foodCategoriesView.cellForItem(at: indexpath) as? FoodCategoriesCell
                cell?.updateAsSelectedUI()
            })
            .disposed(by: disposeBag)
        
        foodCategoriesView.selectItem(at: IndexPath(item: 0, section: 0), animated: true, scrollPosition: .centeredHorizontally)
        self.foodMenuPresenter?.updateDisplayFoodItems(newCategory: 0,previousCategory: nil)
    }
    
    private func moveToNextFoodCategory(_ direction: UISwipeGestureRecognizer.Direction) {
        let totalItem = self.foodCategoriesView.numberOfItems(inSection: 0)
        
        let selectedCategoryItem = self.foodCategoriesView.indexPathsForSelectedItems?.first?.item ?? 0
        
        var nextCategoryItem = selectedCategoryItem
        
        if direction == .right {
            nextCategoryItem -= 1
            
            if nextCategoryItem <= 0 {
                nextCategoryItem = 0
            }
        }
        else if direction == .left {
            nextCategoryItem += 1
            
            if nextCategoryItem >= totalItem {
                nextCategoryItem = selectedCategoryItem
            }
        }
        
        if nextCategoryItem != selectedCategoryItem {
            // deselect current
            let currIndexPath = IndexPath(item: selectedCategoryItem, section: 0)
            
            let currCell = self.foodCategoriesView.cellForItem(at: currIndexPath) as? FoodCategoriesCell
            currCell?.isSelected = false
            currCell?.updateAsSelectedUI()
            
            self.foodCategoriesView.deselectItem(at: currIndexPath, animated: true)
            
            // select next
            let nextIndexPath = IndexPath(item: nextCategoryItem, section: 0)
            
            let nextCell = self.foodCategoriesView.cellForItem(at: nextIndexPath) as? FoodCategoriesCell
            nextCell?.isSelected = true
            nextCell?.updateAsSelectedUI()
            
            self.foodCategoriesView.selectItem(at: nextIndexPath, animated: true, scrollPosition: .centeredHorizontally)
            
            self.foodMenuPresenter?.updateDisplayFoodItems(newCategory: nextCategoryItem,previousCategory: lastIndex)
            lastIndex = nextCategoryItem
        }
    }
    
    func initFoodItemsView() {
        foodItemsView.delegate = self
        foodItemsView.separatorColor = .clear
        foodItemsView.showsVerticalScrollIndicator = false
        
        let roundCornerView = foodItemsView.superview!
        
        roundCornerView.layer.cornerRadius = 40
        roundCornerView.layer.masksToBounds = true
        roundCornerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        // hortizontal (left, right) swipe guestures..
        let rightSwipeGesture = UISwipeGestureRecognizer()
        rightSwipeGesture.direction = .right
        foodItemsView.addGestureRecognizer(rightSwipeGesture)
        
        rightSwipeGesture.rx.event.bind(onNext: { recognizer in
            if recognizer.state != .ended {
                return
            }
            self.moveToNextFoodCategory(recognizer.direction)
            
        }).disposed(by: disposeBag)
        

        let leftSwipeGesture = UISwipeGestureRecognizer()
        leftSwipeGesture.direction = .left
        foodItemsView.addGestureRecognizer(leftSwipeGesture)
        
        leftSwipeGesture.rx.event.bind(onNext: { recognizer in
            if recognizer.state != .ended {
                return
            }
            self.moveToNextFoodCategory(recognizer.direction)
            
        }).disposed(by: disposeBag)
        
        // data & add button tap..
        guard let displayFoodItemsRelay = self.foodMenuPresenter?.viewModel.displayFoodItemsRelay else {return}
        displayFoodItemsRelay
            .bind(to: foodItemsView
                .rx
                .items(cellIdentifier: FoodItemsCell.Identifier,
                       cellType: FoodItemsCell.self)) {
                        row, foodItem, cell in
                        cell.setValues(foodItem)
                        
                        cell.foodAddButton
                        .rx.tap
                        .subscribe(onNext: {
                            // Fade out
                            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                                    FoodCart.sharedCart.add(foodItem)
                                
                                    cell.foodAddButton.backgroundColor = .systemGreen
                                    cell.foodAddButton.setTitle("added +1", for: .normal)
                                }, completion: {
                                    (finished: Bool) -> Void in
                                    
                                    // Fade in
                                    UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
                                        }, completion: {
                                            (finished: Bool) -> Void in
                                            cell.foodAddButton.backgroundColor = .black
                                            cell.foodAddButton.setTitle("\(foodItem.price ?? 0.0) usd", for: .normal)
                                })
                            })
                        }
                        ).disposed(by: cell.disposeBagOfCell)
                    }
                    .disposed(by: disposeBag)
    }
    
    func initFoodCartButton() {
        FoodCart.sharedCart.foodItems
            .asObservable()
            .subscribe(onNext: {
              [unowned self] food_items in
                self.foodCartButton.animate("\(food_items.count)")
            })
            .disposed(by: disposeBag)
    }
}
