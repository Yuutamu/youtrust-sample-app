class NotificationJob < ApplicationJob
  # Usecaseから呼ばれて、klass内での対応するクラスを呼び出す”だけ”なのが美しい
  queue_as :default

  KLASS_BY_TYPE = {
    send_friend_request: Notification::SendFriendRequest,
    accept_friend_request: Notification::AcceptFriendRequest,
  }.freeze

  # jobをエンキューする際に、type, **args（ハッシュ） の引数を渡して　 performメソッドを行う
  # app/use_cases/friend_request/accept_use_case.rb　Usecase層このメソッドが呼ばれている場所見るとわかりやすい
  def perform(type, **args)
    klass = KLASS_BY_TYPE.fetch(type.to_sym)
    klass.run(**args)
  end
end
