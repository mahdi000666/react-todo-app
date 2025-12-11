<<<<<<< HEAD
import { defineConfig } from 'vitest/config';
import react from '@vitejs/plugin-react';
=======
import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
>>>>>>> main

export default defineConfig({
  plugins: [react()],
  test: {
<<<<<<< HEAD
    environment: 'jsdom',
    setupFiles: './src/test-setup.js',
  },
});
=======
    environment: "jsdom",
    globals: true
  }
});
>>>>>>> main
