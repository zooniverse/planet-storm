require 'java'
require 'red_storm'

java_import "backtype.storm.LocalCluster"
java_import "backtype.storm.LocalDRPC"
java_import "backtype.storm.StormSubmitter"
java_import "backtype.storm.generated.StormTopology"
java_import "backtype.storm.tuple.Fields"
java_import "backtype.storm.tuple.Values"
java_import "storm.trident.TridentState"
java_import "storm.trident.TridentTopology"
java_import "storm.trident.operation.BaseFunction"
java_import "storm.trident.operation.TridentCollector"
java_import "storm.trident.operation.builtin.Count"
java_import "storm.trident.operation.builtin.FilterNull"
java_import "storm.trident.operation.builtin.MapGet"
java_import "storm.trident.operation.builtin.Sum"
java_import "storm.trident.testing.FixedBatchSpout"
java_import "storm.trident.testing.MemoryMapState"
java_import "storm.trident.tuple.TridentTuple"

java_import 'redstorm.storm.jruby.JRubyTridentFunction'

require 'planet_hunters/classifications_spout'

REQUIRE_PATH = Pathname.new(__FILE__).relative_path_from(Pathname.new(RedStorm::BASE_PATH)).to_s

module PlanetHunters
  class SplitUserId
    def execute(tuple, collector)
      collector.emit(tuple["classification"]["user_id"])
    end

    def prepare(conf,context); end
    def cleanup; end
  end

  class UserAgentPerformanceTopology
    RedStorm::Configuration.topology_class = self

    def build_topology
      topology = TridentTopology.new

      spout = KafkaClassificationsSpoutFactory.create("zk1.zooniverse.local:2181,zk2.zooniverse.local:2181,zk3.zooniverse.local:2181", "planet_hunters")

      user_agents = topology.new_stream("ph_classifications", spout)
        .parallelism_hint(3)
        .each(Fields.new("classification"),
              JRubyTridentFunction.new(REQUIRE_PATH, "PlanetHunters::SplitUserId"),
              Fields.new("user_id"))
        .groupBy(Fields.new("user_id"))
        .persistentAggregate(MemoryMapState::Factory.new, Count.new, Fields.new("count"))
        .parallelism_hint(3)

      topology.build
    end

    def start(env)
      conf = Backtype::Config.new
      conf.debug = true
      conf.max_spout_pending = 200

      case env
      when :local
        submitter = LocalCluster.new
        conf.num_workers = 1
      when :cluster
        submitter = StormSubmitter
        conf.num_workers = 3
      end

      submitter.submit_topology("planet_hunters", conf, build_topology)
    end
  end

end
