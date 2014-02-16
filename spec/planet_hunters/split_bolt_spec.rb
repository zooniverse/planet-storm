require 'java'
require 'spec_helper'
require 'planet_hunters/split_bolt'

java_import 'backtype.storm.Testing'
java_import 'backtype.storm.tuple.Values'
java_import 'backtype.storm.testing.MkTupleParam'

describe SplitBolt do
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

  let :tuple do
    Testing.testTuple(Values.new(test_classification), 
                      MkTupleParam.new.tap{|p| p.setFields("classification")})
  end

  before(:each) do
    @collector = double("OutputCollector")
  end

  it "should split markings in classifications" do
    result = []
    expect(@collector).to receive(:emit).exactly(2).times do |values|
      result << values[0]
    end

    bolt = SplitBolt.new
    bolt.prepare(nil, nil, @collector)
    bolt.execute(tuple)

    expect(result).to eq([{
          "start" => 25,
          "finish" => 50
        },
        {
          "start" => 70,
          "finish" => 150
        }])
  end

  it "should include the subject id in the returned tuples" do
    result = []
    expect(@collector).to receive(:emit).exactly(2).times do |values|
      result << values[1]
    end

    bolt = SplitBolt.new
    bolt.prepare(nil, nil, @collector)
    bolt.execute(tuple)

    expect(result).to eq(["another_bson_id", "another_bson_id"])

  end

end
