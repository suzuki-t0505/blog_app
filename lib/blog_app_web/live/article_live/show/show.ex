defmodule BlogAppWeb.ArticleLive.Show do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles
  alias BlogApp.Comments

  def mount(%{"article_id" => article_id}, _session, socket) do
    article = Articles.get_article!(article_id)
    cs = Comments.change_comment(%Comments.Comment{})
    current_account_id =
      Map.get(socket.assigns.current_account || %{}, :id)

    socket =
      socket
      |> assign(:current_account_id, current_account_id)
      |> assign(:article, article)
      |> assign_form(cs)
      |> assign(:page_title, article.title)

    {:ok, socket}
  end

  def handle_event("like_article", %{"account_id" => account_id}, socket) do
    article_id = socket.assigns.article.id
    Articles.liked_article(article_id, account_id)

    {:noreply, assign(socket, :article, Articles.get_article!(article_id))}
  end

  def handle_event("comment_validate", %{"comment" => params}, socket) do
    cs = Comments.change_comment(%Comments.Comment{}, params)
    {:noreply, assign_form(socket, cs)}
  end

  def handle_event("comment_save", %{"comment" => params}, socket) do
    params =
      Map.merge(params, %{"account_id" => socket.assigns.current_account.id, "article_id" => socket.assigns.article.id})

    socket =
      case Comments.create_comment(params) do
        {:ok, _comment} ->
          cs = Comments.change_comment(%Comments.Comment{})

          socket
          |> put_flash(:info, "Comment created successfully")
          |> assign(:article, Articles.get_article!(socket.assigns.article.id))
          |> assign_form(cs)

        {:error, %Ecto.Changeset{} = cs} ->
          assign_form(socket, cs)
      end

    {:noreply, socket}
  end

  defp assign_form(socket, cs) do
    assign(socket, :form, to_form(cs))
  end
end
