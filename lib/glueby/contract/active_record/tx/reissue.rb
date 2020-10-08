module Glueby
  module Contract
    module AR
      module Tx
        class Reissue < ::ActiveRecord::Base
          include Tx::TxValidator

          belongs_to :token
          enum status: { init: 0, broadcasted: 1, finalized: 2 }
          validates :receiver_wallet_id, format: { with: /\A[[:xdigit:]]{32}\z/ }, presence: true
          validates :token, presence: true

          validate :reissuable_token

          def reissuable_token
            return unless token
            unless token.token_type == Tapyrus::Color::TokenTypes::REISSUABLE
              errors.add(:token, "is not reissuable")
            end
            unless token.script_pubkey&.present?
              errors.add(:token, "does not have script pubkey")
            end
          end
        end
      end
    end
  end
end
