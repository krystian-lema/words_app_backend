class WordCollectionsController < ApplicationController
  before_action :authorize
  before_action :find_collection, only: %i[change_collection_name delete_collection]
  before_action :check_permission, only: %i[change_collection_name delete_collection]

  def get_public_collections
    @collections = WordCollection.all.where(public: true)
    render json: { success: true, word_collections: @collections, auth_token: updated_auth_token }
  end

  def get_collections
    @collections = WordCollection.all.where(user_id: current_user.id)
    render json: { success: true, word_collections: @collections, auth_token: updated_auth_token }
  end

  def create_collection
    collection = WordCollection.new(create_collection_params)
    collection.user = current_user
    collection.public = false
    if collection.save
      render json: { success: true, word_collection: collection, auth_token: updated_auth_token }
    else
      render json: { success: false, error: collection.errors.full_messages.first, auth_token: updated_auth_token }
    end
  end

  def change_collection_name
    if @collection.update(change_collection_name_params)
      render json: { success: true, word_collection: @collection, auth_token: updated_auth_token }
    else
      render json: { success: false, error: @collection.errors.full_messages.first, auth_token: updated_auth_token }
    end
  end

  def delete_collection
    if @collection.destroy
      render json: { success: true, auth_token: updated_auth_token }
    else
      render json: { success: false, error: @collection.errors.full_messages.first, auth_token: updated_auth_token }
    end
  end

  private

  def find_collection
    @collection = WordCollection.find(params[:id]) if WordCollection.where(id: params[:id]).present?
    render json: { success: false, error: 'Colllection does not exist', auth_token: updated_auth_token } if @collection.blank?
  end

  def check_permission
    condition = @collection.user.id == current_user.id
    render json: { success: false, error: 'Permission denied', auth_token: updated_auth_token } unless condition
  end

  def create_collection_params
    params.require(:word_collection).permit(:name)
  end

  def change_collection_name_params
    params.require(:word_collection).permit(:name)
  end
end
