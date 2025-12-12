import { render } from '@testing-library/react';
import { describe, it, beforeEach, vi } from 'vitest';
import TodoList from './TodoList';

// Mock localStorage before all tests
const localStorageMock = (() => {
  let store = {};
  return {
    getItem: (key) => store[key] || null,
    setItem: (key, value) => { store[key] = value.toString(); },
    removeItem: (key) => { delete store[key]; },
    clear: () => { store = {}; }
  };
})();

Object.defineProperty(global, 'localStorage', {
  value: localStorageMock
});

describe('TodoList', () => {
  beforeEach(() => {
    localStorageMock.clear();
  });

  it('renders without crashing', () => {
    render(<TodoList />);
  });
});