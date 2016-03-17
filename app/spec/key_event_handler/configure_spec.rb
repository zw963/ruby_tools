# -*- coding:utf-8; mode:ruby; -*-

require 'rbindkeys'
require 'fileutils'
require 'revdev'

include Rbindkeys

$tmp_dir = 'tmp'

describe KeyEventHandler do
  before :all do
    FileUtils.mkdir $tmp_dir
  end

  after :all do
    FileUtils.rm_r $tmp_dir
  end

  before do
    @ope = double DeviceOperator
  end

  describe 'bind keys methods' do
    before do
      @defval = :hoge
      @bind_set = []
      @res = double Rbindkeys::BindResolver

      # define stubs
      allow(@res).to receive(:bind) do |i, o|
        @bind_set << [i, o]
      end
      allow(@res).to receive(:resolve) do |input, _pressed_key_set|
        if input == 10
          BindResolver.new
        else
          @defval
        end
      end
      allow(@res).to receive(:just_resolve) do |input, _pressed_key_set|
        BindResolver.new if input == 10
      end
      allow(@res).to receive(:kind_of?) do |klass|
        klass == Rbindkeys::BindResolver
      end
      allow(Rbindkeys::BindResolver).to receive(:new).and_return(@res)

      @handler = KeyEventHandler.new @ope
    end

    describe KeyEventHandler, '#pre_bind_key' do
      context 'with a bind' do
        it 'map the bind to @pre_bind_resolver' do
          @handler.pre_bind_key 1, 0
          expect(@handler.pre_bind_resolver[1]).to eq 0
        end
      end
      context 'with duplicated binds' do
        it 'should raise a DuplicatedNodeError' do
          @handler.pre_bind_key 1, 0
          expect do
            @handler.pre_bind_key(1, 2)
          end.to raise_error DuplicateNodeError
        end
      end
    end

    describe KeyEventHandler, '#bind_key' do
      context 'with two Fixnum' do
        it 'construct @bind_set' do
          @handler.bind_key 0, 1
          expect(@bind_set).to eq [[[0], [1]]]
        end
      end
      context 'with two Arrays' do
        it 'construct @bind_set' do
          @handler.bind_key [0, 1], [2, 3]
          expect(@bind_set).to eq [[[0, 1], [2, 3]]]
        end
      end
      context 'with an Array and a KeyResolver' do
        it 'construct @bind_set' do
          @handler.bind_key [0, 1], @res
          expect(@bind_set).to eq [[[0, 1], @res]]
        end
      end
      context 'with an Array and a block' do
        it 'construct @bind_set' do
          @handler.bind_key [0, 1] do
            # noop
          end
          expect(@bind_set.first[1]).to be_a Proc
        end
      end
      context 'with mix classes' do
        it 'construct @bind_set' do
          @handler.bind_key 1, [2, 3]
          @handler.bind_key [2, 3], 4
          expect(@bind_set).to eq [[[1], [2, 3]], [[2, 3], [4]]]
        end
      end
      context 'with invalid args' do
        it 'raise some error' do
          expect do
            @handler.bind_key [1], [[[2]]]
          end.to raise_error ArgumentError
        end
      end
    end

    describe KeyEventHandler, '#bind_prefix_key' do
      context 'with a new prefix key' do
        it 'construct @bind_set' do
          @handler.bind_prefix_key [0, 1] do
            @handler.bind_key 2, 3
          end
          expect(@bind_set.length).to eq 2
          expect(@bind_set.include?([[2], [3]])).to be true
        end
      end
      context 'with a existing prefix key' do
        it 'should construct @bind_set' do
          @handler.bind_prefix_key [0, 10] do
            @handler.bind_key 2, 3
          end
          expect(@bind_set.length).to eq 1
          expect(@bind_set.include?([[2], [3]])).to be true
        end
      end
    end

    describe KeyEventHandler, '#window' do
      context 'with invalid arg' do
        it 'should raise ArgumentError' do
          expect { @handler.window(nil, 'foo') }.to raise_error ArgumentError
          expect { @handler.window(nil, :class => 'bar') }.to raise_error ArgumentError
        end
      end
      context 'with nil and a regex' do
        it 'should return the BindResolver and added it to @window_bind_resolver_map' do
          size = @handler.window_bind_resolver_map.size
          res = @handler.window(nil, /foo/)
          expect(res).to be_a BindResolver
          expect(@handler.window_bind_resolver_map.size).to eq(size + 1)
          expect(Hash[*@handler.window_bind_resolver_map.flatten]).to have_value res
        end
      end
      context 'with nil and a Hash having :class key' do
        it 'should return the BindResolver and added it to @window_bind_resolver_map' do
          size = @handler.window_bind_resolver_map.size
          res = @handler.window(nil, :class => /foo/)
          expect(res).to be_a BindResolver
          expect(@handler.window_bind_resolver_map.size).to eq(size + 1)
          expect(Hash[*@handler.window_bind_resolver_map.flatten]).to have_value res
        end
      end
      context 'with a BindResolver and a regex' do
        before do
          @arg_resolver = double BindResolver
          allow(@arg_resolver).to receive(:kind_of?).and_return(false)
          allow(@arg_resolver).to receive(:kind_of?).with(BindResolver).and_return(true)
        end
        it 'should return the BindResolver and added it to @window_bind_resolver_map' do
          size = @handler.window_bind_resolver_map.size
          res = @handler.window(@arg_resolver, /foo/)
          expect(res).to be_a BindResolver
          expect(@handler.window_bind_resolver_map.size).to eq(size + 1)
          expect(Hash[*@handler.window_bind_resolver_map.flatten]).to have_value res
        end
      end
    end

    describe 'KeyEventHandler#load_config' do
      before :all do
        @config = File.join $tmp_dir, 'config'
        open @config, 'w' do |f|
          f.write <<-EOF
pre_bind_key KEY_CAPSLOCK, KEY_LEFTCTRL
bind_key [KEY_LEFTCTRL,KEY_F], KEY_RIGHT
bind_key [KEY_LEFTCTRL,KEY_W], [KEY_LEFTCTRL,KEY_X]
bind_prefix_key [KEY_LEFTCTRL,KEY_X] do
  bind_key KEY_K, [KEY_LEFTCTRL, KEY_W]
end
EOF
        end
      end
      it 'construct @pre_bind_key_set and @bind_key_set' do
        @handler.load_config @config
        expect(@handler.pre_bind_resolver.size).to eq 1
        expect(@bind_set.length).to eq 4
        expect(@bind_set[0][1]).to eq [Revdev::KEY_RIGHT]
        expect(@bind_set[1][1]).to eq [Revdev::KEY_LEFTCTRL, Revdev::KEY_X]
        expect(@bind_set[2][1]).to be @res
        expect(@bind_set[3][1]).to eq [Revdev::KEY_LEFTCTRL, Revdev::KEY_W]
      end
    end
  end
end
