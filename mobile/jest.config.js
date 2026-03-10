module.exports = {
  preset: 'jest-expo',
  setupFilesAfterEnv: ['@testing-library/jest-native/extend-expect'],
  moduleNameMapper: {
    '^expo/src/winter(.*)$': '<rootDir>/__mocks__/expo-winter.js'
  }
};
