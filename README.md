### FE flutter

```sh
$ cd mobile

- 最新バージョンを確認
$ fvm release

$ fvm install 3.38.7
$ fvm use 3.38.7

- 依存関係の更新
$ fvm flutter pub outdated
$ fvm flutter pub upgrade

### Android
- スマホとPCを同じWifiにつなげる
- 開発者モード -> ワイヤレスデバッグ -> ペア設定コード を確認して、「IPアドレスとポート」をhogehogeの部分に入力
- 下記を入力後、表示されているペア設定コードを入力
$ adb pair hogehoge

- ワイヤレスデバッグのIPアドレスとポートに記載の部分をfugafugaの部分に入力
$ adb connect fugafuga

- 下記を実行してコードを取得
$ DEVICE_ID=$(adb devices | awk 'NR>1 && $2=="device"{print $1; exit}')

- 実機スマホで立ち上げ
- .envrc の IP_ADDRESS に、`ifconfig | grep "inet "` を入力してわかった自分の IPアドレスを入力すること
$ fvm flutter run -d $DEVICE_ID --dart-define=API_URL=$API_URL

# fvm の Java の version をインストール済みのものと合わせる
$ fvm flutter config --jdk-dir=/opt/homebrew/Cellar/openjdk@21/21.0.9/libexec/openjdk.jdk/Contents/Home

### iOS
- 初回、Xcodeで「ワイヤレスデバッグ」設定
  - iOSは adb pair / adb connect は使わず、Xcode側でペアリング/ネットワーク接続します。
  - 初回はUSBでiPhoneをMacに接続して「このコンピュータを信頼」を許可
  - Xcode → Window > Devices and Simulators を開く
  - 左で対象iPhoneを選び、必要なら Pair（ペアリング） を押して、iPhone側に出るコードを入力
  - 詳細の “Connect via network”（ネットワーク経由で接続）にチェック → 左の端末にネットワークアイコンが出ればOK
  - USBを抜いても接続が維持される

- iPhone でデベロッパーの証明書を信頼する
  - 設定 >「一般」>「VPNとデバイス管理」（または「プロファイル」）に進み、該当するデベロッパ（通常は「Apple Development: 開発者名」）を選択して「信頼」をタップ

$ fvm flutter devices

$ fvm flutter build ios --debug
- 上記のコマンドで表示されるIDをxxx部分に指定
$ export IPHONE_DEVICE_ID=xxx
$ fvm flutter run -d $IPHONE_DEVICE_ID --no-hot --dart-define=API_URL="$API_URL"

- 参考: ログを詳細に吐き出す
$ fvm flutter run -d $IPHONE_DEVICE_ID -v --no-hot --dart-define=API_URL="$API_URL"
```

- リンター
```sh
$ fvm dart run custom_lint --fix
```

- フォーマッター
```sh
$ fvm dart format .
```

- テスト
```sh
$ fvm flutter test

# カバレッジの算定。coverage/lcov.info が出力される
$ fvm flutter test --coverage
# HTML形式のカバレッジレポートを生成
$ genhtml coverage/lcov.info -o coverage/html
# ブラウザで確認
$ open coverage/html/index.html
```

### BE Django Ninja

```sh
$ touch .envrc
$ cp .envrc.example .envrc

$ brew install direnv
- 適宜更新
$ direnv allow

- Docker 立ち上げ
```sh
# ローカル開発環境
$ docker compose down
$ docker compose build
$ docker compose up -d

# APP 追加
$ mkdir backend/api
$ docker compose exec backend uv run django-admin startapp api api
# migration
$ docker compose exec backend uv run manage.py makemigrations
# migrate
$ docker compose exec backend uv run manage.py migrate
# super user 作成
$ docker compose exec backend uv run manage.py createsuperuser --noinput || true

# コンテナ作り直しスクリプト
$ ./remake-container.sh

# フォーマッター/リンターの実行
$ docker compose exec  backend uv run ruff check . --fix
$ docker compose exec  backend uv run ruff format .

# テストの実行
$ docker compose exec backend uv run pytest

# 型チェック
$ docker compose exec backend uv run mypy .
```

http://127.0.0.1:8080/api/count_saved_images/
http://127.0.0.1:8080/admin/


### Git Rebase
```sh
$ git log --oneline
$ git rebase -i <ハッシュ値>^
$ git push --force-with-lease origin <ブランチ名>
```
