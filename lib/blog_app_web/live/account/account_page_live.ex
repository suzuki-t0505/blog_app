defmodule BlogAppWeb.AccountPageLive do
  use BlogAppWeb, :live_view

  alias BlogApp.Accounts
  alias BlogApp.Articles

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  # "/accounts/profile/:account_id"
  # "/accounts/profile/:account_id/draft"
  # "/accounts/profile/:account_id/likes"
  # で呼ばれるやつ
  def handle_params(%{"account_id" => account_id}, _uri, socket) do
    socket =
      socket
      |> assign(:account, Accounts.get_account!(account_id))
      |> apply_action(socket.assigns.live_action)

    {:noreply, socket}
  end

  def handle_params(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_account_email(socket.assigns.current_account, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/accounts/profile/#{socket.assigns.current_account.id}")}
  end

  def handle_params(_params, _session, socket) do
    {:noreply, apply_action(socket, :edit)}
  end

  # "/accounts/profile/:account_id"で呼ばれるやつ
  defp apply_action(socket, :info) do
    account = socket.assigns.account
    articles =
      Articles.list_articles_for_account(account.id, get_current_account_id(socket))

    articles_count =
      Enum.count(articles)

    socket
    |> assign_article(articles)
    |> assign(:articles_count, articles_count)
    |> assign(:page_title, account.name)
  end

  # "/accounts/profile/:account_id/draft"で呼ばれるやつ
  defp apply_action(socket, :draft) do
    current_account_id = get_current_account_id(socket)

    socket
    |> assign_article(Articles.list_draft_articles_for_account(current_account_id))
    |> assign_articles_count(current_account_id, current_account_id)
    |> assign(:page_title, socket.assigns.current_account.name <> " - draft")
  end

  # "/accounts/profile/:account_id/likes"で呼ばれるやつ
  defp apply_action(socket, :likes) do
    account = socket.assigns.account

    socket
    |> assign_article(Articles.list_liked_articles_for_account(account.id))
    |> assign_articles_count(account.id, get_current_account_id(socket))
    |> assign(:page_title, account.name <> " - liked")
  end

  defp apply_action(socket, :edit) do
    account = socket.assigns.current_account
    socket
    |> assign(:account, account)
    |> assign_article([])
    |> assign_articles_count(account.id, get_current_account_id(socket))
    |> assign(:page_title, "account settings")
  end

  defp get_current_account_id(socket) do
    Map.get(socket.assigns.current_account || %{}, :id)
  end

  defp assign_articles_count(socket, account_id, current_account_id) do
    articles_count =
      account_id
      |> Articles.list_articles_for_account(current_account_id)
      |> Enum.count()

    assign(socket, :articles_count, articles_count)
  end

  defp assign_article(socket, articles) do
    socket
    |> assign(:articles, articles)
    |> assign(:set_article_id, nil)
  end

  def handle_info({:updated, %Accounts.Account{id: id}}, socket) do
    {:noreply, redirect(socket, to: ~p"/accounts/profile/#{id}")}
  end

  def handle_info({:update_email, %Accounts.Account{id: id}}, socket) do
    socket =
      socket
      |> put_flash(:info, "A link to confirm your email change has been sent to the new address.")
      |> redirect(to: ~p"/accounts/profile/#{id}")

    {:noreply, socket}
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
