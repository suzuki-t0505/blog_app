defmodule BlogAppWeb.AccountLive.Likes do
  use BlogAppWeb, :live_view

  alias BlogApp.Accounts
  alias BlogApp.Articles

  def mount(%{"account_id" => account_id}, _session, socket) do
    account = Accounts.get_account!(account_id)
    current_account_id =
      Map.get(socket.assigns.current_account || %{}, :id)

    articles_count =
      account_id
      |> Articles.list_articles_for_account(current_account_id)
      |> Enum.count()

    socket =
      socket
      |> assign(:articles_count, articles_count)
      |> assign(:articles, Articles.list_liked_articles_for_account(account_id))
      |> assign(:account, account)
      |> assign(:page_title, account.name <> " - liked")

    {:ok, socket}
  end
end
