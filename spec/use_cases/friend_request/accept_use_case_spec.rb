# MEMO:「友達申請処理」におけるusecase層での責務、usecase層に対応するテスト（本ファイル）が凄く勉強にるので、この設計は毎回は見直したい。

require 'rails_helper'

RSpec.describe FriendRequest::AcceptUseCase do
  describe '.run' do
    describe '処理内容について' do
      # MEMO: FriendRequestオブジェクトを作成（友達申請）する
      subject { described_class.run(operation_user: operation_user, friend_request: friend_request) }

      # MEMO:let は、subject 定義後に記述できる。若干違和感あるけど、これがrails
      let(:operation_user) { create(:user) }
      let(:friend_request) { create(:friend_request, to_user: operation_user) }
      
      before do
        # MEMO:RSpec のメソッドである、instance_doubleは、モックを作成する
          # 効果効能：FriendRequest::AcceptCommandクラスのインスタンスのダブルを作成し、success?メソッドが呼び出されたときにtrueを返すように設定
        command = instance_double(FriendRequest::AcceptCommand, success?: true)
        
        # MEMO:allow_to_receive_mocked_runは、以下で定義されている → spec/support/helpers/mock.rb
        allow_to_receive_mocked_run(FriendRequest::AcceptCommand).and_return(command)
      end

      # 正常系
      it 'つながり申請承認コマンドを呼び出す' do
        expect(subject.success?).to eq true
        expect(FriendRequest::AcceptCommand)
          .to have_received(:run)
          .with(friend_request: friend_request)
      end

      # 正常系
      it '通知ジョブをエンキューする' do
        allow_to_receive_mocked_run(Notification::AcceptFriendRequest)

        perform_enqueued_jobs do
          expect(subject.success?).to eq true
        end

        # have_receivedマッチャ。with 以下の引数を持たせて”メソッド自体が呼ばれたこと”を検証するマッチャ
        expect(Notification::AcceptFriendRequest)
          .to have_received(:run)
          .with(friend_request: friend_request)
      end
    end

    describe 'バリデーションについて' do
      # 異常系
      context '操作者に権限がない場合' do
        subject { described_class.run(operation_user: operation_user, friend_request: friend_request) }

        let(:operation_user) { create(:user) }
        let(:friend_request) { create(:friend_request, to_user: create(:user)) } # `to_user` is not `current_user`

        it '失敗する' do
          expect(subject.success?).to eq false
        end
      end

      # 異常系
      context 'つながり申請送信コマンドに失敗した場合' do
        subject { described_class.run(operation_user: operation_user, friend_request: friend_request) }

        let(:operation_user) { create(:user) }
        let(:friend_request) { create(:friend_request, to_user: operation_user) }

        before do
          command = instance_double(FriendRequest::AcceptCommand, success?: false)
          allow_to_receive_mocked_run(FriendRequest::AcceptCommand).and_return(command)
        end

        it '失敗する' do
          expect(subject.success?).to eq false
        end
      end
    end
  end
end
