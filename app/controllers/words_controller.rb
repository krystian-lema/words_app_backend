class WordsController < ApplicationController
  before_action :authorize
  before_action :find_collection, only: %i[get_words_from_collection create_word]
  before_action :find_word, only: %i[edit_word delete_word]
  before_action :check_word_permission, only: %i[edit_word delete_word]

  def get_words_from_collection
    if @collection.present?
      if check_collection_permission(@collection)
        @words = @collection.word.all.order('created_at')
        render json: { success: true, words: @words, auth_token: updated_auth_token }
      end
    else
      render json: { success: false, error: 'Collection with id ' + params['id'] + ' not found', auth_token: updated_auth_token }
    end
  end

  def create_word
    word = Word.new(create_word_params)
    if @collection.present?
      word.word_collection = @collection
      if word.save
        render json: { success: true, word: word, auth_token: updated_auth_token }
      else
        render json: { success: false, error: word.errors.full_messages.first, auth_token: updated_auth_token }
      end
    else
      render json: { success: false, error: 'Collection with id ' + params['id'] + ' not found', auth_token: updated_auth_token }
    end
  end

  def edit_word
    if @word.update(edit_word_params)
      render json: { success: true, word: @word, auth_token: updated_auth_token }
    else
      render json: { success: false, error: @word.errors.full_messages.first, auth_token: updated_auth_token }
    end
  end

  def delete_word
    if @word.destroy
      render json: { success: true, auth_token: updated_auth_token }
    else
      render json: { success: false, error: @word.errors.full_messages.first, auth_token: updated_auth_token }
    end
  end

  private

  def find_collection
    @collection = WordCollection.find(params[:id]) if WordCollection.where(id: params[:id]).present?
    render json: { success: false, error: 'Colllection does not exist', auth_token: updated_auth_token } if @collection.blank?
  end

  def find_word
    @word = Word.find(params[:id]) if Word.where(id: params[:id]).present?
    render json: { success: false, error: 'Word does not exist', auth_token: updated_auth_token } if @word.blank?
  end

  def check_collection_permission(collection)
    condition = collection.public
    condition ||= collection.user.id == current_user.id
    render json: { success: false, error: 'Permission denied', auth_token: updated_auth_token } unless condition
    condition
  end

  def check_word_permission
    condition = @word.word_collection.user.id == current_user.id if @word.present?
    render json: { success: false, error: 'Permission denied', auth_token: updated_auth_token } unless condition
  end

  def create_word_params
    params.require(:word).permit(:definition, :translation)
  end

  def edit_word_params
    params.require(:word).permit(:definition, :translation)
  end
end
