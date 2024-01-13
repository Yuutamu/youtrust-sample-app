# MEMO:RSpec で利用するカスタムメソッドを共通化して定義している

module Helpers
  module Mock
    def allow_to_receive_mocked_run(klass)
      allow(klass).to receive(:run) { |**args| klass.new(**args) }
    end
  end
end

# RSpecのallowメソッド:
  # allow(klass):
  # 指定したオブジェクト（この場合はklass）のメソッドの振る舞いをスタブ（模倣）するために使用

# to receive(:run):
  # 指定したメソッド（この場合は:run）が呼び出されたときの振る舞いを設定
  # :runはシンボルで、klassクラスのrunメソッドを指す

# **args
  # キーワード引数