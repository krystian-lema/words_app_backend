class Word < ApplicationRecord
  belongs_to :word_collection

  def as_json(_options = {})
    super(only: %i[id definition translation])
  end
end
