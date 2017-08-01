class WordCollection < ApplicationRecord
  belongs_to :user, optional: true
  has_many :word

  def as_json(_options = {})
    super(only: %i[id name])
  end
end
