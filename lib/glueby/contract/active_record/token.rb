module Glueby
  module Contract
    module AR
      class Token < ::ActiveRecord::Base
        validates :token_type, inclusion: { in: [Tapyrus::Color::TokenTypes::REISSUABLE, Tapyrus::Color::TokenTypes::NON_REISSUABLE, Tapyrus::Color::TokenTypes::NFT] }
        validates :issuer_wallet_id, format: { with: /\A[[:xdigit:]]{32}\z/ }, presence: true
        validates :color_id, format: { with: /\A[[:xdigit:]]{66}?\z/ }
        validates :script_pubkey, format: { with: /\A[[:xdigit:]]*\z/ }

        def self.issue!(token_type:, issuer_wallet_id:, receiver_wallet_id:, amount:)
          token = Token.create!(token_type: token_type, issuer_wallet_id: issuer_wallet_id)
          tx = Tx::Issue.create!(receiver_wallet_id: receiver_wallet_id, amount: amount, token: token)
          [token, tx]
        end

        def transfer!(sender_wallet_id:, receiver_wallet_id: , amount: )
          Tx::Transfer.new(sender_wallet_id: sender_wallet_id, receiver_wallet_id: receiver_wallet_id, amount: amount)
        end

        def burn!(sender_wallet_id:, amount:)
          Tx::Burn.new(sender_wallet_id: sender_wallet_id, amount: amount, token: self)
        end

        def reissue()


        end
      end
    end
  end
end
