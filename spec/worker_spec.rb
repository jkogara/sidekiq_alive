RSpec.describe SidekiqAlive::Worker do
  subject do
    n = described_class.new
    n.perform(SidekiqAlive.liveness_key)
  end

  it 'calls to main methods in SidekiqAlive' do
    expect(described_class).to receive(:perform_in).with(instance_of(Fixnum), SidekiqAlive.liveness_key)
    expect(SidekiqAlive).to receive(:store_alive_key).once
    n = 0
    expect(SidekiqAlive).to receive(:callback).once.and_return(proc { n = 2 })
    subject
    expect(n).to eq 2
  end

  context 'when the job belongs to another container' do
    subject do
      n = described_class.new
      n.perform('some_other_key')
    end

    it 'does not write the liveliness key' do
      expect(SidekiqAlive).to receive(:store_alive_key).never
      expect(SidekiqAlive).to receive(:callback).never
      expect { subject }.to raise_error(StandardError, "Not the correct host, will retry")
    end
  end
end
