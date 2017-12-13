
const path = require('path')
const webpack = require('webpack')

module.exports = {

  target: 'node',
  stats: { warnings: false },

  entry: {
    geth: './js/index.js',
  },

  output: {
    path: path.join(__dirname, 'build'),
    filename: '[name].bundle.js',
  },

  resolve: {
    extensions: ['.js', '.json'],
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        use: ['babel-loader'],
        exclude: /node_modules/,
      }
    ],
  },

}

