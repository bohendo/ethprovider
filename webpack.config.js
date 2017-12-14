
const path = require('path')
const webpack = require('webpack')

module.exports = {

  externals: ['eth'],

  entry: './js/cryptokitties.js',

  output: {
    path: path.join(__dirname, 'build'),
    filename: 'ck.bundle.js',
    library: 'ck',
    libraryTarget: 'assign',
  },

  resolve: {
    extensions: ['.js', '.json'],
  },

  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          loader: 'babel-loader',
          options: { presets: ['es2015'], },
        },
      },
    ],
  },

}

