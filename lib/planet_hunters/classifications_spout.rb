require 'java'
require 'red_storm'
require './json_scheme'
java_import 'storm.kafka.KafkaSpout'
java_import 'storm.kafka.ZkHosts'
java_import 'storm.kafka.SpoutConfig'
java_import 'backtype.storm.spout.SchemeAsMultiScheme'

class ClassificationsSpout < KafkaSpout

  def initialize(zk_host, topic, client_id=nil)
    brokers = ZkHosts.new(brokers)
    conf = SpoutConfig.new(brokers, topic, "", client_id)
    conf.scheme = SchemeAsMultiScheme.new(JsonScheme)
    super(conf)
  end

end
