defmodule BlogAppWeb.AccountLive.Draft do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles

  def mount(_params, _session, socket) do
    current_account = socket.assigns.current_account
    articles_count =
      current_account.id
      |> Articles.list_articles_for_account(current_account.id)
      |> Enum.count()

    socket =
      socket
      |> assign(:articles, Articles.list_draft_articles_for_account(current_account.id))
      |> assign(:articles_count, articles_count)
      |> assign(:set_article_id, nil)
      |> assign(:page_title, current_account.name <> " - draft")

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
          |> assign(:articles, Articles.list_draft_articles_for_account(socket.assigns.current_account.id))
          |> put_flash(:info, "Draft article deleted successfully")

        {:error, _cs} ->
          put_flash(socket, :error, "Could not delete draft article")
      end

    {:noreply, socket}
  end
end
