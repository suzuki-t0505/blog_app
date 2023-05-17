defmodule BlogAppWeb.AccountLive.Info do
  use BlogAppWeb, :live_view

  alias BlogApp.Accounts
  alias BlogApp.Articles

  def mount(%{"account_id" => account_id}, _session, socket) do
    account = Accounts.get_account!(account_id)
    current_account_id =
      Map.get(socket.assigns.current_account || %{}, :id)

    articles =
      Articles.list_articles_for_account(account.id, current_account_id)

    articles_count =
      Enum.count(articles)


    socket =
      socket
      |> assign(:account, account)
      |> assign(:articles, articles)
      |> assign(:articles_count, articles_count)
      |> assign(:set_article_id, nil)
      |> assign(:page_title, account.name)

    {:ok, socket}
  end

  def handle_event("set_article_id", %{"id" => id}, socket) do
    id =
      unless id == "#{socket.assigns.set_article_id}", do: String.to_integer(id), else: nil
    {:noreply, assign(socket, :set_article_id, id)}
  end

  def handle_event("delete_article", %{"id" => id}, socket) do
    socket =
      case Articles.delete_article(Articles.get_article!(id)) do
        {:ok, _article} ->
          socket
          |> assign(:articles, Articles.list_articles_for_account(socket.assigns.account.id, socket.assigns.current_account.id))
          |> put_flash(:info, "Article deleted successfully")

        {:error, _cs} ->
          put_flash(socket, :error, "Could not delete article")
      end

    {:noreply, socket}
  end
end
