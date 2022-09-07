alias Fox.Repo
alias Fox.Users
alias Fox.Institutions

defmodule I do
  def set_user do
    user = Users.get_user_by_email("toreskog@live.com")
    Repo.put_user(user)
  end
end
