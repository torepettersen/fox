defmodule FoxWeb.Router do
  use FoxWeb, :router

  import FoxWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {FoxWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FoxWeb do
    pipe_through :browser

    live "/", LandingPageLive
  end

  scope "/", FoxWeb do
    pipe_through [:browser, :require_authenticated_user]

    live "/banks", BanksLive
    live "/accounts", AccountsLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", FoxWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: FoxWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", FoxWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live "/registration", UserRegistrationLive
    post "/registration", UserRegistrationController, :create

    live "/sign-in", UserSessionLive
    post "/sign-in", UserSessionController, :create

    live "/reset-password", UserResetPasswordLive, :new

    live "/reset-password/:token", UserResetPasswordLive, :edit
  end

  scope "/", FoxWeb do
    pipe_through [:browser]

    delete "/sign-out", UserSessionController, :delete
  end
end
