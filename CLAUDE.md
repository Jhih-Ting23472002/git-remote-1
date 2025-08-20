Angular 20+ 團隊開發技術規格

1. 開發哲學與核心原則
   本節定義了我們團隊在開發過程中共同遵守的核心信念與設計原則，旨在確保程式碼品質、團隊協作效率與專案的長期健康。
   1.1. 核心信念
   清晰優於聰明 (Clear intent over clever code): 程式碼首先是寫給人看的，其次才是給機器執行的。應優先選擇直觀、易於理解的寫法，而非晦澀難懂的技巧。
   增量優於重構 (Incremental progress over big bangs): 透過小步、可驗證的提交來推進專案，避免一次性進行大規模、高風險的重構。
   務實優於教條 (Pragmatic over dogmatic): 雖然我們遵循最佳實踐，但也應根據專案的實際情況靈活應對，選擇最合適的解決方案。
   學習優於臆測 (Learning from existing code): 在實作新功能前，花時間研究和理解現有程式碼的模式與架構。
   註解應用於「為何」，而非「如何」: 只在複雜的業務邏輯或演算法處提供註解，解釋其背後的原因與目的，而非逐行解釋程式碼的功能。
   1.2. 專案結構設計原則 (LIFT)
   所有結構決策均遵循 Angular 官方的 LIFT 原則：
   L (Locate - 快速定位): 結構應能讓開發者快速且直觀地找到程式碼。
   I (Identify - 快速識別): 檔案或目錄的用途應一目了然。
   F (Flat - 保持扁平): 盡可能保持目錄結構的扁平化，避免過度嵌套。
   T (Try to be DRY - 避免重複): 遵守 "Don't Repeat Yourself" 原則，但不可為此犧牲程式碼的可讀性。
2. UI/UX 開發指南
   畫面佈局與樣式: 專案全面採用 TailwindCSS 進行畫面切版與樣式設計，以實現快速、一致的 UI 開發。
   共用元件建立原則:
   優先使用 Angular Material: 在需要建立共用 UI 元件（如按鈕、對話框、表單控制項）時，應優先尋找並使用 Angular Material 官方提供的元件。
   必要時自訂開發: 如果 Angular Material 無法滿足特定的設計或功能需求，才考慮使用原生 Angular 方式建立自訂元件，並將其放置於 src/app/shared/components 目錄下。
3. 專案結構與 NgRx 實踐
   3.1. 概述
   本專案採用「按功能 (By Feature)」的組織方式，並深度整合 NgRx 進行狀態管理。旨在建立一個可預測、可擴展且高度可維護的架構，同時保持業務邏輯與 UI 元件的清晰分離。
   3.2. 整合 NgRx 後的目錄結構
   my-angular-app/
   ├── src/
   │ ├── app/
   │ │ ├── core/ # 核心功能 (單例服務、攔截器、守衛)
   │ │ ├── features/ # 業務功能模組
   │ │ │ └── products/ # 範例：產品功能
   │ │ │ ├── components/ # 此功能專用的 UI 元件
   │ │ │ ├── pages/ # 作為路由目標的頁面元件
   │ │ │ ├── services/ # API 服務 (e.g., products-api.service.ts)
   │ │ │ ├── models/ # 資料模型
   │ │ │ ├── state/ # NgRx 狀態管理
   │ │ │ │ ├── products.actions.ts
   │ │ │ │ ├── products.reducer.ts
   │ │ │ │ ├── products.effects.ts
   │ │ │ │ └── products.selectors.ts
   │ │ │ ├── products.facade.ts # Facade 服務
   │ │ │ └── products.routes.ts # 路由
   │ │ ├── shared/ # 共享、可重用的 UI 元件、指令、管道
   │ │ ├── layout/ # 應用程式佈局 (Header, Footer, Sidebar)
   │ │ ├── store/ # 全域 Store 設定 (Meta Reducers, Router Store)
   │ │ ├── app.component.ts
   │ │ ├── app.config.ts # 應用程式設定
   │ │ └── app.routes.ts # 主要路由設定
   │ ├── assets/
   │ └── ...
   3.3. NgRx 相關目錄詳解
   src/app/store (Root Store): 存放應用程式級別的 NgRx 設定，如 Meta Reducers (logger) 和 Router Store 的設定。
   features/[feature-name]/state (Feature State): 封裝特定功能模組的所有 NgRx 邏輯，包含 Actions, Reducer, Effects, Selectors。這是實踐狀態模組化的核心。
   features/[feature-name]/[feature-name].facade.ts (Facade 模式):
   用途: 建立一個抽象層，作為元件與 NgRx Store 之間的唯一溝通管道。
   職責: 向元件提供簡潔的 API (可觀察的資料流 $ 和指令型方法)，隱藏所有 store.dispatch 和 store.select 的實作細節。
   優點: 大幅簡化元件邏輯，提高可測試性，並將狀態管理的複雜性集中化。
   3.4. 元件與狀態的互動流程 (Facade 模式)
   觸發: 使用者在元件中執行操作。
   呼叫 Facade: 元件呼叫 Facade 的方法 (e.g., this.productsFacade.loadProducts())。
   分派 Action: Facade 向 Store 分派一個 Action。
   處理副作用: Effect 監聽此 Action，呼叫 API 服務，並在完成後分派成功或失敗的 Action。
   更新狀態: Reducer 監聽 Action 並更新 Store 中的狀態。
   資料流向元件: Selector 計算出新的衍生狀態。元件透過訂閱 Facade 提供的 Observable (this.productsFacade.allProducts$) 自動接收更新，並渲染畫面。
4. 開發流程指南
   卡關處理流程 (三次嘗試原則)
   關鍵原則: 針對同一個問題，最多進行 3 次獨立嘗試。若仍無法解決，必須停止並啟動以下流程，以避免時間浪費並尋求更有效的解決方案。
   停止並記錄 (Stop & Document): 停止當前的嘗試。清晰地記錄你已經嘗試過的方法以及它們失敗的原因。
   研究替代方案 (Research Alternatives): 跳出原有的思路，主動研究是否有其他可能的解決路徑或工具。
   質疑根本問題 (Question Fundamentals): 退一步思考，是不是對問題本身的理解有偏差？或是底層的假設是錯誤的？
   尋求協助 (Ask for Help): 帶著你記錄的失敗嘗試和研究結果，向團隊成員或主管尋求協助或進行結對程式設計 (Pair Programming)。
