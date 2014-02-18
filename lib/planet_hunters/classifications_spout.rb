require 'java'
require 'red_storm'
require './json_scheme'

java_import 'storm.kafka.KafkaSpout'
java_import 'storm.kafka.ZkHosts'
java_import 'storm.kafka.SpoutConfig'
java_import 'backtype.storm.spout.SchemeAsMultiScheme'

class KafkaClassificationsSpout < KafkaSpout

  def self.base_class_path
    @base_class_path
  end

  def self.base_class_path=(path)
    @base_class_path = path
  end

  def initialize(zk_host, project, client_id=nil)
    brokers = ZkHosts.new(zk_host)
    conf = SpoutConfig.new(brokers, "classifications_#{project}", "", client_id)
    conf.scheme = SchemeAsMultiScheme.new(JsonScheme)
    super(conf)
  end

end
