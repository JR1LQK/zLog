Readme.txt

この資料は NkPrinter のマニュアルです。

1. 概要

TNkPrinter は Delphi の TPrinter の改良版です。
現在以下のことが出来ます。

 (1) プリンターの一覧の取得
 (2) プリンターの切り替え
 (3) プリンターのサポート機能の取得
 (4) 紙関係の情報取得
     紙の大きさ、印刷可能領域の大きさ、余白、解像度(dpi)
 (5) 紙サイズの一覧の取得
 (6) 紙サイズの取得/設定(ユーザ定義サイズの設定も含む)
 (7) ビン名の一覧の取得
 (8) ビンの取得／設定
 (9) 部数の取得／設定
(10) 丁合の取得／設定
(11) スケーリング倍率の取得／設定
(12) カラー／モノクロの取得／設定
(13) 両面印刷指定の取得／設定
(14) 印刷品質の一覧の取得
(15) 印刷品質の取得・設定
(16)  印刷

今後改良を加えて行く予定です。

TNkPrinter は Delphi 3.0J/3.1J/4.0J 用です。
C++Builder でも使えるかも知れませんが未試験です。

2.著作権について

とりあえずフリーソフトです。

本プログラムの不具合による損害の責任は負いません。

このプログラムの著作権は 中村 拓男 が保持します。しかし、配布／改変／利用は
完全に自由です。BBS, NetNews, Mailing List, Software Archive 等に転載も
自由です。何の制限も有りません。ただ、一言連絡していただけるとうれしいです。

3. 連絡先

ご意見、ご希望、ご感想、バグレポート等がございましたら、
Delphi World ML(delphian_world@ml.yoyo-kikaku.org) へあげて下さい。

Delphi World に参加されていない方は

nakamuri@asahi.email.ne.jp

までご連絡をお願いします。

4. 改訂履歴

1998.3.30  0.1  版      初版
1998.3.31  0.11 版
   (1) BinNames で2番目以降のビン名がおかしくなるバグを修正
   (2) メモリリークを1件修正
   (3) PaperExtent Property の書き込み(ユーザ定義サイズ)が 0.1mm 単位に
       なってしまっているバグを修正。Pixel 単位とする。
1998.3.31  0.12 版
   (1) DevMode 構造体の変更を DocumentProperties を介して行うように変更
1998.4.2   0.2  版
   (1) プリンタのパラメータを一つ変えると他のパラメータがリセットされて
       しまうというおおぼけバグを修正。
   (2) Copies, MaxCopies, Collate property を追加
   (3) MaxPaperExtebt, MinPaperExtent Property を追加
   (4) プリンタの追加削除に対応。OnSystemChanged イベントを追加
