#!/bin/bash

# デフォルトポート番号
DEFAULT_PORT=5000

# ポート番号が指定されている場合はそれを使用、指定されていない場合はデフォルトポートを使用
PORT=${1:-$DEFAULT_PORT}

# Flutter Webアプリを特定のポートで起動
echo "Starting Flutter Web on port $PORT..."
flutter run -d chrome --web-port=$PORT