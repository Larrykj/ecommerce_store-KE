require "test_helper"

class GiftCardsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:one)
  end

  test "should redirect index when not signed in" do
    get gift_cards_url
    assert_redirected_to new_user_session_url
  end

  test "should get index when signed in" do
    sign_in @user
    get gift_cards_url
    assert_response :success
  end

  test "should get new when signed in" do
    sign_in @user
    get new_gift_card_url
    assert_response :success
  end

  test "should create gift card" do
    sign_in @user
    assert_difference("GiftCard.count") do
      post gift_cards_url, params: {
        gift_card: { initial_value: 1000 }
      }
    end
    assert_redirected_to gift_cards_url
  end

  test "should check balance via post" do
    gc = gift_cards(:one)
    post "/gift-cards/check-balance", params: { code: gc.code }
    assert_response :success
  end

  test "should not create gift card with invalid value" do
    sign_in @user
    assert_no_difference("GiftCard.count") do
      post gift_cards_url, params: {
        gift_card: { initial_value: 0 }
      }
    end
    assert_response :unprocessable_entity
  end
end
