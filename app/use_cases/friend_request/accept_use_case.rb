class FriendRequest::AcceptUseCase
  include UseCase

  attr_reader :operation_user, :friend_request

  validate :validate_operation_user

  # runメソッドの中でrun が呼ばれていて...!?だったが、includeしてきたモジュールのrun（**args）メソッド
  def run
    command = ApplicationRecord.transaction do
      lock_users
      FriendRequest::AcceptCommand.run(friend_request: friend_request)
    end

    if command && command.success?
      enqueue_notification_job
    else
      errors.add(:friend_request, :invalid)
    end
  end

  def initialize(operation_user:, friend_request:)
    @operation_user = operation_user
    @friend_request = friend_request
  end

  private

  def lock_users
    User.lock_users(friend_request.from_user, friend_request.to_user)
  end

  # app/jobs/notification_job.rb にて定義された perform メソッドをRails内部側で”自動的に”非同期のメソッドも用意してくれる
  # Railsガイド（ActiveJobの章）https://railsguides.jp/active_job_basics.html
  def enqueue_notification_job
    NotificationJob.perform_later(:accept_friend_request, friend_request: friend_request)
  end

  def validate_operation_user
    if operation_user != friend_request.to_user
      errors.add(:operation_user, :invalid)
    end
  end
end
