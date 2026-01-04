module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2018,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": "off", // Désactiver
    "indent": "off", // Désactiver
    "max-len": "off", // Désactiver
    "object-curly-spacing": "off", // Désactiver
    "comma-dangle": "off", // Désactiver
    "no-trailing-spaces": "off", // Désactiver
    "padded-blocks": "off", // Désactiver
    "valid-jsdoc": "off", // Désactiver
    "eol-last": "off", // Désactiver
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};