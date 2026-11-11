# usefulpain

**ファイルを2つ、並べるだけ。** 左右で別々にフォルダやファイルを選べる、Mac用の小さなビューアです。

## 必要なもの

- AppleシリコンMac（M1以降）・macOS 14以降
- Xcode 15以降、またはSwift 5.9以降を含むCommand Line Tools

開発ツールがない場合は、ターミナルで `xcode-select --install` を実行してください。

## すぐ使う

ターミナルで次の4行を実行します。

```sh
git clone https://github.com/sbach0219/usefulpain.git
cd usefulpain
./scripts/build-app.sh
open dist/usefulpain.app
```

普段使う場合は、できた **dist/usefulpain.app** を「アプリケーション」フォルダへコピーしてください。

## 操作

- 各側の **フォルダ** または **ファイル** で選ぶ。Finderからのドロップでも開けます。
- **ファイル** を押すと、その側だけ差し替え。選択をキャンセルすれば今の表示を保ちます。
- ファイル名の左の **×** で閉じて一覧へ。反対側のファイルはそのままです。

PDF・画像・テキストなどをQuick Lookで表示します。対応形式はmacOSに依存します。
ファイルの編集・削除はしません。選択内容はアプリ終了時に保存しません。

## 配布について

現在はソースからビルドして使う開発版です。生成アプリはローカル用のアドホック署名で、
**Developer ID署名・Apple公証は未実施**です。未公証のダウンロード版はGatekeeperに
止められる場合があります。GatekeeperやSIPを無効にする必要はありません。

[検証結果](docs/VERIFICATION.md) · [プライバシー](SECURITY.md) · [開発・公開手順](docs/RELEASING.md)

[MIT License](LICENSE) · Copyright © 2026 Soshi Shibata
