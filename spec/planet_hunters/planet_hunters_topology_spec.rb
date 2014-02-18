require 'java'
require 'spec_helper'
require 'planet_hunters/planet_hunters_topology'

java_import 'backtype.storm.Testing'
java_import 'backtype.storm.tuple.Values'
java_import 'backtype.storm.testing.MkTupleParam'
java_import 'backtype.storm.testing.MkClusterParam'
java_import 'backtype.storm.testing.TestJob'
java_import 'backtype.storm.testing.MockedSources'
java_import 'backtype.storm.testing.CompleteTopologyParam'

describe PlanetHuntersTopology do
  let(:test_classification) do
    {
      "_id" => "a_bson_id",
      "annotations" => {
        "user_agent" => "",
        "user_ip" => "",
        "markings" => [{
          "start" => 25,
          "finish" => 50
        },
        {
          "start" => 70,
          "finish" => 150
        }]
      },
      "subjects" => [
        {
          "_id" => "another_bson_id"
        }
      ]
    }
  end

  it "should run the topology" do
    cluster_params = MkClusterParam.new
    cluster_param.set_supervisors(2)
    conf = Backtype::Config.new
    # conf.put(Backtype::Config.STORM_LOCAL_MODE_ZMQ, false)
    # conf.put(Backtype::Config.SUPERVISOR_ENABLE, false)
    conf.put(Backtype::Config.TOPOLOGY_ACKER_EXECUTORS, 0)
    cluster_param.set_daemon_conf(conf)

    TestJob.new.tap do |job|
      def job.run(cluster)
        topology = WordCountTopology.build_topology

        mocked_sources = MockedSources.new
        mocked_sources.add_mock_data("classification_spout", Values.new(test_classification))

        conf = Backtype::Config.new
        conf.set_num_workers(2)

        param = CompleteTopologyParam.new
        param.set_mocked_sources(mocked_sources)
        param.set_storm_conf(conf)

        result = Testing.complete_topology(cluster, topology, param)
        sleep(1) # seems to solve the FileNotFoundException, see https://github.com/nathanmarz/storm/issues/356

        expect(result_tuples(result, "classification_spout")).to eq(test_classification)
        expect(result_tuples(result, "split_bolt")).to eq([
          [{"start" => 25, "finish" => 50}, "another_bson_id"],
          [{"start" => 70, "finish" => 150}, "another_bson_id"]
        ])

      end

      Testing.with_local_cluster(cluster_param, job)
    end


  end
end
