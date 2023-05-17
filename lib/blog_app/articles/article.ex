defmodule BlogApp.Articles.Article do
  use Ecto.Schema
  import Ecto.Changeset

  alias BlogApp.Accounts.Account
  alias BlogApp.Comments.Comment
  alias BlogApp.Likes.Like

  schema "articles" do
    field :body, :string
    field :status, :integer, default: 1
    field :submit_date, :date
    field :title, :string
    field :like_count, :integer, virtual: true
    belongs_to :account, Account

    timestamps()

    has_many :comments, Comment
    has_many :likes, Like
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :body, :status, :submit_date, :account_id])
    |> validate_article()
  end

  def validate_article(cs) do
    cs =
      validate_required(cs, :title, message: "Please fill in the title.")

    unless get_change(cs, :status) == 0 do
      cs
      |> change(%{submit_date: Date.utc_today()})
      |> validate_required(:body, message: "Please fill in the body.")
      |> validate_required(:submit_date)
    else
      cs
    end
  end
end
