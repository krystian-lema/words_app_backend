require 'test_helper'
require 'word_collections_controller'

class WordCollectionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @my_collection = word_collections(:one)
    @not_my_collection = word_collections(:two)
    @public_collection = word_collections(:three)
  end

  test 'get public collections' do
    token = login_as_user
    get '/public_collections', params: { auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
  end

  test 'should not get public collections when is not logged in' do
    get '/public_collections'
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'get collections' do
    token = login_as_user
    get '/collections', params: { auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
  end

  test 'should not get collections when is not logged in' do
    get '/collections'
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'create collection' do
    token = login_as_user
    collection_name = 'Base Collection'
    assert_difference('WordCollection.count', 1, 'Collection should be created') do
      post '/collections', params: { word_collection: { name: collection_name }, auth_token: token }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
    created_collection = WordCollection.last
    assert_equal collection_name, created_collection.name, json_response['error']
    assert_equal true, @user.word_collection.where(name: created_collection.name).present?
  end

  test 'create my collection' do
    token = login_as_user
    collection_name = 'Base Collection'
    assert_difference('@user.word_collection.count', 1, 'Collection should be created') do
      post '/collections', params: { word_collection: { name: collection_name }, auth_token: token }
    end
    assert_equal collection_name, @user.word_collection.last.name 
    assert_equal false, @user.word_collection.last.public 
  end

  test 'should not create collection when is not logged in' do
    collection_name = 'Base Collection'
    assert_no_difference('WordCollection.count', 'Collection should not be created') do
      post '/collections', params: { word_collection: { name: collection_name } }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'change name of the collection' do
    token = login_as_user
    new_name = 'updated'
    patch '/collections/' + @my_collection.id.to_s, params: { word_collection: { name: new_name }, auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
    assert_equal new_name, @my_collection.reload.name
  end

  test 'should not change name of the collection when belongs to other user' do
    token = login_as_user
    new_name = 'updated'
    patch '/collections/' + @not_my_collection.id.to_s, params: { word_collection: { name: new_name }, auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_not_equal new_name, @not_my_collection.reload.name
  end

  test 'should not change name of the collection when is not logged in' do
    new_name = 'updated'
    patch '/collections/' + @my_collection.id.to_s, params: { word_collection: { name: new_name } }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_not_equal new_name, @my_collection.reload.name
  end

  test 'delete collection' do
    token = login_as_user
    assert_difference('WordCollection.count', -1, 'Collection should be deleted') do
      delete '/collections/' + @my_collection.id.to_s, params: { auth_token: token }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
  end

  test 'should not delete collection when belongs to other user' do
    token = login_as_user
    assert_no_difference('WordCollection.count', 'Collection should not be deleted') do
      delete '/collections/' + @not_my_collection.id.to_s, params: { auth_token: token }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'should not delete collection when is not logged in' do
    assert_no_difference('WordCollection.count', 'Collection should not be deleted') do
      delete '/collections/' + @my_collection.id.to_s
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end
end