1998.4.4  0.21 版
   (1) Port が変更されても Indexがずれないようにした。
       このためソースを大幅修正！！ これで Port 変更機能の準備完了。
   (2) Demo の修正。Copies/Collate が機能していなかった。
   (3) 例外の定義がすべて Exception と同等になっていたので、継承に
       なるように修正(^^。
1998.4.5  0.3 版
   (1) Color, Duplex, Scale, ColorBitCount を追加。
   (2) Portnames. Port を追加
1998.4.7 0.31 版
   (1) プリンタのサポートがいいかげんであるため
       やもうえず MaxPaperExtent/MinPaperExtent property を削除
   (2) delphi-cw 99 で東大 武内氏からご報告の有った Collate の
       バグを修正(Orientation を取得／設定していた(^^;)
   (3) delphi-cw 99 で東大 武内氏からご報告の有った MD-1300 での不具合
       に対応。紙情報／ビン情報の更新をビンと紙関係の Propety を
       アクセスするたびに行うように修正。

1998.4.9 0.32 版
   (1) Ver 0.31 の (3) の対処でデモプログラムが異様に遅くなること判明。
       紙名、ビン名一覧の取得で DocumentProperties が遅いことが判明。
       TNkPrintDialog, TNkPrinterSetupDialog を導入することに決めた。

1998.4.18 0.4版
   (1) 印刷品質用の Property を追加
       Quality, Qualities NumQuality Property
   (2) HasPaperSizeNumber, HasBinNumber メソッドを追加
   (3) BinNumber Property の追加
   (4) PaperSize Property を PaperSizeNumber Property に改名
   (5) NumPaperSizes, NumBins Property を追加
   (6) PaperNumbers, BinNumbers Property を追加

1998.4.19 0.41 版
   (1) PaperExtent Property でユーザ定義紙サイズを設定するとき Scale(印刷倍率)
       を考慮していなかった点を修正。
   (2) MMPageExtent(0.1mm 単位の印刷可能領域の大きさ) Property を追加
   (3) 印刷倍率 がサポートされていない場合 Scale の読み出しでは 100% が
       返るように変更。
1998.4.27 0.42 版
   (1) MMPaperExtent Property を新設。ユーザ定義紙サイズを 0.1 mm 単位で
       設定できるようにした。
   (2) NkPrinter の IC or DC を表わす Handle Property を追加
   (3) 印刷中を表わす、Printing Property を追加
1998.4.29 0.43 版    β一版
   (1) Port 追加／削除に対応
   (2) ポート一覧に同じポート名が複数出てくるのに対処(対症療法)
1998.6.1 0.44 版
   (1) ヘルプを作成
   (2) 若干バグを修正
1998.6.6 0.45 版
   (1)プリンタが紙サイズ情報、ビン情報、印刷品質情報、最大部数を 
      DeviceCapabilitites で提供しない場合が有ることに対応した。
1998.6.8 0.46 版
   (1)ヘルプを修正
1998.9.13 0.5 版
   互換性の無い仕様変更を行いました！！ すいません！！
   (1) ApplySettings/DiscardModification メソッド Modified プロパティを追加。
       プリンタ設定の変更をダイレクトにプリンタに設定せず、ApplySettings
       メソッドで一括設定することにした。
   (2) MMPaperExtent/PaperExtent を読み取り専用に変更。ユーザ定義紙サイズの
       取得／変更用に UserPaperExtent を新設。



5. インストール方法

5.1 NkPrinters ユニットのインストール

NkPrinters.pas をコンポーネントとしてインストールして下さい。
すると、TNkPrintDialog, TNkPrinterSetupDialog がインストールされます。

但し、NkPrinter はコンポーネントではありません。グローバル変数です。

uses NkPrinters と指定してお使い下さい。

デモプログラムをコンパイルする前に必ずインストールして下さい。

5.2 NkPrn.hlp NkPrn.cnt のインストール

Delphi をインストールしたフォルダの Delphi 3\Help フォルダに Delphi3.cnt 
というファイルが有ります。これを編集して

:Include <NkPrinter.cnt のフルパス名>
:Link <NkPrinter.hlp のフルパス名>

を付け加えて下さい。

例：



:Base delphi3.HLP>main

;==============
:Title Delphi ヘルプ
; Index section
:Index VCL オブジェクトとコンポーネントのリファレンス =vcl3.hlp
:Index Object Pascal 言語ガイド =obpascl3.hlp
:Index Quick Report 2.0 =quickrpt.hlp

; Include section
;================
:include delphi3.cfg
:include delphi3.toc
:include vcl3.cnt
:include obpascl3.cnt
:Include win32sdk.toc
:Include winhlp32.cnt
:Include d:\test\dp3\NkPrinter\help\NkPrn.cnt
:Link d:\test\dp3\NkPrinter\help\NkPrn.hlp


6. 使い方

NkPrinter の使い方はヘルプを見て下さい。簡単なチュートリアルをつけてあります。

7. デモ

demo.dpr というプログラムが付いています。
いじり倒してください(^^
バグレポートをお待ちしています。

demo.dpr をインストールする前に必ず NkPrinters.pas をインストールしておいて
下さい。

注意：例外を多用しているので Delphi の IDE の中で実行するときは
      ツール｜環境オプション の 「設定」タグで
     「例外をデバッガで開く」のチェックを外した方がよいでしょう。

8. 現在判っている問題。

リモートプリンタが落ちている場合メモリエラーが起きるようです。
現在現象を確認中です。

9. 謝辞

NkPrinter の作成に当たり、Delphian Wold ML や Delphi-cw ML の多くの方々に
ご支援をいただきました。この場を借りて御礼申し上げます。

NG＠NCKさん
Delphian World での NG さんの発言が NkPrinter を作成するきっかけとなりました。
また、仕様に付いて多くのご助言をいただきました。

安田＠ＫＯＢＩＲＡさん
http://www.kobira.co.jp/sakura/d_print.htm をご紹介いただきました。そこに
載っていたコンポーネントの仕様は NkPrinter の参考にさせていただきました。

河村＠京大農学部さん
Excel の VBA でのプリンタ制御機能に付いて情報を提供していただきました。

Delphian World ML/Delphi-cw ML で試験を手伝っていただいた方々は下記の通りです。

NG＠NCKさん、安田＠ＫＯＢＩＲＡさん、小川  浩一、増田＠岩崎通信機(株)、
武内＠東大生研さん、松本＠エスパームさん、なかのんさん、ほそかわ＠ＮＴＴさん
河村＠京大農学部さん、有馬＠ＦＩＴＥＣさん、金澤＠応用技術さん


皆さんのおかげで様々なプリンタで NkPrinter を試験をすることが出来ました。
個人では中々出来なかったと思います。

繰り返しになりますが本当にありがとうございました。

まだ NkPrinter はりリースされたばかりで今後改良が必要と思いますが、
今後とも宜しくお願いいたします(^^

