const js = require("@eslint/js");

module.exports = [
  js.configs.recommended,
  {
    languageOptions: {
      globals: {
        require: "readonly",
        module: "readonly",

        describe: "readonly",
        test: "readonly",
        expect: "readonly",
      },
    },
    rules: {
      quotes: ["error", "double"],
      semi: ["error", "always"],
      "no-console": "off",
      "no-unused-vars": "warn",
    },
  },
];