require_relative '../lib/inspector'

describe Inspector do

  context 'when no binding' do
    let(:code) { Inspector::Code.parse 'x + 1' }
    it { expect(code.has_binding? 'foo').to be false }
    it { expect(code.has_binding? 'x').to be false }
  end

  context 'when variable declaration' do
    let(:code) { Inspector::Code.parse 'x = 2' }

    it { expect(code.has_binding? 'foo').to be false }
    it { expect(code.has_binding? 'x').to be true }
  end

  context 'when method declaration' do
    let(:code) { Inspector::Code.parse 'def foo; x = 4; x ; end' }

    it { expect(code.has_binding? 'foo').to be true }
    it { expect(code.has_binding? 'x').to be false }
  end

  context 'when class declaration' do
    let(:code) { Inspector::Code.parse 'class Foo; def bar; end; end' }

    it { expect(code.has_binding? 'Foo').to be true }
    it { expect(code.has_binding? 'bar').to be false }
  end


  context 'when scoped class declaration' do
    let(:code) { Inspector::Code.parse 'class X::Foo; def bar; end; end' }

    it { expect(code.has_binding? 'Foo').to be false }
  end

  context 'when top level class declaration' do
    let(:code) { Inspector::Code.parse 'class ::Foo; def bar; end; end' }

    it { expect(code.has_binding? 'Foo').to be true }
  end


  context 'when multiple declarations' do
    let(:code) { Inspector::Code.parse 'def bar; 4; end; x = 2; z = 7' }

    it { expect(code.has_binding? 'bar').to be true }
    it { expect(code.has_binding? 'x').to be true }
    it { expect(code.has_binding? 'z').to be true }
    it { expect(code.has_binding? 'y').to be false }
  end

end
