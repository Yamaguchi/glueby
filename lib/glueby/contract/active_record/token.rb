module Glueby
  module Contract
    module AR
      class Token < ::ActiveRecord::Base
        validates :token_type, inclusion: { in: [Tapyrus::Color::TokenTypes::REISSUABLE, Tapyrus::Color::TokenTypes::NON_REISSUABLE, Tapyrus::Color::TokenTypes::NFT] }
        validates :issuer_wallet_id, format: { with: /\A[[:xdigit:]]{32}\z/ }, presence: true
        validates :color_id, format: { with: /\A[[:xdigit:]]{66}?\z/ }
        validates :script_pubkey, format: { with: /\A[[:xdigit:]]*\z/ }

        def self.issue!(token_type:, issuer_wallet_id:)

        end
      end
    end
  end
end
