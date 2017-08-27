class WordsController < ApplicationController
  before_action :authorize
  before_action :find_collection, only: %i[get_words_from_collection create_word]
  before_action :find_word, only: %i[edit_word delete_word]
  before_action :check_word_permission, only: %i[edit_word delete_word]

  def get_words_from_collection
    if @collection.present?
      if check_collection_permission(@collection)
        @words = @collection.word.all.order('created_at')
        render_response(true, nil, { words: @words })
      end
    else
      render_response(false, 'Collection with id ' + params['id'] + ' not found', nil)
    end
  end

  def create_word
    word = Word.new(create_word_params)
    if @collection.present?
      word.word_collection = @collection
      if word.save
        render_response(true, nil, { word: word })
      else
        render_response(false, word.errors.full_messages.first, nil)
      end
    else
      render_response(false, 'Collection with id ' + params['id'] + ' not found', nil)
    end
  end

  def edit_word
    if @word.update(edit_word_params)
      render_response(true, nil, { word: @word })
    else
      render_response(false, @word.errors.full_messages.first, nil)
    end
  end

  def delete_word
    if @word.destroy
      render_response(true, nil, nil)
    else
      render_response(false, @word.errors.full_messages.first, nil)
    end
  end

  private

  def find_collection
    @collection = WordCollection.find(params[:id]) if WordCollection.where(id: params[:id]).present?
    render_response(false, 'Colllection does not exist', nil) if @collection.blank?
  end

  def find_word
    @word = Word.find(params[:id]) if Word.where(id: params[:id]).present?
    render_response(false, 'Word does not exist', nil) if @word.blank?
  end

  def check_collection_permission(collection)
    condition = collection.public
    condition ||= collection.user.id == current_user.id
    render_response(false, 'Permission denied', nil) unless condition
    condition
  end

  def check_word_permission
    condition = @word.word_collection.user.id == current_user.id if @word.present?
    render_response(false, 'Permission denied', nil) unless condition
  end

  def create_word_params
    params.require(:word).permit(:definition, :translation)
  end

  def edit_word_params
    params.require(:word).permit(:definition, :translation)
  end
end
