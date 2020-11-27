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
    
    private var foodPromoItemsSource: [FoodItem] = [FoodItem]()
    private var displayFoodPromoItemsRelay: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    
    private var foodCategoriesSource: [String] = ["Pizza", "Sushi", "Drinks"]
    
    private var foodItemsSource: [FoodItem] = [FoodItem]()
    private var displayFoodItemsRelay: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    
    private var loadingImgViewTimer: Timer? = nil
    private var loadingImageAnimationFlag: Bool = false
    private var previousOffset: CGFloat = 0.0
    private var lastIndex: Int = 0
    
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
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        //.default
        .lightContent
    }
}

extension FoodMenuViewController: PresenterToViewFoodMenuProtocol {
    
    func onReceivingFoodItemsSuccessResponse(_ foodItems: [FoodItem], _ foodPromoItems: [FoodItem]) {
        
        self.foodItemsSource = foodItems
        self.foodPromoItemsSource = foodPromoItetms
        
        self.appState.accept(.loaded)
    }
    
    func onReceivingFoodItemsFailureResponse(_ error: Error) {
        // TODO:
        // as of now repsonse is mocked with delay of 5 secs.. so no error will happen !!
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
        
        if (cellToSwipe >= self.foodPromoItemsSource.count) {
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
                print("1 \(newY) \(delta)")
                self.foodPromoItemsViewYConstraint.constant = -1 * carouselHeight
                //self.foodItemsViewYConstraint.constant = -61
                return
            }else if newY < 0 {
                print("2 \(newY) \(delta)")
                self.foodPromoItemsViewYConstraint.constant = 0
                //self.foodItemsViewYConstraint.constant = 271
                return
            }else {
                //we compress the top view
                if delta > 0 {
                    print("3 \(newY) \(delta)")
                   foodPromoItemsViewYConstraint.constant -= delta
                   //foodItemsViewYConstraint.constant -= delta
                    scrollView.contentOffset.y -= delta
                }

                //we expand the top view
                if delta < 0 {
                    print("4 \(newY) \(delta)")
                   foodPromoItemsViewYConstraint.constant -= delta
                   //foodItemsViewYConstraint.constant -= delta
                    scrollView.contentOffset.y -= delta
                }
                previousOffset = scrollView.contentOffset.y
            }
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
                
                print("App State: \(app_state)")
            
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

        displayFoodPromoItemsRelay.accept(self.foodPromoItemsSource)
        
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

        Observable.just(foodPromoItemsSource.count)
            .bind(to: foodPromoItemsPageCtrl.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        foodPromoItemsPageCtrl.rx.controlEvent(.valueChanged)
            // commented, until touch event handled..
//            .subscribe(onNext: { [unowned self] in
//                self.moveToNextPromo(self.foodPromoItemsPageCtrl.currentPage + 1)
//            })
            .subscribe(onNext: { value in
                print("vvv value is \(value)")
                self.moveToNextPromo(self.foodPromoItemsPageCtrl.currentPage + 1)
                //print("valueChanged: \(self.foodPromoItemsPageCtrl.currentPage) (only log.. action to be handled..)")
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
        
        Observable.just(self.foodCategoriesSource)
            .bind(to: foodCategoriesView
                .rx
                .items(cellIdentifier: FoodCategoriesCell.Identifier,
                       cellType: FoodCategoriesCell.self)) {
                        item, category, cell in
                        cell.setValue(category)
                        cell.updateAsSelectedUI()
            }
            .disposed(by: disposeBag)
        
        foodCategoriesView
            .rx
            .itemSelected
            .subscribe(onNext:{ [unowned self] indexPath in
                //let selectedCategoryItem = self.foodCategoriesView.indexPathsForSelectedItems?.first?.item ?? 0
                
                let cell = self.foodCategoriesView.cellForItem(at: indexPath) as? FoodCategoriesCell
                cell?.updateAsSelectedUI()
                self.foodCategoriesView.scrollToItem(at: IndexPath(item: indexPath.item, section: 0), at: .centeredHorizontally, animated: true)
                
                // need to check, is already same category in display !! :)
                self.updateDisplayFoodItems(newCategory: indexPath.item,previousCategory: lastIndex)
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
        updateDisplayFoodItems(newCategory: 0)
    }
    
    private func updateDisplayFoodItems(newCategory: Int, previousCategory: Int? = nil) {
        let isLtoR : Bool = newCategory < (previousCategory ?? 0)
        var animate: Bool = false
        
        switch newCategory {
            case 0:
                displayFoodItemsRelay.accept(self.foodItemsSource.filter { $0.type == 1 })
                animate = true
            case 1:
                displayFoodItemsRelay.accept(self.foodItemsSource.filter { $0.type == 2 })
                animate = true
            case 2:
                displayFoodItemsRelay.accept(self.foodItemsSource.filter { $0.type == 3 })
                animate = true
            default:
                print("popup")
                // assumed category index within the range :)
                self.toast("\(foodCategoriesSource[newCategory]) Coming Soon..")
        }
        
        if animate {
            if let viewToAnimate = self.foodItemsView {
                // L -> R
                var l2rFrame: CGRect = viewToAnimate.frame
                print("y is \(l2rFrame.minY) \(l2rFrame.maxY)")
                l2rFrame.origin.x = viewToAnimate.frame.size.width * (isLtoR ? 1 : -1);
                
                UIView.animate(withDuration:0.4, delay:0.0, options: .curveEaseIn,
                               animations: {
                                viewToAnimate.frame = l2rFrame
                                viewToAnimate.alpha = 0.4
                            }, completion: {
                                (finished: Bool) -> Void in
                                self.foodItemsView.reloadData()
                                if self.displayFoodItemsRelay.value.count > 0 {
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
        
        //print("Selected: \(selectedCategoryItem), Next: \(nextCategoryItem), Direction: \(direction)")
        
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
            
            self.updateDisplayFoodItems(newCategory: nextCategoryItem,previousCategory: lastIndex)
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
        
        // data & add butotn tap..
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
                            print("\(foodItem.name ?? "Food Item") \(foodItem.price ?? 0.0)")
                            
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
                // self.foodCartButton.badge = "\(food_items.count)"
                self.foodCartButton.animate("\(food_items.count)")
            })
            .disposed(by: disposeBag)
    }
}
