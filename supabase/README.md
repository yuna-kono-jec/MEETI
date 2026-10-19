# Supabaseの準備

`migrations/202610190001_create_participants.sql`をSupabaseのSQL Editorで実行する。

Authenticationの設定でAnonymous Sign-Insを有効にすると、各実機が初回接続時に匿名ユーザーとしてログインできる。すでに運営アカウントでログインしている実機は、そのログインをそのまま使う。

この設定で次のデータを複数端末から共有できる。

- 受付番号
- ニックネーム
- MBTI
- 好きなこと
- ひとこと
- 性別
- 年代
- プロフィール写真の保存場所
