require 'openscap'
require 'openscap/ds/arf'
require 'openscap/xccdf/benchmark'

class OpenscapResult < ApplicationRecord
  belongs_to :container_image
  has_one    :binary_blob,           :dependent => :destroy, :autosave => true, :as => :resource
  has_many   :openscap_rule_results, :dependent => :destroy, :autosave => true

  def html
    raw = binary_blob.try(:binary)
    return unless raw
    with_openscap_arf(raw) do |arf|
      ascii8bit_to_utf8(arf.html)
    end
  end

  def raw=(value)
    self.binary_blob = BinaryBlob.new(:name => 'openscap_compliance_arf', :data_type => 'XML')
    binary_blob.binary = value
    create_results(binary_blob.binary)
  end

  private

  def create_results(raw)
    with_openscap_detailed_results(raw) do |rule_results, benchmark_items|
      rule_results.each do |openscap_id, result|
        openscap_rule_results << OpenscapRuleResult.new(
          :name            => ascii8bit_to_utf8(openscap_id),
          :result          => ascii8bit_to_utf8(result.result),
          :openscap_result => self,
          :severity        => ascii8bit_to_utf8(benchmark_items[openscap_id].severity)
        )
      end
    end
  end

  def ascii8bit_to_utf8(string)
    string.to_s.encode('utf-8', :invalid => :replace, :undef => :replace, :replace => '_')
  end

  def with_openscap_detailed_results(raw)
    raise 'no block given' unless block_given?
    with_openscap_arf(raw) do |arf|
      begin
        test_result = arf.test_result
        source_datastream = arf.report_request
        bench_source = report_request.select_checklist!
        benchmark = OpenSCAP::Xccdf::Benchmark.new(bench_source)
        ret = yield(test_result.rr, benchmark.items)
      ensure
        benchmark.try(:destroy)
        source_datastream.try(:destroy)
        test_result.try(:destroy)
      end
      ret
    end
  end

  def with_openscap_arf(raw)
    raise "no block given" unless block_given?
    begin
      OpenSCAP.oscap_init

      # ARF - nist standardized 'Asset Reporting Format' Full representation if a scap scan result.
      arf = OpenSCAP::DS::Arf.new(:content => raw, :length => raw.length, :path => 'incoming_arf.xml')
      ret = yield arf
    ensure
      arf.try(:destroy)
      OpenSCAP.oscap_cleanup
    end
    ret
  end
end
