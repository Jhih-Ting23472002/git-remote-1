# Angular & NgRx 最新文件 - 協作參考

> 本文件包含從 Context7 檢索的最新 Angular 和 NgRx 官方文件，供團隊協作開發時參考。
> 
> 最後更新：2025-08-20

## 目錄

1. [Angular 最新特性與最佳實踐](#angular-最新特性與最佳實踐)
2. [NgRx 最新特性與最佳實踐](#ngrx-最新特性與最佳實踐)
3. [開發最佳實踐總結](#開發最佳實踐總結)
4. [參考連結](#參考連結)

## Angular 最新特性與最佳實踐

### 核心概念

#### 1. Standalone Components (預設)
- Angular 推薦使用 standalone components 而不是 NgModules
- **不要設置 `standalone: true`** - 這是預設值
- 使用 `input()` 和 `output()` 函數取代裝飾器

```typescript
import { Component, input, output } from '@angular/core';

@Component({
  selector: 'app-example',
  template: '<div>{{ message() }}</div>',
  changeDetection: ChangeDetectionStrategy.OnPush // 推薦設置
})
export class ExampleComponent {
  readonly message = input<string>('');
  readonly clicked = output<void>();
}
```

#### 2. Angular Signals (狀態管理)
- 使用 signals 進行狀態管理
- 使用 `computed()` 進行衍生狀態
- 避免使用 `mutate()`，改用 `update()` 或 `set()`

```typescript
import { signal, computed } from '@angular/core';

export class MyComponent {
  readonly count = signal(0);
  readonly doubleCount = computed(() => this.count() * 2);
  
  increment() {
    this.count.update(n => n + 1);
  }
}
```

#### 3. 變更檢測策略
- **必須使用 `ChangeDetectionStrategy.OnPush`**
- 有助於 Zoneless 相容性
- 改善應用程式效能

#### 4. 範本語法更新
- 使用原生控制流：`@if`、`@for`、`@switch`
- 不再使用 `*ngIf`、`*ngFor`、`*ngSwitch`
- 避免使用 `ngClass` 和 `ngStyle`，改用直接綁定

```typescript
@Component({
  template: `
    @if (isVisible()) {
      <div>內容可見</div>
    }
    
    @for (item of items(); track item.id) {
      <div>{{ item.name }}</div>
    }
  `
})
```

#### 5. 圖片最佳化
- 對於所有靜態圖片使用 `NgOptimizedImage`
- 注意：不適用於 base64 內嵌圖片

#### 6. 服務注入
- 使用 `inject()` 函數取代建構函式注入
- 使用 `providedIn: 'root'` 進行單例服務

```typescript
import { inject } from '@angular/core';

@Component({})
export class MyComponent {
  private httpClient = inject(HttpClient);
}
```

### 路由最佳實踐

#### Lazy Loading
- 對功能路由實施延遲載入
- 改善初始載入時間

#### 路由器配置函數
```typescript
import { 
  withComponentInputBinding,
  withPreloading,
  withHashLocation 
} from '@angular/router';

bootstrapApplication(AppComponent, {
  providers: [
    provideRouter(
      routes,
      withComponentInputBinding(),
      withPreloading(PreloadAllModules),
      withHashLocation()
    )
  ]
});
```

### Zone.js 和 Zoneless
- Angular 正朝向 Zoneless 架構發展
- 使用 `OnPush` 策略確保 Zoneless 相容性
- 準備遷移至信號驅動的變更檢測

## NgRx 最新特性與最佳實踐

### Signal Store (新預設)

#### 1. 基本用法
NgRx Signals 是新的本地狀態管理預設選擇：

```typescript
import { signalStore, withState, withComputed, withMethods } from '@ngrx/signals';
import { withEntities } from '@ngrx/signals/entities';

export const BooksStore = signalStore(
  withEntities<Book>(),
  withState({ isLoading: false }),
  withComputed(({ entities, isLoading }) => ({
    booksCount: computed(() => entities().length)
  })),
  withMethods((store) => ({
    setLoading(loading: boolean) {
      patchState(store, { isLoading: loading });
    }
  }))
);
```

#### 2. 實體管理
```typescript
import { withEntities, setAllEntities, addEntity } from '@ngrx/signals/entities';

export const TodosStore = signalStore(
  withEntities<Todo>(),
  withMethods((store) => ({
    addTodo(todo: Todo) {
      patchState(store, addEntity(todo));
    },
    setTodos(todos: Todo[]) {
      patchState(store, setAllEntities(todos));
    }
  }))
);
```

#### 3. 自訂功能
```typescript
// 自訂請求狀態功能
export function withRequestStatus() {
  return signalStoreFeature(
    withState<{ requestStatus: 'idle' | 'pending' | 'fulfilled' | { error: string } }>({
      requestStatus: 'idle'
    }),
    withComputed(({ requestStatus }) => ({
      isPending: computed(() => requestStatus() === 'pending'),
      isFulfilled: computed(() => requestStatus() === 'fulfilled'),
      error: computed(() => {
        const status = requestStatus();
        return typeof status === 'object' ? status.error : null;
      })
    }))
  );
}

// 狀態更新函數（支援 tree-shaking）
export function setPending() {
  return { requestStatus: 'pending' as const };
}

export function setFulfilled() {
  return { requestStatus: 'fulfilled' as const };
}
```

#### 4. 使用 withFeature 進行靈活輸入
```typescript
export function withBooksFilter(books: Signal<Book[]>) {
  return signalStoreFeature(
    withState({ query: '' }),
    withComputed(({ query }) => ({
      filteredBooks: computed(() =>
        books().filter(b => b.name.includes(query()))
      )
    })),
    withMethods((store) => ({
      setQuery(query: string) {
        patchState(store, { query });
      }
    }))
  );
}

export const BooksStore = signalStore(
  withEntities<Book>(),
  withFeature(({ entities }) => withBooksFilter(entities))
);
```

### 傳統 NgRx Store

#### 1. Feature Creators
```typescript
import { createFeature, createReducer, on } from '@ngrx/store';

export const booksFeature = createFeature({
  name: 'books',
  reducer: createReducer(
    initialState,
    on(BookActions.loadBooks, (state) => ({ ...state, loading: true })),
    on(BookActions.loadBooksSuccess, (state, { books }) => ({
      ...state,
      books,
      loading: false
    }))
  ),
  extraSelectors: ({ selectBooks, selectLoading }) => ({
    selectFilteredBooks: createSelector(
      selectBooks,
      selectQuery,
      (books, query) => books.filter(book => book.title.includes(query))
    )
  })
});
```

#### 2. Effects 最佳實踐
使用 `mapResponse` (v20+)：

```typescript
import { mapResponse } from '@ngrx/operators';

@Injectable()
export class BookEffects {
  readonly loadBooks$ = createEffect(() =>
    this.actions$.pipe(
      ofType(BookActions.loadBooks),
      exhaustMap(() =>
        this.bookService.getBooks().pipe(
          mapResponse({
            next: (books) => BookActions.loadBooksSuccess({ books }),
            error: (error) => BookActions.loadBooksFailure({ error })
          })
        )
      )
    )
  );
}
```

### ESLint 規則

重要的 NgRx ESLint 規則：

- `@ngrx/prefer-action-creator` - 偏好使用 action creator
- `@ngrx/no-store-subscription` - 使用 async pipe 而非 store 訂閱
- `@ngrx/prefer-concat-latest-from` - 使用 `concatLatestFrom` 而非 `withLatestFrom`
- `@ngrx/good-action-hygiene` - 確保良好的 action 衛生
- `@ngrx/no-multiple-global-stores` - 只能有一個全域 store

## 開發最佳實踐總結

### Angular 開發
1. **使用 Standalone Components** - 預設架構
2. **採用 OnPush 策略** - 必要的變更檢測最佳化
3. **使用 Signals** - 現代反應式狀態管理
4. **原生控制流** - `@if`、`@for` 等
5. **inject() 函數** - 取代建構函式注入
6. **NgOptimizedImage** - 所有靜態圖片
7. **Lazy Loading** - 功能路由延遲載入

### NgRx 開發
1. **NgRx Signals 優先** - 新專案的預設選擇
2. **Signal Store** - 本地狀態管理
3. **自訂功能模組化** - 可重用的 store 功能
4. **Tree-shakable 更新函數** - 獨立的狀態更新函數
5. **Entity 管理** - 使用 `withEntities`
6. **Feature Creators** - 傳統 store 的最佳實踐
7. **遵循 ESLint 規則** - 確保程式碼品質

### TypeScript 最佳實踐
1. **嚴格型別檢查** - 啟用所有嚴格模式
2. **型別推斷** - 讓 TypeScript 推斷明顯的型別
3. **避免 any** - 使用 `unknown` 處理不確定的型別
4. **通用型別** - 自訂功能使用泛型以提高靈活性

## 參考連結

### 官方文件
- [Angular 官方文件](https://angular.dev)
- [NgRx 官方文件](https://ngrx.io)
- [Angular Signals 指南](https://angular.dev/guide/signals)
- [NgRx Signals 指南](https://ngrx.io/guide/signals)

### 重要更新
- Angular v20+ 新特性
- NgRx v20+ mapResponse 操作符
- Signal Store 和自訂功能
- Zoneless 變更檢測準備

---

*本文件基於 Context7 在 2025-08-20 檢索的最新官方文件編制，定期更新以保持資訊的準確性。*