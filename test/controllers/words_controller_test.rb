require 'test_helper'
require 'words_controller'

class WordsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @my_collection = word_collections(:one)
    @not_my_collection = word_collections(:two)
    @public_collection = word_collections(:three)
    @my_word = words(:one)
    @not_my_word = words(:two)
  end

  test 'get words from public collection' do
    token = login_as_user
    get '/collections/' + @public_collection.id.to_s + '/words', params: { auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
  end

  test 'get words from user collection' do
    token = login_as_user
    get '/collections/' + @my_collection.id.to_s + '/words', params: { auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
  end

  test 'should not get words from collection when is not logged in' do
    token = login_as_user
    get '/collections/' + @my_collection.id.to_s + '/words'
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'should not get words from collection when colelction not belongs to the user' do
    token = login_as_user
    get '/collections/' + @not_my_collection.id.to_s + '/words', params: { auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'create word' do
    token = login_as_user
    assert_difference('@my_collection.word.count', 1, 'Word should be created') do
      post '/collections/' + @my_collection.id.to_s + '/words', params: { word: { definition: 'def',
                                                                                  translation: 'trans' }, auth_token: token }
    end
  end

  test 'should not create word when is not logged in' do
    token = login_as_user
    assert_no_difference('@my_collection.word.count', 'Word should not be created') do
      post '/collections/' + @my_collection.id.to_s + '/words', params: { word: { definition: 'def',
                                                                                  translation: 'trans' } }
    end
  end

  test 'edit word' do
    token = login_as_user
    old_definition = @my_word.definition
    old_translation = @my_word.translation
    new_definition = 'updated'
    new_translation = 'updated'
    patch '/words/' + @my_word.id.to_s, params: { word: { definition: new_definition,
                                                          translation: new_translation }, auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
    assert_equal new_definition, @my_word.reload.definition
    assert_equal new_translation, @my_word.reload.translation
  end

  test 'should not edit word when is not logged in' do
    token = login_as_user
    old_definition = @my_word.definition
    old_translation = @my_word.translation
    new_definition = 'updated'
    new_translation = 'updated'
    patch '/words/' + @my_word.id.to_s, params: { word: { definition: new_definition,
                                                          translation: new_translation } }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal old_definition, @my_word.reload.definition
    assert_equal old_translation, @my_word.reload.translation
  end

  test 'should not edit word when word belongs to other user collection' do
    token = login_as_user
    old_definition = @my_word.definition
    old_translation = @my_word.translation
    new_definition = 'updated'
    new_translation = 'updated'
    patch '/words/' + @not_my_word.id.to_s, params: { word: { definition: new_definition,
                                                              translation: new_translation }, auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal old_definition, @my_word.reload.definition
    assert_equal old_translation, @my_word.reload.translation
  end

  test 'delete word' do
    token = login_as_user
    assert_difference('Word.count', -1, 'Word should be deleted') do
      delete '/words/' + @my_word.id.to_s, params: { auth_token: token }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal true, json_response['success'], json_response['error']
  end

  test 'should not delete word when is not logged in' do
    token = login_as_user
    assert_difference('Word.count', 0, 'Word should not be deleted') do
      delete '/words/' + @my_word.id.to_s
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'should not delete word when word belongs to other user collection' do
    token = login_as_user
    assert_difference('Word.count', 0, 'Word should not be deleted') do
      delete '/words/' + @not_my_word.id.to_s, params: { auth_token: token }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end

  test 'try edit word that not exist' do
    token = login_as_user
    old_definition = @my_word.definition
    old_translation = @my_word.translation
    new_definition = 'updated'
    new_translation = 'updated'
    patch '/words/1', params: { word: { definition: new_definition,
                                        translation: new_translation }, auth_token: token }
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
    assert_equal old_definition, @my_word.reload.definition
    assert_equal old_translation, @my_word.reload.translation
  end

  test 'try delete word that not exist' do
    token = login_as_user
    assert_difference('Word.count', 0, 'Word should not be deleted') do
      delete '/words/1', params: { auth_token: token }
    end
    json_response = ActiveSupport::JSON.decode @response.body
    assert_equal false, json_response['success'], json_response['error']
  end
end
