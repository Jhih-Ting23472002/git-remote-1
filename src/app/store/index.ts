import { ActionReducer, ActionReducerMap, MetaReducer } from '@ngrx/store';
import { environment } from '../../environments/environment';

// Global App State Interface
export interface AppState {
  // Feature states will be added here as they are implemented
}

// Root reducers map - features will be added as they are implemented
export const reducers: ActionReducerMap<AppState> = {
  // Feature reducers will be registered here
};

// Logger meta-reducer for development
export function logger(reducer: ActionReducer<any>): ActionReducer<any> {
  return (state, action) => {
    console.log('state', state);
    console.log('action', action);
    return reducer(state, action);
  };
}

// Meta-reducers configuration
export const metaReducers: MetaReducer<AppState>[] = !environment.production ? [logger] : [];