require 'test_helper'

describe UnicornMetrics do
  describe '::registry' do
    it 'returns the UnicornMetrics::Registry object' do
      UnicornMetrics.registry.must_equal UnicornMetrics::Registry
    end
  end

  describe '::configure' do
    it 'yields self' do
      -> { UnicornMetrics.configure { |u| print u } }.must_output 'UnicornMetrics'
    end
  end

  describe '::http_metrics=' do
    before { UnicornMetrics.metrics.delete_if { true } }
    context 'when arg is false' do
      it 'should not include http metrics' do
        UnicornMetrics.http_metrics = false
        UnicornMetrics.default_register
        UnicornMetrics.metrics.keys.must_equal ['cloudinsight']
      end
    end

    context 'when arg is true' do
      before do
        UnicornMetrics.http_metrics = true
        UnicornMetrics.default_register
      end

      it 'extends Registry with DefaultHttpMetrics module' do
        UnicornMetrics.registry.must_respond_to :register_default_http_counters
        UnicornMetrics.registry.must_respond_to :register_default_http_timers
      end

      it 'registers the default component counters' do
        UnicornMetrics.registry.metrics.keys.size.must_equal 10
      end
    end
  end

  it 'delegates unknown methods to Registry' do
    methods       = UnicornMetrics.registry.methods(false)
    respond_count = 0
    methods.each { |m| respond_count += 1 if UnicornMetrics.respond_to?(m) }
    respond_count.must_equal methods.size
  end
end
