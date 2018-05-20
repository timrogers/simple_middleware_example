class Customer < ApplicationRecord
  validates :email, presence: true, uniqueness: true
  validates :iban, presence: true

  belongs_to :user
end
