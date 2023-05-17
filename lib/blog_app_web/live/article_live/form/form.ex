defmodule BlogAppWeb.ArticleLive.Form do
  use BlogAppWeb, :live_view

  alias BlogApp.Articles

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    socket =
      apply_action(socket, socket.assigns.live_action, params)

    {:noreply, socket}
  end

  def handle_event("validate", %{"article" => params}, socket) do
    cs = Articles.change_article(socket.assigns.article, params)
    {:noreply, assign_form(socket, cs)}
  end

  def handle_event("save", %{"article" => params}, socket) do
    socket =
      save_article(socket, socket.assigns.live_action, params)

    {:noreply, socket}
  end

  defp apply_action(socket, :edit, %{"article_id" => article_id}) do
    socket
    |> assign(:page_title, "Edit Article")
    |> assign(:article, Articles.get_article!(article_id))
    |> assign_form(%{})
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Article")
    |> assign(:article, %Articles.Article{})
    |> assign_form(%{})
  end

  defp save_article(socket, :edit, params) do
    case Articles.update_article(socket.assigns.article, params) do
      {:ok, article} ->
        socket
        |> put_flash(:info, "Article updated successfully")
        |> redirect(to: ~p"/articles/show/#{article.id}")

      {:error, %Ecto.Changeset{} = cs} ->
        assign_form(socket, cs)
    end
  end

  defp save_article(socket, :new, params) do
    current_account_id = socket.assigns.current_account.id
    params = Map.merge(params, %{"account_id" => current_account_id})
    case Articles.create_article(params) do
      {:ok, %Articles.Article{submit_date: nil}} ->
        socket
        |> put_flash(:info, "Article saved successfully")
        |> redirect(to: ~p"/accounts/profile/#{current_account_id}/draft")

      {:ok, %Articles.Article{id: id}} ->
        socket
        |> put_flash(:info, "Article created successfully")
        |> redirect(to: ~p"/articles/show/#{id}")

      {:error, %Ecto.Changeset{} = cs} ->
        assign_form(socket, cs)
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = cs) do
    assign(socket, :form, to_form(cs))
  end

  defp assign_form(socket, params) do
    cs = Articles.change_article(socket.assigns.article, params)
    assign(socket, :form, to_form(cs))
  end
end
