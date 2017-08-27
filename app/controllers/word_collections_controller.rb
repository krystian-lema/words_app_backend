class WordCollectionsController < ApplicationController
  before_action :authorize
  before_action :find_collection, only: %i[change_collection_name delete_collection]
  before_action :check_permission, only: %i[change_collection_name delete_collection]

  def get_public_collections
    @collections = WordCollection.all.where(public: true)
    render_response(true, nil, { word_collections: @collections })
  end

  def get_collections
    @collections = WordCollection.all.where(user_id: current_user.id)
    render_response(true, nil, { word_collections: @collections })
  end

  def create_collection
    collection = WordCollection.new(create_collection_params)
    collection.user = current_user
    collection.public = false
    if collection.save
      render_response(true, nil, { word_collection: collection })
    else
      render_response(false, collection.errors.full_messages.first, nil)
    end
  end

  def change_collection_name
    if @collection.update(change_collection_name_params)
      render_response(true, nil, { word_collection: @collection })
    else
      render_response(false, @collection.errors.full_messages.first, nil)
    end
  end

  def delete_collection
    if @collection.destroy
      render_response(true, nil, nil)
    else
      render_response(false, @collection.errors.full_messages.first, nil)
    end
  end

  private

  def find_collection
    @collection = WordCollection.find(params[:id]) if WordCollection.where(id: params[:id]).present?
    render_response(false, 'Colllection does not exist', nil) if @collection.blank?
  end

  def check_permission
    condition = @collection.user.id == current_user.id
    render_response(false, 'Permission denied', nil) unless condition
  end

  def create_collection_params
    params.permit(:name)
  end

  def change_collection_name_params
    params.permit(:name)
  end
end
