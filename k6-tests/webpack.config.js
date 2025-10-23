const path = require('path');

module.exports = {
  mode: 'production',
  entry: {
    'auth-signup': './src/services/auth/test-signup.ts',
    'auth-login': './src/services/auth/test-login.ts',
    'auth-refresh': './src/services/auth/test-refresh-token.ts',
    'auth-partner': './src/services/auth/test-partner-create.ts',
    'user-profile': './src/services/user/test-profile.ts',
    'user-update': './src/services/user/test-update.ts',
    'post-create': './src/services/post/test-create.ts',
    'post-list': './src/services/post/test-list.ts',
    'post-update': './src/services/post/test-update.ts',
    'post-delete': './src/services/post/test-delete.ts',
    'dufs-upload': './src/services/dufs/test-upload.ts',
    'dufs-download': './src/services/dufs/test-download.ts',
    'dufs-delete': './src/services/dufs/test-delete.ts',
    'flow-auth': './src/flows/auth-flow.ts',
    'flow-post': './src/flows/post-flow.ts',
    'flow-dufs': './src/flows/dufs-flow.ts',
    'flow-partner': './src/flows/partner-verify-flow.ts',
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    libraryTarget: 'commonjs',
    filename: '[name].js',
  },
  resolve: {
    extensions: ['.ts', '.js'],
  },
  module: {
    rules: [
      {
        test: /\.ts$/,
        use: 'ts-loader',
        exclude: /node_modules/,
      },
    ],
  },
  target: 'web',
  externals: /^(k6|https?\:\/\/)(\/.*)?/,
  stats: {
    colors: true,
  },
};

