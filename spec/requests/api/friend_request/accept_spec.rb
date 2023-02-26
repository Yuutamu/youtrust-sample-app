require 'rails_helper'

RSpec.describe '/api/friend_requests/:id/accept' do
  describe 'PUT /api/friend_requests/:id/accept' do
    describe '200系' do
      context 'つながり申請承認が成功した場合' do
        let(:current_user) { create(:user) }
        let(:friend_request) { create(:friend_request, to_user: current_user) }

        before do
          sign_in current_user
        end

        it '201' do
          use_case = instance_double(FriendRequest::AcceptUseCase, success?: true)
          allow_to_receive_mocked_run(FriendRequest::AcceptUseCase).and_return(use_case)

          put "/api/friend_requests/#{friend_request.encrypted_id}/accept"
          expect(response).to have_http_status(:ok)
        end
      end
    end

    describe '4XX系' do
      context '未認証の場合' do
        let(:current_user) { create(:user) }
        let(:friend_request) { create(:friend_request, to_user: current_user) }

        it '401' do
          put "/api/friend_requests/#{friend_request.encrypted_id}/accept"
          expect(response).to have_http_status(:unauthorized)
        end
      end

      context '不正なパラメーターが指定された場合' do
        let(:current_user) { create(:user) }

        before do
          sign_in current_user
        end

        it '404' do
          put '/api/friend_requests/INVALID/accept'
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'つながり申請承認が失敗した場合' do
        let(:current_user) { create(:user) }
        let(:friend_request) { create(:friend_request, to_user: current_user) }

        before do
          sign_in current_user
        end

        it '400' do
          use_case = instance_double(FriendRequest::AcceptUseCase, success?: false)
          allow_to_receive_mocked_run(FriendRequest::AcceptUseCase).and_return(use_case)

          put "/api/friend_requests/#{friend_request.encrypted_id}/accept"
          expect(response).to have_http_status(:bad_request)
        end
      end
    end
  end
end
