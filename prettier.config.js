/* eslint-disable @typescript-eslint/no-var-requires */
const base = require('@renoirb/conventions-use-prettier')

/**
 * Shareable Prettier configuration
 *
 * https://prettier.io/docs/en/options.html
 * http://json.schemastore.org/prettierrc
 * Match with .gitattributes AND .editorconfig
 * https://prettier.io/docs/en/configuration.html#sharing-configurations
 *
 * @type {import('prettier').Config}
 */
module.exports = {
  ...base,
  endOfLine: 'lf',
  printWidth: 80,
  semi: false,
  singleQuote: true,
  tabWidth: 2,
  trailingComma: 'all',
  useTabs: false,
  overrides: [
    {
      files: '*.md',
      options: {
        proseWrap: 'always',
        printWidth: 120,
      },
    },
  ],
}
