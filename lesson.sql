-- 問題 1
-- 問題: 全てのユーザーの名前と姓を取得してください。
-- 説明: usersテーブルのfirst_nameとlast_nameのすべてのレコードを取得するクエリを作成します。


SELECT first_name, last_name FROM users;



-- 問題 2
-- 問題: 「John Doe」が投稿したツイートをすべて取得してください。
-- 説明: usersテーブルとtweetsテーブルを結合し、first_nameが”John”で、last_nameが”Doe”のユーザーのツイートを取得します。


SELECT tweet FROM users INNER JOIN tweets on users.id = tweets.user_id
WHERE users.first_name = "John" AND users.last_name = "Doe";




-- 問題 3
-- 問題: 「Jane Smith」が投稿したリプライをすべて取得してください。
-- 説明: usersテーブルとreplysテーブルを結合し、first_nameが”Jane”で、last_nameが”Smith”のユーザーのリプライを取得します。


SELECT reply FROM replys INNER JOIN users ON users.id = replys.user_id
WHERE users.first_name = "Jane" AND users.last_name = "Smith";




-- 問題 4
-- 問題: どのツイートにもリプライをしていないユーザーの名前と姓を取得してください。
-- 説明: replysテーブルにレコードが存在しないusersテーブルのユーザーを取得します。


SELECT last_name, first_name FROM users LEFT OUTER JOIN replys ON users.id = replys.user_id 
WHERE replys.user_id IS NULL;




-- 問題 5
-- 問題: 「Charlie Brown」が投稿したツイートの数をカウントしてください。
-- 説明: usersテーブルとtweetsテーブルを結合し、first_nameが”Charlie”で、last_nameが”Brown"のユーザーが投稿したツイートの件数をカウントします。


SELECT COUNT(tweets.tweet) FROM users INNER JOIN tweets ON users.id = tweets.user_id
WHERE users.first_name = "Charlie" AND users.last_name = "Brown";



-- 問題 6
-- 問題: もっともリプライが多いツイートのIDとリプライ数を取得してください。
-- 説明: replysテーブルを使って、各ツイートに対するリプライの数をカウントし、一番多いリプライ数を持つツイートIDを取得します。


SELECT tweet_id, COUNT(tweet_id) FROM replys 
WHERE tweet_id = (SELECT MAX(tweet_id) FROM replys);



-- 問題 7
-- 問題: 全てのツイートと、それに対するリプライがあればその内容も取得してください。
-- 説明: tweetsテーブルとreplysテーブルを結合して、各ツイートとそのリプライを取得します。リプライがない場合はツイートだけ表示されます。


/* ツイートを取得、そのリプライを取得、IFNULLで値NULLの時空白へ置換 */
SELECT tweets.tweet, IFNULL(replys.reply, "") 
FROM tweets LEFT OUTER JOIN replys ON tweets.id = replys.tweet_id;



-- 問題 8
-- 問題: ユーザーごとのツイート数とリプライ数を取得してください。
-- 説明: 各ユーザーのツイート数とリプライ数を集計して、それぞれを表示します。


/* ID、名前、ツイート数をカウント、リプライ数をカウント */
SELECT users.id, first_name, last_name, COUNT(tweets.user_id) AS tweet, COUNT(replys.user_id) AS reply 
FROM users 
LEFT OUTER JOIN tweets 
ON users.id = tweets.user_id 
LEFT OUTER JOIN replys 
ON tweets.id = replys.tweet_id 
GROUP BY tweets.user_id;



-- 問題 9
-- 問題: もっとも多くリプライを投稿したユーザーの名前と姓を取得してください。
-- 説明: replysテーブルを使って、リプライをもっとも多く投稿したユーザーを特定し、そのユーザーの名前と姓を取得します。


/* ユーザー名の取得 */
SELECT tmp.first_name, tmp.last_name 
FROM 
(   /* （サブクエリ３）[仮テーブル tmp] (サブクエリ１、２)テーブルデータから取得　 */
    SELECT first_name, last_name, COUNT(replys.user_id) AS cnt2 
    FROM 
    users LEFT OUTER JOIN replys 
    ON users.id = replys.user_id 
    GROUP BY user_id
) tmp 

  /* （サブクエリ２）[仮テーブル num] (サブクエリ１)テーブルデータからカウント最大数の取得  */
WHERE tmp.cnt2 = 
(
    SELECT MAX(cnt) 
    FROM 
      /* (サブクエリ１) replys-users結合 リプライ数のカウント取得 */
    (
        SELECT first_name, last_name, COUNT(replys.user_id) AS cnt 
        FROM users 
        LEFT OUTER JOIN replys 
        ON users.id = replys.user_id 
        GROUP BY user_id
    ) num
);


-- 問題 10
-- 問題: すべてのツイートの内容と、それを投稿したユーザーの名前を取得してください。ただし、リプライもツイートとして扱い、それがどのツイートに対するリプライかも表示してください。
-- 説明: tweetsテーブル、replysテーブル、usersテーブルを結合し、ツイートとリプライを含むすべての投稿とそれに関連するユーザー情報を取得します。


SELECT union_r_t.all_tweet, CONCAT(users.first_name, users.last_name) AS tweet_user, tmp.tweet AS original_tweet, CONCAT(tmp.first_name, tmp.last_name) AS tweet_user
FROM users 
RIGHT OUTER JOIN 
(--  サブクエリ「union_r_t」 (リプライ = ツイート = ユーザー) 
        -- リプライ = ユーザー
        SELECT r.reply AS all_tweet, r.user_id, r.tweet_id AS id
        FROM replys AS r 
        LEFT OUTER JOIN users AS u 
        ON r.user_id = u.id 

    UNION ALL
        -- ツイート = ユーザー
        SELECT t.tweet  AS all_tweet, t.user_id, t.id AS id
        FROM tweets AS t 
        LEFT OUTER JOIN users AS u 
        ON t.user_id = u.id 
) AS union_r_t 
ON users.id = union_r_t.user_id 
LEFT OUTER JOIN
-- サブクエリ「tmp」（ツイート = ユーザー) 
(-- ツイート = ユーザー
        SELECT t.id AS t_id, t.tweet, u.id AS u_id, u.first_name, u.last_name
        FROM tweets AS t
        LEFT OUTER JOIN users AS u 
        ON t.user_id = u.id
) AS tmp 
ON tmp.t_id = union_r_t.id 
;