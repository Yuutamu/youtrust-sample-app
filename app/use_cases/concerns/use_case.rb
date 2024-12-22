# ゆうたむポエム：綺麗な設計って、こうゆうことかと感動した。
  # usecase層で利用する”基本的な”メソッドは、モジュールで管理
  # それぞれのusecaseファイルで、このモジュールをinclude して直接、run メソッド等を利用する
  # また、更新系だったり、処理の組み合わせはUsecaseで実行しており、単なる参照系はQuery層？で行っているのが素敵
  # →ここまで責務と役割が明確であれば、読みやすい＆デバックしやすい＆どこに書くか悩まずに済みそうだなあ。

module UseCase
  extend ActiveSupport::Concern
  include ActiveModel::Model

  module ClassMethods
    def run(**args)
      new(**args).tap { |use_case| use_case.valid? && use_case.run }
    end
  end

  def run
    raise NotImplementedError
  end

  def initialize
    raise NotImplementedError
  end

  def success?
    errors.none?
  end

  def raise_rollback
    raise ActiveRecord::Rollback
  end
end
