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
end
