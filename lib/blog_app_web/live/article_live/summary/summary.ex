defmodule BlogAppWeb.ArticleLive.Summary do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:articles, Articles.list_articles())
      |> assign(:page_title, "blog")
      |> assign_search_articles_form()

    {:ok, socket}
  end

  def handle_event("search_articles", %{"search_article" => %{"keyword" => keyword}}, socket) do
    socket =
      socket
      |> assign(:articles, Articles.search_articles_by_keywords(keyword))
      |> assign_search_articles_form()

    {:noreply, socket}
  end

  def assign_search_articles_form(socket) do
    assign(socket, :search_articles_form, to_form(%{}, as: "search_article"))
  end
end
