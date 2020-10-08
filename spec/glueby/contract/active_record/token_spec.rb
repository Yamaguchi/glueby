# frozen_string_literal: true

require 'active_record'

RSpec.describe 'Glueby::Contract::AR::Token' do
  def setup_database
    ::ActiveRecord::Base.establish_connection(config)
    connection = ::ActiveRecord::Base.connection
    connection.create_table :tokens do |t|
      t.integer :token_type, null: false
      t.string :color_id, null: false
      t.string :script_pubkey, null: true
      t.string :issuer_wallet_id, null: false
      t.timestamps
    end

    connection.add_index :tokens, [:color_id], unique: true
    connection.add_index :tokens, [:token_type]
    connection.add_index :tokens, [:script_pubkey], unique: true
    connection.add_index :tokens, [:issuer_wallet_id]
  end

  let(:wallet) { Glueby::Internal::Wallet::AR::Wallet.create(wallet_id: 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF') }
  let(:config) { { adapter: 'sqlite3', database: 'test' } }

  before { setup_database }
  after do
    connection = ::ActiveRecord::Base.connection
    connection.drop_table :tokens, if_exists: true
  end


  describe '#valid?' do
    subject { token.valid? }

    let(:token) { Glueby::Contract::AR::Token.new(token_type: token_type, color_id: color_id, script_pubkey: script_pubkey, issuer_wallet_id: issuer_wallet_id) }
    let(:issuer_wallet_id) { '00000000000000000000000000000000' }
    let(:token_type) { Tapyrus::Color::TokenTypes::REISSUABLE }
    let(:color_id) { 'c10000000000000000000000000000000000000000000000000000000000000000' }
    let(:script_pubkey) { '0000000000000000000000000000000000000000' }

    it { is_expected.to be_truthy }

    context 'if token types is not supported' do
      let(:token_type) { -1 }

      it { is_expected.to be_falsy }
    end

    context 'if color_id is invalid' do
      let(:color_id) { 'c10000000000000000000000000000000000000000000000000000000000000000FF' }

      it { is_expected.to be_falsy }
    end

    context 'if script_pubkey is nil' do
      let(:script_pubkey) { nil }

      it { is_expected.to be_truthy }
    end

    context 'if script_pubkey is invalid' do
      let(:script_pubkey) { 'GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG' }

      it { is_expected.to be_falsy }
    end
  end
end