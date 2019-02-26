class Purchase < ApplicationRecord
  belongs_to :user
  notifies :user, :purchase

  def purchase
  end
end
