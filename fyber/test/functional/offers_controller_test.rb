require 'test_helper'

class OffersControllerTest < ActionController::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "should get index" do
  	get :index
  	assert_response :success
  end

  test "form is rendered" do 
    get :index
    assert_select "#offerForm", count: 1
    assert_select "#offerForm input", count: 3
    assert_select "#offerForm button", count: 1
  end

  test "should fetch offers" do
  	post :fetch, :offers => {"page" => 1, 'pub0' => 'campaingn', 'uid' => 'testFyber'}
  	assert_select ".noContent", count: 1
  end

  test "should throw error for no uid" do
  	post :fetch, :offers => {"page" => 1, 'pub0' => 'campaingn'}
  	assert_select ".error", count: 1
  end
end
