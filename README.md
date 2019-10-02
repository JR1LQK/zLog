# zLog for Windows

Amateur Radio Contest Logging Program

# Dependency
Delphi

# Requirement
Windows
Windows専用ですが，Delphiで書かれているのでMacOSやLinuxへの移植も可能かもしれません

# Licence
This software is released under the GNU General Public License.

# Authors
Yokobayashi Yohei (ex. JJ1MED), JARL Contest Committee

# Document
There is no documentation for the developer.
開発のためのドキュメントはありません

zLog for Windowsは元東京大学アマチュア無線部JA1ZLOの横林洋平さん（ex. JJ1MED）
が開発した，アマチュア無線コンテストロギングソフトです．
すでに横林さんはzLog for Windowsのメンテナンスに係わっておらず，現在公開され
ている最新版は2004年11月20日に公開されたzLog for Windows 2.2です．

http://www.zlog.org/zlog/zlogwin.html

Windows 10での動作は不安定で，動作することもあれば動作しないこともあるという状
態です．
また，JARL電子ログでの提出時に「59 M」のように，送信マルチが空白になることがあ
るという，問題があります．また，全市全郡コンテストで市郡区ナンバーが6桁の場合，
RSTと送信マルチがつながってしまい，自動解析ができません．

JARLコンテスト委員会は横林さんからzLog for Windowsのソースコードをいただき，
ここにMITライセンスによるオープンソースとして公開します．有志による改良を期待します．

------
ビルド方法 de JR8PPG
(1)Delphi 10.3.2でビルドするにあたり、ICSは下記のサイトのICSV8.58を使用
http://www.overbyte.eu/frame_index.html?redirTo=/products/ics.html
InstallフォルダのD103Install.groupprojを開き、ビルド→インストール 

(2)VCLフォルダのzlog_requires.dpkを開き、ビルド→インストール
(3)オプション－言語－DelphiでライブラリパスにVCLフォルダとその下を追加
(4)zlogフォルダのzlog.dprojを開き、ビルド
(5)完成

オリジナルからの変更点
(1)JARL ELOG 2.0に対応
(2)LPTポート対応廃止
(3)Voice対応廃止
(4)Windows7/10で目立つ不具合修正
(5)など

