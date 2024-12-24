class Api::SearchUsersController < Api::ApplicationController
  before_action :authenticate_user!

  def index
    @user_ids = User
      .where
      .not(id: current_user.id)
      .map(&:encrypted_id)
  end
end

# select *
# from users
# where users.id != current_user.id
# ここまでやった後に、mapで encrypted_id