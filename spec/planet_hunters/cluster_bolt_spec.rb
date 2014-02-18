require 'red_storm'
require 'spec_helper'
require 'planet_hunters_cluster'

java_import 'backtype.storm.Testing'
java_import 'backtype.storm.tuple.Values'
java_import 'backtype.storm.testing.MkTupleParam'

describe ClusterBolt do
  let :marking do
    {"start" => 70, "finish" => 150}
  end

  let :tuple do
    Testing.testTuple(Values.new(marking, "a_bson_id"), 
                      MkTupleParam.new.tap{|p| p.setFields("marking"); p.setFields("subject_id")})
  end

  before(:each) do
    @collector = double("OutputCollector")
    @bolt = ClusterBolt.new
    @bolt.prepare(nil, nil, @collector)
  end

  it "should add hitherto unknown transists to its internal state" do
    expect(@bolt.transists['a_bson_id']).to be_empty
    @bolt.execute(tuple)
    expect(@bolt.transists['a_bson_id']).to_not be_empty
  end
end
