module Glueby
  module Contract
    module AR
      module Tx
        module TxValidator
          extend ActiveSupport::Concern

          included do
            validates :amount, numericality: { only_integer: true, greater_than: 0 }, presence: true
            validates :txid, format: { with: /\A[[:xdigit:]]{64}?\z/ }
            validates :status, inclusion: { in: ['init', 'broadcasted', 'finalized']}, presence: true
          end
        end

        autoload :Burn, 'glueby/contract/active_record/tx/burn'
        autoload :Issue, 'glueby/contract/active_record/tx/issue'
        autoload :Payment, 'glueby/contract/active_record/tx/payment'
        autoload :Reissue, 'glueby/contract/active_record/tx/reissue'
        autoload :Transfer, 'glueby/contract/active_record/tx/transfer'
      end
    end
  end
end
