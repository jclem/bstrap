require "../spec_helper"

describe Bstrap::AppEnv do
  it "sets a value with #[]=" do
    env = Bstrap::AppEnv.new
    env["foo"] = "bar"
    env.get_entry("foo").as(Bstrap::Entry).value.should eq("bar")
  end

  it "gets a value with #[]" do
    env = Bstrap::AppEnv.new
    env["foo"] = "bar"
    env["foo"].should eq("bar")
  end

  it "sets an entry with #put_entry" do
    env = Bstrap::AppEnv.new
    env.put_entry("foo", Bstrap::Entry.new("bar"))
    env["foo"].should eq("bar")
  end

  it "gets an entry with #get_entry" do
    env = Bstrap::AppEnv.new
    env.put_entry("foo", Bstrap::Entry.new("bar"))
    env.get_entry("foo").as(Bstrap::Entry).value.should eq("bar")
  end

  it "is enumerable" do
    env = Bstrap::AppEnv.new
    env["foo"] = "bar"
    env["baz"] = "qux"

    env.reduce([] of String) do |arr, (key, entry)|
      arr.push(key)
      arr.push(entry.value.as(String))
    end.should eq(["foo", "bar", "baz", "qux"])
  end

  it "merges with other AppEnvs" do
    env_a = Bstrap::AppEnv.new
    env_a["foo"] = "bar"
    env_a["baz"] = "qux"

    env_b = Bstrap::AppEnv.new
    env_b["foo"] = "bar_2"
    env_b["quux"] = "quuz"

    env_a.merge!(env_b).to_h.should(
      eq({"foo" => "bar_2", "baz" => "qux", "quux" => "quuz"}))
  end

  it "converts to an envfile" do
    env = Bstrap::AppEnv.new
    env["foo"] = "bar"
    env["baz"] = "qux"
    env.to_envfile.should eq "baz=qux\nfoo=bar\n"
  end

  it "converts to a hash" do
    env = Bstrap::AppEnv.new
    env["foo"] = "bar"
    env["baz"] = "qux"
    env.to_h.should eq({"foo" => "bar", "baz" => "qux"})
  end
end
