
module.exports = {
    root: true, // if you want to prevent ESLint from searching for the configuration file all the way up to the root directory of the filesystem
    env: {
        browser: true, // for ESLint to be aware of browser global variables
        node: true, // for ESLint to be aware of Node.js global variables and scoping
        es6: true, // for ESLint to be aware of ES6 global variables (this automatically enables ES6 syntax)
    },
    parser: '@typescript-eslint/parser', // TypeScript (if not Vue)
    parserOptions: {
        parser: '@typescript-eslint/parser', // Vue + TypeScript
        ecmaFeatures: {
            jsx: true, // React, React Native
        },
        sourceType: 'module', // if you're using ECMAScript modules
    },
    extends: [
        'eslint:recommended', // always (set of rules recommended by ESLint team)
        'plugin:@typescript-eslint/recommended'
    ],
    rules: {
        "@typescript-eslint/no-explicit-any": ["error", { "fixToUnknown": false, "ignoreRestArgs": true }]
    },
    plugins: [
        '@typescript-eslint', // TypeScript
    ],
    settings: {
        react: {
            version: 'detect', // React
        }
    }
};
