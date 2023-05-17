alias BlogApp.Repo
alias BlogApp.Accounts.Account
alias BlogApp.Articles.Article
alias BlogApp.Comments.Comment
alias BlogApp.Likes.Like

params = [
  {"user01", "user01@sample.com", "user01999"},
  {"user02", "user02@sample.com", "user02999"},
  {"user03", "user03@sample.com", "user03999"},
  {"user04", "user04@sample.com", "user04999"},
  {"user05", "user05@sample.com", "user05999"}
]

[a01, a02, a03, a04, a05] =
  Enum.map(params, fn {name, email, password} ->
    Repo.insert!(
      %Account{
        name: name,
        email: email,
        hashed_password: Bcrypt.hash_pwd_salt(password),
        confirmed_at: NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      }
    )
  end)

article1 =
  Repo.insert!(
    %Article{
      title: "初めての投稿",
      body: """
        初めての投稿をします。
        よろしくお願いします。
      """,
      status: 1,
      submit_date: Date.utc_today(),
      account_id: a01.id
    }
  )

Repo.insert!(
  %Comment{
    body: """
      初めまして#{a01.name}さん!!
    """,
    account_id: a02.id,
    article_id: article1.id
  }
)

Enum.each([a02, a03, a04, a05], fn account ->
  Repo.insert!(
    %Like{
      account_id: account.id,
      article_id: article1.id
    }
  )
end)
