module Tapyrus
  module Contract
    # Timestamp feature allows users to send transaction with op_return output which has sha256 hash of arbitary data.
    # Timestamp transaction has
    # * 1 or more inputs enough to afford transaction fee.
    # * 1 output which has op_return, application specific prefix, and sha256 hash of data.
    # * 1 output to send the change TPC back to the input address.
    #
    # Storing timestamp transaction to the blockchain enables everyone to verify that the data existed at that time and a user signed it.
    class Timestamp
      include Tapyrus::Contract::TxBuilder

      attr_reader :tx, :txid

      # @param [String] content Data to be hashed and stored in blockchain.
      # @param [Tapyrus::Rpc::Client] rpc
      # @param [WalletFeature] sender
      # @param [String] prefix prefix of op_return data
      # @param [Tapyrus::Contract::FeeProvider] fee_provider
      def initialize(
        content:,
        rpc:,
        sender:,
        prefix: '',
        fee_provider: Tapyrus::Contract::FixedFeeProvider.new
      )
        @content = content
        @rpc = rpc
        @sender = sender
        @prefix = prefix
        @fee_provider = fee_provider
      end

      # broadcast to Tapyrus Core
      # raise TxAlreadyBroadcasted if tx has been broadcasted.
      # @return [String] txid
      def save!
        raise Tapyrus::Contract::Errors::TxAlreadyBroadcasted if @txid

        @tx = create_tx(@prefix, Timestamp.content_hash(@content), @sender, @fee_provider)
        keys = [@sender.key.to_wif]
        @tx = sign_tx(@tx, keys)
        @txid = broadcast_tx(@tx)
      end

      def self.validate!(txid:, content:, rpc:, sender: nil, prefix: nil)
        tx = find!(txid, rpc)
        script = tx.outputs.map(&:script_pubkey).find(&:op_return?)
        raise Tapyrus::Contract::Errors::OpReturnDataNotFound unless script

        payload = script.op_return_data
        raise Tapyrus::Contract::Errors::InvalidPrefix if prefix && !payload.start_with?(prefix)

        hash = if prefix 
          payload[prefix.size..]
        else
          payload
        end
        raise Tapyrus::Contract::Errors::InvalidHashValue unless hash == Timestamp.content_hash(content)

        if sender
          p2pkh = Tapyrus::Script.parse_from_payload(sender.to_p2pkh)
          for i in (0...tx.inputs.size)
            raise Tapyrus::Contract::Errors::InvalidSender unless tx.verify_input_sig(i, p2pkh)
          end
        end
        true
      end

      private

      def self.content_hash(content)
        Tapyrus.sha256(content)
      end

      def self.find(txid, rpc)
        response = rpc.getrawtransaction(txid)
        Tapyrus::Tx.parse_from_payload(response.htb)
      rescue => e
        raise Tapyrus::Contract::Errors::TransactionNotFound
      end

      def create_tx(prefix, data_hash, sender, fee_provider)
        tx = Tapyrus::Tx.new
        tx.outputs << Tapyrus::TxOut.new(value: 0, script_pubkey: create_script(prefix, data_hash))

        results = list_unspent(sender)
        fee = fee_provider.fee(tx)
        sum, outputs = collect_outputs(results, fee)
        fill_input(tx, outputs)

        change_script = Tapyrus::Script.parse_from_payload(sender.to_p2pkh)
        fill_change_output(tx, fee, change_script, sum)
        tx
      end

      def create_payload(prefix, data_hash)
        payload = +''
        payload << prefix
        payload << data_hash
      end

      def create_script(prefix, data_hash)
        script = Tapyrus::Script.new
        script << Tapyrus::Script::OP_RETURN
        script << create_payload(prefix, data_hash)
        script
      end

      def sign_tx(tx, keys)
        # TODO: Implement SignatureProvider
        response = @rpc.signrawtransactionwithkey(tx.to_payload.bth, keys)
        Tapyrus::Tx.parse_from_payload(response['hex'].htb)
      end

      def list_unspent(sender)
        # TODO: Implement UtxoProvider
        @rpc.importaddress(sender.to_p2pkh.bth, "", false)
        @rpc.listunspent(0, 999_999, [sender.address])
      end

      def broadcast_tx(tx)
        @rpc.sendrawtransaction(tx.to_payload.bth)
      end
    end
  end
end
