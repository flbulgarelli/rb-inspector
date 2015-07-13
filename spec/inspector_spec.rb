require_relative '../lib/inspector'

describe Inspector do

  describe 'PatternMatching' do
    include AST::Sexp
    include AST::Patterns

    let(:exp) { s(:foo, :bar, s(:baz), 3) }

    it { expect(v.bind(4)).to eq [4] }
    it { expect(v.bind(:bar)).to eq [:bar] }
    it { expect(_.bind(:bar)).to eq [] }
    it { expect(AST::Patterns::Literal.new(:bar).bind(:bar)).to eq [] }
    it { expect(AST::Patterns::Literal.new(:foo).bind(:bar)).to eq nil }

    it { expect(p(:foo).bind(exp)).to be nil }
    it { expect(p(_).bind(exp)).to be nil }
    it { expect(p(_, _, _).bind(exp)).to be nil }
    it { expect(p(_, _, _, 4).bind(exp)).to be nil }
    it { expect(p(:foo, _, _, _).bind(exp)).to eq [] }
    it { expect(p(:foo, :bar, _, 3).bind(exp)).to eq [] }
    it { expect(p(:foo, v, _, v).bind(exp)).to eq [:bar, 3] }
    it { expect(p(:foo, v, p(:baz), v).bind(exp)).to eq [:bar, 3] }
    it { expect(p(:foo, v, p(_), v).bind(exp)).to eq [:bar, 3] }
    it { expect(p(:foo, v, p(v), v).bind(exp)).to eq [:bar, :baz, 3] }

  end

  context 'when no binding' do
    let(:code) { Inspector::Code.parse 'x + 1' }
    it { expect(code.has_binding? :foo).to be false }
    it { expect(code.has_binding? :x).to be false }
  end

  context 'when variable declaration' do
    let(:code) { Inspector::Code.parse 'x = 2' }

    it { expect(code.has_binding? :foo).to be false }
    it { expect(code.has_binding? :x).to be true }
  end

  context 'when method declaration' do
    let(:code) { Inspector::Code.parse 'def foo; x = 4; x ; end' }

    it { expect(code.has_binding? :foo).to be true }
    it { expect(code.has_binding? :x).to be false }
  end

  context 'when class declaration' do
    let(:code) { Inspector::Code.parse 'class Foo; def bar; end; end' }

    it { expect(code.has_binding? :Foo).to be true }
    it { expect(code.has_binding? :bar).to be false }
  end

  context 'when scoped class declaration' do
    let(:code) { Inspector::Code.parse 'class X::Foo; def bar; end; end' }

    it { expect(code.has_binding? :Foo).to be false }
  end

  context 'when top level class declaration' do
    let(:code) { Inspector::Code.parse 'class ::Foo; def bar; end; end' }

    it { expect(code.has_binding? :Foo).to be true }
  end

  context 'when module declaration' do
    let(:code) { Inspector::Code.parse 'module Foo; def bar; end; end' }

    it { expect(code.has_binding? :Foo).to be true }
    it { expect(code.has_binding? :bar).to be false }
  end

  context 'when method declaration in class' do
    let(:code) { Inspector::Code.parse 'module Foo; def bar; end; end' }

    it { pending; expect(code.has_binding? :'Foo.bar').to be true }
    it { expect(code.has_binding? :'Foo.baz').to be false }
    it { expect(code.has_binding? :'Baz.bar').to be false }
  end

  context 'when method declaration in object' do
    let(:code) { Inspector::Code.parse 'foo = Foo.new; def foo.bar; end' }

    it { pending; expect(code.has_binding? :'foo.bar').to be true }
    it { expect(code.has_binding? :'foo.baz').to be false }
    it { expect(code.has_binding? :'baz.bar').to be false }
  end

  context 'when scoped module declaration' do
    let(:code) { Inspector::Code.parse 'module X::Foo; def bar; end; end' }

    it { expect(code.has_binding? :Foo).to be false }
  end

  context 'when top level module declaration' do
    let(:code) { Inspector::Code.parse 'module ::Foo; def bar; end; end' }

    it { expect(code.has_binding? :Foo).to be true }
  end

  context 'when multiple declarations' do
    let(:code) { Inspector::Code.parse 'def bar; 4; end; x = 2; z = 7' }

    it { expect(code.has_binding? :bar).to be true }
    it { expect(code.has_binding? :x).to be true }
    it { expect(code.has_binding? :z).to be true }
    it { expect(code.has_binding? :y).to be false }
  end

end
