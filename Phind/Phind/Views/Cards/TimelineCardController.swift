//
//  TimelineCardController.swift
//  Phind
//
//  Created by Kevin Chang on 2/27/19.
//  Copyright © 2019 Team-7. All rights reserved.
//

import Foundation
import CardParts
import RxSwift

class TimelineCardController: CardPartsViewController  {
  
  var viewModel = TestViewModel()
  var titlePart = CardPartTitleView(type: .titleOnly)
  var textPart = CardPartTextView(type: .normal)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    viewModel.title.asObservable().bind(to: titlePart.rx.title).disposed(by: bag)
    viewModel.text.asObservable().bind(to: textPart.rx.text).disposed(by: bag)
    
    setupCardParts([titlePart, textPart])
  }
}

class TestViewModel {
  
  var title = Variable("")
  var text = Variable("")
  
  init() {
    
    // When these values change, the UI in the TestCardController
    // will automatically update
    title.value = "Hello, world!"
    text.value = "CardParts is awesome!"
  }
}
