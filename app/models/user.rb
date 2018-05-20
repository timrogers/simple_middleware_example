class User < ApplicationRecord
  validates :email, :access_token, presence: true,
                                   uniqueness: true

  has_many :customers
end
